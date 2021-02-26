# Bash3Map

## Introduction

Implementation of a key-value dictionary in bash 3.

Single file, function-only implementation of key-value dictionary in bash 3. Needed due to Apple's fear of GPL 3 and refusal to update Bash. Source this `bash3map.sh` file from a script that uses it, or cut and paste functions into your code. All functions should be called without subshells; they return values in the global $__ which should be be copied for use immediately.

## Usage
```
source "bash3map.sh"
myMap=""

setMap myMap "aKey" "a value"
getMap myMap "aKey"
[[ "$__" == "a value" ]] || echo "Oops"

setMap myMap "bKey" 42
getMap myMap "bKey"
[[ $__ -gt 41 && $__ -lt 43 ]] || echo "Oops"

```

## Description

### setMap

### getMap

## Testing

Tests are written using [shellspec (0.28.1)](https://github.com/shellspec/shellspec), this must be available either globally or locally installed into test/lib/shellspec. Tests are run by changing to the test directory and running:

```  
./test.sh
```

