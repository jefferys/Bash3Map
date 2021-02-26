#!/usr/bin/env bash

# Concatenate parameters with IFS (space) and print to STDERR
function sayErr() {
   local message="$*"
   message="${message%\\n}\n"
   printf "ERROR: %b" "$message" >&2
}

# Shellspec executable path is the first found of:
#    1. An executable specified in environmental variable "$SHELLSPEC_HOME"
#    2. A locally installed shellpec executable in test/lib/shellspec/shellspec
#    3. A global executable "shellspec" (on path)
getShellspecExec() {
    if [[ -f "$SHELLSPEC_HOME/shellspec" ]]; then
        shellspecCommand="$SHELLSPEC_HOME/shellspec"
    elif [[ -f "lib/shellspec/shellspec" ]]; then
        shellspecCommand="lib/shellspec/shellspec"
    elif type shellspec >/dev/null 2>&1; then
        shellspecCommand="shellspec"
    else sayErr "Can't find the shellspec executable. You can:\n" \
            "1. Specify its home directory with the env variable" \
            "\"SHELLSPEC_HOME\";\n" \
            "2. Install shellspec globally.\n" \
            "See: https://github.com/shellspec/shellspec#installation\n"
            "3. Put a copy of the shellspec runtime directory as" \
            "\"shellspec\" into \"test/lib/\".\n"
        return 1
    fi
    __="$shellspecCommand"
}

main() {
    
    getShellspecExec || return $!
    local shellspecCommand="$__"
    
    "$shellspecCommand" --shell "$(which bash)" "$@"
}

# Allow source as well as run
[[ "$0" == "$BASH_SOURCE" ]] && main "$@"