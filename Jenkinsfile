pipeline {
    agent {
        label 'docker'
    }

    options {
        disableConcurrentBuilds()
        timeout(time: 60, unit: 'MINUTES')
    }

    parameters {
        string(
            name: 'CONNEXT_VERSION',
            defaultValue: '7.7.0',
            description: 'Connext version used by the public base image and generated image tags.'
        )
        string(
            name: 'DOCKER_PLATFORM',
            defaultValue: 'linux/amd64',
            description: 'Single platform used for CI builds and tests.'
        )
        string(
            name: 'IMAGE_TAG_PREFIX',
            defaultValue: 'local',
            description: 'Local image tag prefix used by Jenkins.'
        )
        booleanParam(
            name: 'RUN_LANGUAGE_MATRIX',
            defaultValue: true,
            description: 'Build the shared SDK and test Runtime profiles: all, c, cpp, java, csharp, and python.'
        )
        booleanParam(
            name: 'RUN_RUNTIME_EXAMPLES',
            defaultValue: true,
            description: 'Run generated applications in the Runtime image. Requires the rti_license.dat Jenkins credential.'
        )
        booleanParam(
            name: 'KEEP_CI_IMAGES',
            defaultValue: false,
            description: 'Keep locally built CI images on the Jenkins agent after the run.'
        )
        string(
            name: 'MAX_RUNTIME_IMAGE_SIZE_MB',
            defaultValue: '0',
            description: 'Optional Runtime image size limit in MB. Use 0 to disable enforcement.'
        )
    }

    environment {
        DOCKER_BUILDKIT = '1'
    }

    stages {
        stage('CI') {
            steps {
                withCredentials([file(credentialsId: 'rti_license.dat', variable: 'RTI_LICENSE_FILE_HOST')]) {
                    sh '''
                        CI_LICENSE_FILE="$(mktemp)"
                        trap 'rm -f "$CI_LICENSE_FILE"' EXIT
                        cp "$RTI_LICENSE_FILE_HOST" "$CI_LICENSE_FILE"
                        chmod 0644 "$CI_LICENSE_FILE"

                        CONNEXT_VERSION="${CONNEXT_VERSION}" \
                        DOCKER_PLATFORM="${DOCKER_PLATFORM}" \
                        IMAGE_TAG_PREFIX="${IMAGE_TAG_PREFIX}" \
                        RUN_LANGUAGE_MATRIX="${RUN_LANGUAGE_MATRIX}" \
                        RUN_RUNTIME_EXAMPLES="${RUN_RUNTIME_EXAMPLES}" \
                        RTI_LICENSE_FILE_HOST="$CI_LICENSE_FILE" \
                        NO_CACHE=false \
                        KEEP_CI_IMAGES="${KEEP_CI_IMAGES}" \
                        MAX_RUNTIME_IMAGE_SIZE_MB="${MAX_RUNTIME_IMAGE_SIZE_MB}" \
                            ./resources/automation/ci/ci-run.sh
                    '''
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'reports/**/*', allowEmptyArchive: true
            junit testResults: 'reports/**/*.xml', allowEmptyResults: true
            deleteDir()
        }
    }
}
