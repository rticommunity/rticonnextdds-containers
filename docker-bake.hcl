variable "CONNEXT_VERSION" {
  default = "7.7.0"
}

variable "BASE_IMAGE" {
  default = "rticom/connext-base:7.7.0"
}

variable "DOCKER_PLATFORM" {
  default = "linux/amd64"
}

variable "IMAGE_TAG_PREFIX" {
  default = "local"
}

variable "IMAGE_TAG_SUFFIX" {
  default = ""
}

group "default" {
  targets = ["sdk", "runtime-all"]
}

group "all" {
  targets = ["sdk", "runtime-all", "runtime-c", "runtime-cpp", "runtime-java", "runtime-csharp", "runtime-python", "ui-tools"]
}

group "ui-test" {
  targets = ["ui-tools", "rdp-test-client"]
}

target "ui-tools" {
  context = "."
  dockerfile = "docker/connext-ui-tools/Dockerfile"
  platforms = ["linux/amd64"]
  tags = ["${IMAGE_TAG_PREFIX}/connext-ui-tools:${CONNEXT_VERSION}${IMAGE_TAG_SUFFIX != "" ? "-${IMAGE_TAG_SUFFIX}" : ""}"]
  args = {
    CONNEXT_VERSION = CONNEXT_VERSION
    CONNEXT_BASE_IMAGE = BASE_IMAGE
  }
}

target "rdp-test-client" {
  context = "."
  dockerfile = "tests/connext-rdp-test-client/rdp-test-client.Dockerfile"
  platforms = ["linux/amd64"]
  tags = ["${IMAGE_TAG_PREFIX}/connext-rdp-test-client:${CONNEXT_VERSION}${IMAGE_TAG_SUFFIX != "" ? "-${IMAGE_TAG_SUFFIX}" : ""}"]
}

target "sdk" {
  context = "."
  dockerfile = "docker/connext-sdk/Dockerfile"
  platforms = [DOCKER_PLATFORM]
  tags = ["${IMAGE_TAG_PREFIX}/connext-sdk:${CONNEXT_VERSION}${IMAGE_TAG_SUFFIX != "" ? "-${IMAGE_TAG_SUFFIX}" : ""}"]
  args = {
    BASE_IMAGE = BASE_IMAGE
    CONNEXT_VERSION = CONNEXT_VERSION
  }
}

target "runtime-all" {
  context = "."
  dockerfile = "docker/connext-runtime/Dockerfile"
  platforms = [DOCKER_PLATFORM]
  tags = ["${IMAGE_TAG_PREFIX}/connext-runtime:${CONNEXT_VERSION}${IMAGE_TAG_SUFFIX != "" ? "-${IMAGE_TAG_SUFFIX}" : ""}"]
  args = {
    BASE_IMAGE = BASE_IMAGE
    CONNEXT_VERSION = CONNEXT_VERSION
    CONNEXT_LANGUAGES = "all"
  }
}

target "runtime-c" {
  inherits = ["runtime-all"]
  tags = ["${IMAGE_TAG_PREFIX}/connext-c-runtime:${CONNEXT_VERSION}${IMAGE_TAG_SUFFIX != "" ? "-${IMAGE_TAG_SUFFIX}" : ""}"]
  args = {
    CONNEXT_LANGUAGES = "c"
  }
}

target "runtime-cpp" {
  inherits = ["runtime-all"]
  tags = ["${IMAGE_TAG_PREFIX}/connext-cpp-runtime:${CONNEXT_VERSION}${IMAGE_TAG_SUFFIX != "" ? "-${IMAGE_TAG_SUFFIX}" : ""}"]
  args = {
    CONNEXT_LANGUAGES = "cpp"
  }
}

target "runtime-java" {
  inherits = ["runtime-all"]
  tags = ["${IMAGE_TAG_PREFIX}/connext-java-runtime:${CONNEXT_VERSION}${IMAGE_TAG_SUFFIX != "" ? "-${IMAGE_TAG_SUFFIX}" : ""}"]
  args = {
    CONNEXT_LANGUAGES = "java"
  }
}

target "runtime-csharp" {
  inherits = ["runtime-all"]
  tags = ["${IMAGE_TAG_PREFIX}/connext-csharp-runtime:${CONNEXT_VERSION}${IMAGE_TAG_SUFFIX != "" ? "-${IMAGE_TAG_SUFFIX}" : ""}"]
  args = {
    CONNEXT_LANGUAGES = "csharp"
  }
}

target "runtime-python" {
  inherits = ["runtime-all"]
  tags = ["${IMAGE_TAG_PREFIX}/connext-python-runtime:${CONNEXT_VERSION}${IMAGE_TAG_SUFFIX != "" ? "-${IMAGE_TAG_SUFFIX}" : ""}"]
  args = {
    CONNEXT_LANGUAGES = "python"
  }
}
