#!/usr/bin/env bash

normalize_connext_languages() {
    local raw="${1:-all}"
    local token
    local normalized=()

    raw="${raw//,/ }"
    for token in ${raw}; do
        token="$(printf "%s" "${token}" | tr '[:upper:]' '[:lower:]')"
        case "${token}" in
            all)
                normalized+=(c cpp java csharp python)
                ;;
            c)
                normalized+=(c)
                ;;
            cpp|cxx|c++|cpp98|cpp11|c++98|c++11)
                normalized+=(cpp)
                ;;
            java)
                normalized+=(java)
                ;;
            csharp|c#|dotnet|cs)
                normalized+=(csharp)
                ;;
            python|py)
                normalized+=(python)
                ;;
            "")
                ;;
            *)
                printf "Unsupported language profile: %s\n" "${token}" >&2
                return 2
                ;;
        esac
    done

    [ "${#normalized[@]}" -gt 0 ] || return 2
    printf "%s\n" "${normalized[@]}" | awk '!seen[$0]++'
}

connext_example_languages() {
    local profile="${1:-all}"
    local language
    local languages
    languages="$(normalize_connext_languages "${profile}")" || return 2

    while IFS= read -r language; do
        case "${language}" in
            c)
                printf "C\n"
                ;;
            cpp)
                printf "CPP98\n"
                printf "CPP11\n"
                ;;
            java)
                printf "Java\n"
                ;;
            csharp)
                printf "CSharp\n"
                ;;
            python)
                printf "Python\n"
                ;;
        esac
    done <<< "${languages}"
}
