#!/bin/sh

# Only use bold formatting if stdout is an interactive terminal
if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
    BOLD=$(tput bold 2>/dev/null || true)
    RESET=$(tput sgr0 2>/dev/null || true)
else
    BOLD=""
    RESET=""
fi

usage() {
    cat << EOF
Gets a list of ${BOLD}all users${RESET} based on usernames in /etc/passwd

Usage: $(basename -- "$0") [OPTIONS]...

Options:
    -h, --help      Print help menu
    -o <filepath>   Specify an output file (Optional)

Examples:
    $(basename -- "$0")
    $(basename -- "$0") -o user_list.txt

Authors:
    L3prech4un - https://github.com/L3prech4un
EOF
}

get_users() {
    awk -F':' '
    BEGIN {
        printf "%-20s %-10s %-8s %-8s %-28s %-25s %s\n", "Username", "Password", "UID", "GID", "GECOS", "Home Directory", "Login Shell"
    }
    {
        printf "%-20s %-10s %-8s %-8s %-28s %-25s %s\n", $1, $2, $3, $4, $5, $6, $7
    }' /etc/passwd
}

main() {
    filepath=""

    # Parse arguments using POSIX while + case
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -o)
                if [ "$#" -lt 2 ] || [ -z "$2" ]; then
                    printf 'Error: -o requires a filepath argument.\n' >&2
                    exit 1
                fi
                filepath="$2"
                shift 2
                ;;
            *)
                printf 'Error: Unknown option "%s"\n' "$1" >&2
                usage >&2
                exit 1
                ;;
        esac
    done

    # Case 1: No output file specified -> print to terminal
    if [ -z "$filepath" ]; then
        get_users | sed "1s/.*/${BOLD}&${RESET}/"
        exit 0
    fi

    # Case 2: Output file specified -> validate path strictly
    case "$filepath" in
        */)
            printf 'Error: "%s" is a directory path, not a file.\n' "$filepath" >&2
            exit 1
            ;;
    esac

    if [ -d "$filepath" ]; then
        printf 'Error: "%s" already exists as a directory.\n' "$filepath" >&2
        exit 1
    fi

    if [ -e "$filepath" ]; then
        if [ ! -w "$filepath" ]; then
            printf 'Error: File "%s" exists but is not writable.\n' "$filepath" >&2
            exit 1
        fi
    else
        parent_dir=$(dirname -- "$filepath")
        if [ ! -d "$parent_dir" ] || [ ! -w "$parent_dir" ]; then
            printf 'Error: Parent directory "%s" does not exist or is not writable.\n' "$parent_dir" >&2
            exit 1
        fi
    fi

    # Write clean, unformatted text to the file
    get_users > "$filepath"
}

main "$@"

