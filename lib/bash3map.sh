# bash3map.sh
# A library implementing hashes for bash 3
#
# Implementation is as a string that looks like
#    | keyA - valA | key2 - val2 |
# where | is the "record" character \036 and - is the "field" character \037

sayErr() {
   local message="$*"
   message="${message%\\n}\n"
   printf "ERROR: %b" "$message" >&2
}

# Returns "true" if key is in map, "false" otherwise 
mapHas() {
    local mapVar="$1"
    local key="$2"

    local map="${!mapVar}"
    local fsep=$'\037'   # k/v separator is unit separator char.
    local rsep=$'\036'   # kv/kv separator is record separator char.
    local found="false"
    
    if [[ -n "$map" ]]; then
        # Not handling an empty map
        local aft="${map#*"${rsep}${key}${fsep}"}"
    
        if [[ "$aft" != "$map" ]]; then
            # Key was found
            found="true"
        fi
    fi
    
    __="$found"
}

# Returns "true" if value is in map, "false" otherwise 
mapHasValue() {
    local mapVar="$1"
    local value="$2"

    local map="${!mapVar}"
    local fsep=$'\037'   # k/v separator is unit separator char.
    local rsep=$'\036'   # kv/kv separator is record separator char.
    local found="false"
    
    if [[ -n "$map" ]]; then
        # Not handling an empty map
        local aft="${map#*"${fsep}${value}${rsep}"}"
    
        if [[ "$aft" != "$map" ]]; then
            # Value was found
            found="true"
        fi
    fi
    
    __="$found"
}

mapDelete() {
    local mapVar="$1"  # Name of map (variable) used by caller
    local key="$2"
    
    local fsep=$'\037'   # k/v separator is unit separator char.
    local rsep=$'\036'   # kv/kv separator is record separator char.
    local map="${!mapVar}"
    local oldVal=""

    # Don't change an empty map
    if [[ -n "$map" ]]; then

        # Get map sub-string starting with key's value, or the whole string if
        # "key" is not found
        local aft="${map#*"${rsep}${key}${fsep}"}"

        # Don't change map if key not found
        if [[ "$aft" != "$map" ]]; then
            # Handle key update by split/trim/join
            oldVal="${aft%%${rsep}*}"
            local fore="${map%%"${rsep}${key}${fsep}"*}"
            aft="${aft#*${rsep}}"
            map="${fore}${rsep}${aft}"
        fi
        
        # Update the external map
        declare -g ${mapVar}="$map"
    fi
    
    __="$oldVal"
}

# Add/change a key/value in a map, initilizinng the map if needed.
mapSet() {
    local mapVar="$1"  # Name of map (variable) used by caller
    local key="$2"
    local value="$3"
    
    local fsep=$'\037'   # k/v separator is unit separator char.
    local rsep=$'\036'   # kv/kv separator is record separator char.
    local map="${!mapVar}"
    local oldVal=""
    
    if [[ -z "$map" ]]; then
        # Handling an empty map
        map="${rsep}${key}${fsep}${value}${rsep}"
    else
        # Get map sub-string starting with key's value, or the whole string if
        # "key" is not found
        local aft="${map#*"${rsep}${key}${fsep}"}"

        if [[ "$aft" == "$map" ]]; then
            # Handling key not found by appending new key/value
            map="${map}${key}${fsep}${value}${rsep}"
            
        else
            # Handle key update by split/trim/join
            oldVal="${aft%%${rsep}*}"
            local fore="${map%%"${rsep}${key}${fsep}"*}"
            aft="${aft#*${rsep}}"
            map="${fore}${rsep}${key}${fsep}${value}${rsep}${aft}"
        fi
    fi
    
    # Update the external map
    declare -g ${mapVar}="$map"
    __="$oldVal"
}

mapGet() {
    local mapVar="$1"
    local key="$2"

    local map="${!mapVar}"
    local fsep=$'\037'   # k/v separator is unit separator char.
    local rsep=$'\036'   # kv/kv separator is record separator char.
    local val=""
    
    if [[ -n "$map" ]]; then
        # Not handling an empty map
        local aft="${map#*"${rsep}${key}${fsep}"}"

        if [[ "$aft" != "$map" ]]; then
            # Key was found
            val="${aft%%${rsep}*}"
        fi
    fi
    
    __="$val"
}

mapGetKeyFor() {
    local mapVar="$1"
    local value="$2"

    local map="${!mapVar}"
    local fsep=$'\037'   # k/v separator is unit separator char.
    local rsep=$'\036'   # kv/kv separator is record separator char.
    local key=""
    
    if [[ -n "$map" ]]; then
        # Not handling an empty map
        local fore="${map%"${fsep}${value}${rsep}"*}"

        if [[ "$aft" != "$map" ]]; then
            # Key was found
            key="${fore##*${rsep}}"
        fi
    fi
    
    __="$key"
}

main() {
    sayErr "This is a bash library; it should only be sourced, not executed."
    return 2
}

# If executed instead of being sourced, call main
[[ "$0" != "$BASH_SOURCE" ]] || main "$@"
