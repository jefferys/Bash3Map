# Bash3Map

## Introduction

Implementation of a key-value dictionary in bash 3.1 (uses `printf -v`).

Single file, function-only implementation of key-value dictionary in bash 3. Useful mainly due to Apple's fear of GPL 3 and refusal to update Bash. Source the `lib/bash3map.sh` file from a script that uses it, or cut and paste all functions from it into your code. Functions should be called without subshells; they return values in the global `$__` which should be be copied for use immediately. Keys are unique. Keys and values can be essentially any strings, including the empty string `""`but may not contain the non-printing characters `\000`, `\036` or `\037`.

The implementation involves a linear search through the keys, so performance will not be very good for a large numbers of keys. (Being forced to use Bash 3 is a pain).

## Usage

Basic usage looks like:

```
source "bash3map.sh"

mapSet myMap "a Key" "a value"
mapGet myMap "a Key"
[[ "$__" == "a value" ]] || echo "Oops"

mapHas myMap "a Key"
[[ "$__" == "true" ]]    || echo "Oops"

mapHasValue myMap "a value"
[[ "$__" == "true" ]]    || echo "Oops"

mapGetKeyFor myMap "a value"
[[ "$__" == "a Key" ]]   || echo "Oops"

mapDelete myMap "a Key"
mapHas myMap "a Key"
[[ "$__" == "false" ]]   || echo "Oops"
```

The `mapSet` and `mapDelete` functions return the previous value of the key.

```
unset myMap
mapSet myMap "a Key" "a value"
[[ "$__" == "" ]]            || echo "Oops"

mapSet myMap "a Key" "a new value"
[[ "$__" == "a value" ]]     || echo "Oops"

mapDelete myMap "a Key"
[[ "$__" == "a new value" ]] || echo "Oops"

mapDelete myMap "a Key"
[[ "$__" == "" ]]            || echo "Oops"
```

Trying to query a non-existing key or value is not an error; it always returns the empty string "". Use `mapHas` or `mapHasValue` to identify genuine missing keys or values. Empty strings are valid keys or values.

```
unset myMap
mapSet myMap "" ""

mapGet myMap ""
[[ "$__" == "" ]]      || echo "Oops"
mapHas myMap ""
[[ "$__" == "true" ]]  || echo "Oops"

mapGetKeyFor myMap ""
[[ "$__" == "" ]]      || echo "Oops"
mapHasValue myMap ""
[[ "$__" == "true" ]]  || echo "Oops"

mapGet myMap "noSuchKey"
[[ "$__" == "" ]]      || echo "Oops"
mapHas myMap "noSuchKey"
[[ "$__" == "false" ]] || echo "Oops"

mapGetKeyFor myMap "noSuchKey"
[[ "$__" == "" ]]      || echo "Oops"
mapHasValue myMap "noSuchKey"
[[ "$__" == "false" ]] || echo "Oops"
```

The map keys are unique; setting an existing key changes its value. Values can be repeated, so getting the key for a value with `getKeyFor` is only guaranteed to return **one** of the keys, not necessarily the same one as retrieved last time, nor the first or the last one set.

## Functions

All functions return 0 for success, 1 for parameter errors, and non-0 for all other errors.

Most functions pass back a value; they do so using a global variable `__`. This should be assigned to a variable by the caller as soon as possible after the call to avoid it being over-written by another function call, e.g. `myAnswer=${__}`

* **mapSet** *mapName* *key* *value* - Adds or updates a key-value pair.
    + Passes back the previous value, or the empty string "" if adding a new key.
* **mapHas** *mapName* *key* - Checks for the existence of the key.
    + Passes back `"true"` if the key is in the map, `"false"` otherwise.
* **mapGet** *mapName* *key* - Returns the value associated with the key, if any.
    + Passes back the empty string `""` if the key was not found.
* **mapDelete** *mapName* *key* - Deletes the key and its associated value
    + Passes back the deleted value, or the empty string "" if the key was not found.
* **mapHasValue** *mapName* *value* - Checks if any key has the given value.
    + Passes back `"true"` if the given value is associated with one or more keys in the map, `"false"` otherwise.
* **mapGetKeyFor** *mapName* *value* - Returns a key associated with the given value, if any.
    + Passes back the empty string `""` if the given value is not associated with any key in the map. Note that if the same value is associated with more than one key, it is not defined which key will be chosen to return.
* **sayErr** [*STR*]* - Prints an error message built from the provided (0 or more) strings
    + The string "ERROR:" will be prefixed to the provided parameter list and then the parameters will be concatenated into a message using IFS. If there is no terminal `\n` on the message, one will be added. If there is one (or more), they will left as is. This message will then be printed to STDERR.

### Parameters

* **`MAP_NAME`** A variable name identifying the map (unquoted bare name). Should not be otherwise used by the caller (don't modify its contents). Any number of maps may be simultaneously created with different names; this act like object instances.
* **`KEY`** - The key part of a key-value pair, as a string.
* **`VALUE`** - The value part of a key-value pair, as a string.
* `[`**`STR`**`]*` - 0 or more space separated strings.

Keys and values may be essentially any string, including empty strings, but they may not contain the non-printing characters  `\000`, `\036` or `\037`.


## Testing

Tests are written using [shellspec (0.28.1)](https://github.com/shellspec/shellspec), the executable must be available either on the `$PATH`, identified via the ENV `$SHELLSPEC_HOME`, or locally installed as `test/lib/shellspec`. Tests are run by changing to the test directory and running:

```  
./test.sh [shellspec opt/arg]
```

Provided options are passed through to shellspec to control how tests are run. By default all tests must be named `*_spec.sh` and be in the `test/spec` directory.

