
sayErr() {
   local message="$*"
   message="${message%\\n}\n"
   printf "ERROR: %b" "$message" >&2
}

main() {
    sayErr "This is a bash library; it should only be sourced, not executed."
    return 2
}

# If executed instead of being sourced, call main
[[ "$0" != "$BASH_SOURCE" ]] || main "$@"
