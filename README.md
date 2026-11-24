# GetUsers
Simple utility script for checking the users on Linux and nicely formatting /etc/passwd.
Gets a list of ${BOLD}all users${RESET} based on usernames in /etc/passwd

## Usage:
    $(basename -- "$0") [OPTIONS]...

## Options:
    -h, --help      Print help menu
    -o <filepath>   Specify an output file (Optional)

## Examples:
    $(basename -- "$0")
    $(basename -- "$0") -o user_list.txt

## Authors:
L3prech4un - https://github.com/L3prech4un
