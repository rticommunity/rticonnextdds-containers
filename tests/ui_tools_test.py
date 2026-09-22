#!/usr/bin/env python3
"""Validate UI Tools startup, XRDP connectivity and the Admin Console UI."""

import os
import re
import secrets
import socket
import subprocess
import tempfile
import time
import uuid
from pathlib import Path
from typing import Callable

import pytest


def docker(*args, check=True, timeout_seconds=30):
    """Run a Docker command and capture its combined output."""
    return subprocess.run(
        ["docker", *args],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=check,
        timeout=timeout_seconds,
    )


def wait_for(check: Callable[[], bool], seconds=120):
    """Wait until a condition is true or fail after the specified timeout."""
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
        if check():
            return
        time.sleep(1)
    raise RuntimeError("Timed out waiting for " + check.__name__)


def required_option(config, name):
    """Read a required pytest option and produce a useful usage error."""
    value = config.getoption(name)
    if not value:
        raise pytest.UsageError(f"--{name.replace('_', '-')} is required")
    return value


def create_password(temp_dir):
    """Create the temporary password used by the UI container and RDP client."""
    password = Path(temp_dir) / "password"
    password.write_text(secrets.token_urlsafe(32), encoding="utf-8")
    password.chmod(0o600)
    return password


def reject_startup_without_password(image):
    """Verify that the image rejects startup without UI_PASSWORD_FILE."""
    result = docker(
        "run",
        "--rm",
        "--platform",
        "linux/amd64",
        image,
        check=False,
    )
    if result.returncode != 2 or "UI_PASSWORD_FILE" not in result.stdout:
        pytest.fail("Image did not reject startup without a password file")


def start_ui_container(image, container_name, password, license_path):
    """Start UI Tools with a temporary password and an optional RTI license."""
    options = [
        "run",
        "--detach",
        "--name",
        container_name,
        "--platform",
        "linux/amd64",
        "--shm-size",
        "1g",
        "--publish",
        "127.0.0.1::3389",
        "--mount",
        f"type=bind,src={password},dst=/run/secrets/ui_password,readonly",
    ]
    if license_path:
        license_file = Path(license_path).resolve(strict=True)
        connext_version = os.environ.get("CONNEXT_VERSION", "7.7.0")
        options += [
            "--mount",
            f"type=bind,src={license_file},dst=/opt/rti.com/rti_connext_dds-{connext_version}/rti_license.dat,readonly",
            "--env",
            "SERVICE_XRDP_BOOTSTRAP_ENABLED=true",
        ]
    docker(*options, image)


def wait_for_rdp(container_name):
    """Wait until the container's published XRDP port accepts TCP connections."""
    address = docker("port", container_name, "3389/tcp").stdout.strip()
    port = int(address.rsplit(":", 1)[1])

    def rdp_ready():
        """Return whether the published XRDP port accepts a TCP connection."""
        try:
            with socket.create_connection(("127.0.0.1", port), timeout=2):
                return True
        except OSError:
            return False

    wait_for(rdp_ready)


def admin_console_window_visible(container_name, reports):
    """Return whether a visible, normal Admin Console workbench window exists."""
    try:
        result = docker(
            "exec",
            container_name,
            "bash",
            "-lc",
            'for display in /tmp/.X11-unix/X*; do '
            '[ -S "$display" ] || continue; '
            'runuser -u user -- env DISPLAY=":${display##*X}" '
            'XAUTHORITY=/home/user/.Xauthority xwininfo -root -tree; done',
            check=False,
            timeout_seconds=5,
        )
    except subprocess.TimeoutExpired:
        return False

    (reports / "windows.log").write_text(result.stdout, encoding="utf-8")

    windows = re.findall(
        r'(0x[0-9a-f]+).*: \("RTI Administration Console" '
        r'"RTI Administration Console"\)\s+(\d+)x(\d+)',
        result.stdout,
    )
    for window, width, height in windows:
        if int(width) < 400 or int(height) < 250:
            continue
        state = docker(
            "exec",
            container_name,
            "bash",
            "-lc",
            'for display in /tmp/.X11-unix/X*; do '
            '[ -S "$display" ] || continue; '
            'runuser -u user -- env DISPLAY=":${display##*X}" '
            'XAUTHORITY=/home/user/.Xauthority xwininfo -id "$1"; done',
            "--",
            window,
            check=False,
            timeout_seconds=5,
        )
        if "Map State: IsViewable" in state.stdout:
            return True
    return False


