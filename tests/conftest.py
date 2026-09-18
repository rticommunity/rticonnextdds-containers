"""Shared pytest options and dynamic test parameterization."""

import pytest


def pytest_addoption(parser):
    """Register Docker, Runtime, language, UI and reporting test options."""
    group = parser.getgroup("Connext container tests")
    group.addoption("--runtime-image")
    group.addoption("--language")
    group.addoption("--workdir")
    group.addoption("--license-file")
    group.addoption("--platform", default="")
    group.addoption("--timeout", type=int, default=60)
    group.addoption("--image")
    group.addoption("--rdp-client-image")
    group.addoption("--reports")


def pytest_generate_tests(metafunc):
    """Create one test case for the selected language and UI test mode."""
    if "language" in metafunc.fixturenames:
        language = metafunc.config.getoption("language")
        if not language:
            raise pytest.UsageError("--language is required")
        metafunc.parametrize("language", [language], ids=[f"HelloWorld pub/sub - {language}"])

    if "ui_mode" in metafunc.fixturenames:
        has_license = bool(metafunc.config.getoption("license_file"))
        mode = "rdp-and-admin-console" if has_license else "rdp-only"
        metafunc.parametrize("ui_mode", [mode], ids=[mode])