#!/usr/bin/env python3
"""Run HelloWorld publisher/subscriber tests in isolated Docker containers."""

import os
import shutil
import threading
import re
import shlex
import subprocess
import uuid
from pathlib import Path

import pexpect
import pytest


def run(args):
    """Run a subprocess and raise an error when it exits unsuccessfully."""
    subprocess.run(args, check=True)


def docker_command(args):
    """Return a shell-escaped Docker command suitable for pexpect."""
    return shlex.join(args)


def language_dir(language):
    """Return the build directory name associated with a language profile."""
    return language.lower()


def commands_for(language):
    """Return subscriber and publisher commands for a language profile."""
    common_arch = "${CONNEXTDDS_ARCH}"
    common_home = "${NDDSHOME}"

    if language in ("C", "CPP98", "CPP11"):
        return (
            f"./objs/{common_arch}/HelloWorld_subscriber",
            f"./objs/{common_arch}/HelloWorld_publisher",
        )
    if language == "Java":
        classpath = f".:objs/{common_arch}:{common_home}/lib/java/nddsjava.jar"
        return (
            f'java -cp "{classpath}" HelloWorldSubscriber',
            f'java -cp "{classpath}" HelloWorldPublisher',
        )
    if language == "CSharp":
        return (
            "dotnet publish/HelloWorld.dll --sub",
            "dotnet publish/HelloWorld.dll --pub",
        )
    if language == "Python":
        return (
            "python3 HelloWorld_subscriber.py",
            "python3 HelloWorld_publisher.py",
        )

    raise ValueError(f"Unsupported language: {language}")


def docker_run_command(
    image, name, network, platform, workdir, license_file, inner_command
):
    """Build the Docker command used to run one pub/sub endpoint."""
    args = ["docker", "run", "--rm", "--tty", "--name", name]
    if platform:
        args.extend(["--platform", platform])
    args.extend(
        [
            "--network",
            network,
            "--volume",
            f"{workdir}:/work",
            "--volume",
            f"{license_file}:/licenses/rti_license.dat:ro",
            "--env",
            "RTI_LICENSE_FILE=/licenses/rti_license.dat",
            image,
            "bash",
            "-lc",
            inner_command,
        ]
    )
    return docker_command(args)


def write_qos_file(build_dir):
    """Copy the shared QoS resource into the language build directory."""
    repo_root = Path(__file__).resolve().parents[1]
    qos_source = repo_root / "resources" / "qos" / "USER_QOS_PROFILES.xml"
    if not qos_source.is_file():
        pytest.fail(f"Missing QoS resource: {qos_source}")
    shutil.copyfile(qos_source, build_dir / "USER_QOS_PROFILES.xml")


def expect_received_sample(subscriber, timeout):
    """Wait until the subscriber output contains a HelloWorld sample."""
    pattern = re.compile(
        r"(msg:\s*\"?HelloWorld|Received:.*HelloWorld)", re.IGNORECASE
    )
    subscriber.expect(pattern, timeout=timeout)


def terminate(child):
    """Force-terminate a running pexpect child process when necessary."""
    if child is not None and child.isalive():
        child.terminate(force=True)


def required_option(config, name):
    """Read a required pytest option or raise a usage error."""
    value = config.getoption(name)
    if not value:
        raise pytest.UsageError(f"--{name.replace('_', '-')} is required")
    return value


def test_hello_world_pubsub(pytestconfig, language):
    """Verify real HelloWorld communication between two Runtime containers."""
    runtime_image = required_option(pytestconfig, "runtime_image")
    workdir = Path(required_option(pytestconfig, "workdir")).resolve()
    license_file = Path(required_option(pytestconfig, "license_file")).resolve()
    platform = pytestconfig.getoption("platform")
    timeout = pytestconfig.getoption("timeout")

    build_dir = workdir / "build" / language_dir(language)
    if not build_dir.is_dir():
        pytest.fail(f"Missing build directory: {build_dir}")

    if not license_file.is_file():
        pytest.fail(f"Missing license file: {license_file}")

    write_qos_file(build_dir)

    network = f"connext-pubsub-{uuid.uuid4().hex[:12]}"
    subscriber_name = f"{network}-sub"
    publisher_name = f"{network}-pub"
    subscriber = None
    publisher = None

    subscriber_cmd, publisher_cmd = commands_for(language)
    report_dir = Path(os.environ.get("TEST_REPORT_DIR", "reports/pubsub"))
    report_dir.mkdir(parents=True, exist_ok=True)
    stop_reader = threading.Event()
    publisher_reader = None
    subscriber_log = (report_dir / f"{language}-subscriber.log").open("w", encoding="utf-8")
    publisher_log = (report_dir / f"{language}-publisher.log").open("w", encoding="utf-8")
    try:
        run(["docker", "network", "create", network])
        subscriber = pexpect.spawn(
            docker_run_command(
                runtime_image,
                subscriber_name,
                network,
                platform,
                workdir,
                license_file,
                f"cd /work/build/{language_dir(language)} && {subscriber_cmd}",
            ),
            encoding="utf-8",
            timeout=timeout,
        )
        subscriber.logfile_read = subscriber_log

        publisher = pexpect.spawn(
            docker_run_command(
                runtime_image,
                publisher_name,
                network,
                platform,
                workdir,
                license_file,
                f"cd /work/build/{language_dir(language)} && {publisher_cmd}",
            ),
            encoding="utf-8",
            timeout=timeout,
        )
        publisher.logfile_read = publisher_log

        def drain_publisher():
            while not stop_reader.is_set():
                try:
                    publisher.read_nonblocking(4096, timeout=0.2)
                except pexpect.TIMEOUT:
                    continue
                except pexpect.EOF:
                    break

        publisher_reader = threading.Thread(target=drain_publisher, daemon=True)
        publisher_reader.start()

        expect_received_sample(subscriber, timeout)
        print(f"Subscriber received HelloWorld data for {language}.")
    except (pexpect.TIMEOUT, pexpect.EOF) as error:
        details = [f"{type(error).__name__}: no HelloWorld sample received."]
        if subscriber is not None:
            details.append(f"subscriber before: {subscriber.before}")
        if publisher is not None:
            details.append(f"publisher before: {publisher.before}")
        pytest.fail("\n".join(details), pytrace=False)
    finally:
        stop_reader.set()
        if publisher_reader:
            publisher_reader.join(timeout=2)
        subscriber_log.close()
        publisher_log.close()
        terminate(publisher)
        terminate(subscriber)
        subprocess.run(["docker", "rm", "-f", publisher_name, subscriber_name], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        subprocess.run(["docker", "network", "rm", network], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