def validate_remote_screenshot(container_name):
    """Preprocess the remote screenshot and validate its pixels and OCR text."""
    mean_result = docker(
        "exec",
        container_name,
        "convert",
        "/tmp/rdp-desktop.png",
        "-colorspace",
        "gray",
        "-format",
        "%[fx:mean]",
        "info:",
    )
    try:
        mean = float(mean_result.stdout.strip())
    except ValueError as error:
        raise RuntimeError("Could not calculate the remote screenshot brightness") from error
    if mean <= 0.02:
        raise RuntimeError("RDP desktop capture is empty or almost completely black")

    docker(
        "exec",
        container_name,
        "convert",
        "/tmp/rdp-desktop.png",
        "-resize",
        "200%",
        "-colorspace",
        "gray",
        "-sharpen",
        "0x1",
        "/tmp/rdp-ocr.png",
    )
    ocr_result = docker(
        "exec",
        container_name,
        "tesseract",
        "/tmp/rdp-ocr.png",
        "stdout",
        "--psm",
        "11",
        check=False,
    )
    ocr = ocr_result.stdout
    expected_text = (
        r"administration\s+console",
        r"auto[-\s]*join",
        r"active\s+domains",
    )
    missing = [pattern for pattern in expected_text if not re.search(pattern, ocr, re.IGNORECASE)]
    if missing:
        raise RuntimeError(f"Admin Console OCR did not find expected text: {missing}")


def wait_for_remote_capture(container_name):
    """Wait until the RDP client has captured a screenshot and remains running."""

    def capture_ready():
        state = docker(
            "inspect",
            "--format",
            "{{.State.Running}}",
            container_name,
            check=False,
        )
        if state.returncode != 0:
            return False
        if state.stdout.strip().lower() != "true":
            logs = docker("logs", container_name, check=False).stdout
            raise RuntimeError(f"RDP client stopped before capture:\n{logs}")
        ready = docker(
            "exec",
            container_name,
            "test",
            "-s",
            "/tmp/rdp-desktop.png",
            check=False,
        )
        if ready.returncode != 0:
            return False
        png = docker(
            "exec",
            container_name,
            "identify",
            "/tmp/rdp-desktop.png",
            check=False,
        )
        return png.returncode == 0

    wait_for(capture_ready, seconds=180)


def run_admin_console_rdp_test(
    rdp_client_image,
    container_name,
    password,
    reports,
):
    """Connect to Admin Console from a separate container and validate its screenshot."""
    wait_for(lambda: admin_console_window_visible(container_name, reports), seconds=180)
    # Give the workbench time to finish rendering before opening the RDP session.
    time.sleep(5)

    rdp_client_name = container_name + "-rdp-client"
    docker(
        "run",
        "--detach",
        "--name",
        rdp_client_name,
        "--network",
        f"container:{container_name}",
        "--env",
        f"RDP_PASSWORD={password.read_text(encoding='utf-8')}",
        rdp_client_image,
        "bash",
        "/usr/local/bin/rdp-client-test.sh",
    )
    try:
        wait_for_remote_capture(rdp_client_name)
    except Exception:
        (reports / "rdp-client.log").write_text(
            docker("logs", rdp_client_name, check=False).stdout,
            encoding="utf-8",
        )
        raise
    screenshot = reports / "desktop.png"
    docker("cp", f"{rdp_client_name}:/tmp/rdp-desktop.png", str(screenshot))
    if not screenshot.is_file() or screenshot.stat().st_size == 0:
        raise RuntimeError("RDP desktop capture is missing or empty")
    validate_remote_screenshot(rdp_client_name)
    (reports / "rdp-client.log").write_text(
        docker("logs", rdp_client_name, check=False).stdout,
        encoding="utf-8",
    )


def collect_container_logs(container_name, reports):
    """Save container and X session logs for troubleshooting failed UI tests."""
    (reports / "container.log").write_text(
        docker("logs", container_name, check=False).stdout,
        encoding="utf-8",
    )
    (reports / "session.log").write_text(
        docker(
            "exec",
            container_name,
            "cat",
            "/home/user/.xsession-errors",
            check=False,
        ).stdout,
        encoding="utf-8",
    )


def test_ui_tools(pytestconfig, ui_mode):
    """Validate startup, XRDP connectivity and, when licensed, Admin Console."""
    image = required_option(pytestconfig, "image")
    rdp_client_image = required_option(pytestconfig, "rdp_client_image")
    reports = Path(required_option(pytestconfig, "reports")).resolve()
    license_path = pytestconfig.getoption("license_file")
    reports.mkdir(parents=True, exist_ok=True)
    container_name = "connext-ui-test-" + uuid.uuid4().hex[:12]
    rdp_client_name = container_name + "-rdp-client"

    with tempfile.TemporaryDirectory() as temp_dir:
        password = create_password(temp_dir)
        try:
            # First validate the mandatory password behavior independently.
            reject_startup_without_password(image)
            start_ui_container(image, container_name, password, license_path)
            wait_for_rdp(container_name)

            # The Admin Console path is enabled only when a license is supplied.
            if license_path:
                run_admin_console_rdp_test(
                    rdp_client_image,
                    container_name,
                    password,
                    reports,
                )
        finally:
            collect_container_logs(container_name, reports)
            docker("rm", "-f", rdp_client_name, check=False)
            docker("rm", "-f", container_name, check=False)
