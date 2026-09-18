#!/usr/bin/env bash
set -Eeuo pipefail

language="${1:?usage: build-connext-example.sh <C|CPP98|CPP11|Java|CSharp|Python> [workdir]}"
workdir="${2:-/work}"

safe_language="$(printf "%s" "${language}" | tr '[:upper:]' '[:lower:]')"
build_dir="${workdir}/build/${safe_language}"
source_idl="${workdir}/HelloWorld.idl"

if [ ! -f "${source_idl}" ]; then
    printf "Missing IDL file: %s\n" "${source_idl}" >&2
    exit 1
fi

if command -v rtienv >/dev/null 2>&1; then
    eval "$(rtienv)"
fi

: "${CONNEXTDDS_ARCH:?CONNEXTDDS_ARCH is not set. Check rtienv and the Connext installation.}"

rm -rf "${build_dir}"
mkdir -p "${build_dir}"
cp "${source_idl}" "${build_dir}/HelloWorld.idl"
cd "${build_dir}"

set_publisher_payload() {
    case "${language}" in
        C)
            sed -i '/HelloWorldDataWriter_write/i\        DDS_String_replace(&instance->msg, "HelloWorld");' HelloWorld_publisher.c
            grep -F 'DDS_String_replace(&instance->msg, "HelloWorld");' HelloWorld_publisher.c >/dev/null
            ;;
        CPP98)
            sed -i '/typed_writer->write/i\        DDS_String_replace(&data->msg, "HelloWorld");' HelloWorld_publisher.cxx
            grep -F 'DDS_String_replace(&data->msg, "HelloWorld");' HelloWorld_publisher.cxx >/dev/null
            ;;
        CPP11)
            sed -i '/writer.write(data/i\            data.msg = "HelloWorld";' HelloWorld_publisher.cxx
            grep -F 'data.msg = "HelloWorld";' HelloWorld_publisher.cxx >/dev/null
            ;;
        Java)
            sed -i '/writer.write(data/i\            data.msg = "HelloWorld";' HelloWorldPublisher.java
            grep -F 'data.msg = "HelloWorld";' HelloWorldPublisher.java >/dev/null
            ;;
        CSharp)
            sed -i '/writer.Write(sample/i\            sample.msg = "HelloWorld";' HelloWorldPublisher.cs
            grep -F 'sample.msg = "HelloWorld";' HelloWorldPublisher.cs >/dev/null
            ;;
        Python)
            sed -i '/writer.write(sample/i\                sample.msg = "HelloWorld"' HelloWorld_publisher.py
            grep -F 'sample.msg = "HelloWorld"' HelloWorld_publisher.py >/dev/null
            ;;
    esac
}

configure_csharp_nuget_source() {
    cat > NuGet.Config <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <clear />
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" />
  </packageSources>
</configuration>
EOF
}

case "${language}" in
    C)
        rtiddsgen -ppDisable -language C -example "${CONNEXTDDS_ARCH}" HelloWorld.idl
        set_publisher_payload
        make -f "makefile_HelloWorld_${CONNEXTDDS_ARCH}" SHAREDLIB=1
        test -x "objs/${CONNEXTDDS_ARCH}/HelloWorld_publisher"
        ;;
    CPP98)
        rtiddsgen -ppDisable -language "C++98" -example "${CONNEXTDDS_ARCH}" HelloWorld.idl
        set_publisher_payload
        make -f "makefile_HelloWorld_${CONNEXTDDS_ARCH}" SHAREDLIB=1
        test -x "objs/${CONNEXTDDS_ARCH}/HelloWorld_publisher"
        ;;
    CPP11)
        rtiddsgen -ppDisable -language "C++11" -example "${CONNEXTDDS_ARCH}" HelloWorld.idl
        set_publisher_payload
        make -f "makefile_HelloWorld_${CONNEXTDDS_ARCH}" SHAREDLIB=1
        test -x "objs/${CONNEXTDDS_ARCH}/HelloWorld_publisher"
        ;;
    Java)
        rtiddsgen -ppDisable -language Java -example "${CONNEXTDDS_ARCH}" HelloWorld.idl
        set_publisher_payload
        make -f "makefile_HelloWorld_${CONNEXTDDS_ARCH}" SHAREDLIB=1
        ;;
    CSharp)
        rtiddsgen -ppDisable -language "C#" -example net10.0 HelloWorld.idl
        set_publisher_payload
        configure_csharp_nuget_source
        dotnet publish --configuration Release --output "${build_dir}/publish"
        test -f "${build_dir}/publish/HelloWorld.dll"
        ;;
    Python)
        rtiddsgen -ppDisable -language Python -example universal HelloWorld.idl
        set_publisher_payload
        test -f HelloWorld_publisher.py
        ;;
    *)
        printf "Unsupported generated example language: %s\n" "${language}" >&2
        exit 2
        ;;
esac

case "${language}" in
    C|CPP98|CPP11)
        ldd "objs/${CONNEXTDDS_ARCH}/HelloWorld_publisher" | grep 'libndds'
        ;;
esac
printf "Built HelloWorld example for %s in %s\n" "${language}" "${build_dir}"
