# Shellspec tests for bash3map.sh.

Describe "Script bash3map.sh"
  It "Exits with error if executed"
    wantErr="ERROR: This is a bash library; it should only be sourced, not executed."
    When run script "lib/bash3map.sh"
    The error should equal "$wantErr"
    The status should equal 2
  End
End

Describe "Library bash3map.sh"
  Include "./lib/bash3map.sh"

  Describe "sayErr()"
    It "Prints parameter to STDERR"
      When call sayErr 'msg'
      The entire error should equal $'ERROR: msg\n'
      The status should equal 0
    End
    It "Concatenates parameters using spaces"
      When call sayErr 'some param' 'another param'
      The entire error should equal $'ERROR: some param another param\n'
      The status should equal 0
    End
    It "Removes one return, if only one"
      When call sayErr 'some param' 'another param\n'
      The entire error should equal $'ERROR: some param another param\n'
      The status should equal 0
    End
    It "Leaves extra returns if more than one"
      When call sayErr 'some param' 'another param\n\n\n'
      The entire error should equal $'ERROR: some param another param\n\n\n'
      The status should equal 0
    End
  End   # sayErr()
  
  Describe "Map operations with various keys and values"
     
    Parameters
      # key         # old value   # new value
      "aKey"        "aValue"      "bValue"
      "a Key"       "a Value"     "b value"
      ""            "a Value"     ""
      ""            ""            "a value"
      42            123           0
      "aKey"        "l1\nl2\nl3"  "\$\\-_"
      "l1\nl2\nl3"  "l4\nl5\nl6"  "l7\nl8\nl9"
      "K\$\\-_\""   "V1\$\\-_'"   "V2\$\\-_\|"
    End

    Describe "on an empty map"
      
      Describe "mapGet()"
        It "Returns the empty string leaving map variable undefined"
          unset myMap
          When call mapGet myMap "$1"
          The variable __ should equal ""
          The variable myMap should be undefined
        End
      End

      Describe "mapGetKeyFor()"
        It "Returns the empty string leaving map variable undefined"
          unset myMap
          When call mapGetKeyFor myMap "$2"
          The variable __ should equal ""
          The variable myMap should be undefined
        End
      End
      
      Describe "mapSet()"
        It "Creates a map variable"
          unset myMap
          When call mapSet myMap "$1" "$2"
          The variable myMap should be defined
        End
        It "Returns an empty string as the previous value"
          unset myMap
          When call mapSet myMap "$1" "$2"
          The variable __ should equal ""
        End
        It "Can retrieve a newly set key-value"
          unset myMap
          mapSet myMap "$1" "$2"
          When call mapGet myMap "$1"
          The variable __ should equal "$2"
        End
      End
      
      Describe "mapDelete()"
        It "Does not create a new map variable"
          unset myMap
          When call mapDelete myMap "$1"
          The variable myMap should not be defined
        End
        It "Returns an empty string as the previous value"
          unset myMap
          When call mapDelete myMap "$1"
          The variable __ should equal ""
        End
      End

      Describe "mapHas()"
        It "Returns false leaving map undefined"
          unset myMap
          When call mapHas myMap "$1"
          The variable __ should equal "false"
          The variable myMap should be undefined
        End
      End

      Describe "mapHasValue()"
        It "Returns false leaving map undefined"
          unset myMap
          When call mapHas myMapValue "$2"
          The variable __ should equal "false"
          The variable myMap should be undefined
        End
      End
    End   # No map
  
    Describe "on a map with one key-value"
    
      initTargetMap() {
        unset targetMap
        mapSet targetMap "$1" "$2"
      }
  
      Describe "Key/Value does not exist"
        Describe "mapGet()"
          It "Returns the empty string when k=|$1| without changing the map"
            initTargetMap "xKey" "xValue"
            myMap="$targetMap"
            
            When call mapGet myMap "$1"
            The variable __ should equal ""
            The variable myMap should equal "$targetMap"
          End
        End
        
        Describe "mapGetKeyFor()"
          It "Returns the empty string if no v=|$2| without changing the map"
            initTargetMap "xKey" "xValue"
            myMap="$targetMap"
            
            When call mapGetKeyFor myMap "$2"
            The variable __ should equal ""
            The variable myMap should equal "$targetMap"
          End
        End
        
        Describe "mapSet()"
          It "Returns the empty string when k=|$1| while changes the map"
            initTargetMap "xKey" "xValue"
            myMap="$targetMap"
            
            When call mapSet myMap "$1" "$2"
            The variable __ should equal ""
            The variable myMap should not equal "$targetMap"
          End
          It "Can retrieve a newly set k=|$1|"
            initTargetMap "xKey" "xValue"
            myMap="$targetMap"
            mapSet myMap "$1" "$2"
            
            When call mapGet myMap "$1"
            The variable __ should equal "$2"
          End
        End
  
        Describe "mapDelete()"
          It "Returns the empty string when k=|$1| without changing the map"
            initTargetMap "xKey" "xValue"
            myMap="$targetMap"
  
            When call mapDelete myMap "$1"
            The variable __ should equal ""
            The variable myMap should equal "$targetMap"
          End
        End
        
        Describe "mapHas()"
          It "Returns false when k=|$1| without changing the map"
            initTargetMap "xKey" "xValue"
            myMap="$targetMap"
            
            When call mapHas myMap "$1"
            The variable __ should equal "false"
            The variable myMap should equal "$targetMap"
          End
        End
        
        Describe "mapHasValue()"
          It "Returns false when value=|$2| without changing the map"
            initTargetMap "xKey" "xValue"
            myMap="$targetMap"
            
            When call mapHasValue myMap "$2"
            The variable __ should equal "false"
            The variable myMap should equal "$targetMap"
          End
        End
      End
      
      Describe "Key/Value exists"
        Describe "mapGet()"
          It "Returns value=|$2| for key=|$1| without changing the map"
            initTargetMap "$1" "$2"
            myMap="$targetMap"
  
            When call mapGet myMap "$1"
            The variable __ should equal "$2"
            The variable myMap should equal "$targetMap"
          End
        End

        Describe "mapGetKeyFor()"
          It "Returns key=|$1| for value=|$2| without changing the map"
            initTargetMap "$1" "$2"
            myMap="$targetMap"
  
            When call mapGetKeyFor myMap "$2"
            The variable __ should equal "$1"
            The variable myMap should equal "$targetMap"
          End
        End
        
        Describe "mapSet()"
          Describe "Can set key to new value, returning the old"
            It "Setting k=|$1| v=|$3| returns old v=|$2|"
              initTargetMap "$1" "$2"
              myMap="$targetMap"
    
              When call mapSet myMap "$1" "$3"
              The variable __ should equal "$2"
              The variable myMap should not equal "$targetMap"
            End
            It "The new value k=|$1| v=|$3| can be retrieved"
              initTargetMap "$1" "$2"
              myMap="$targetMap"
              mapSet myMap "$1" "$3"
              
              When call mapGet myMap "$1"
              The variable __ should equal "$3"
            End
          End
          
          Describe "Can set key to same value, returning it"
            It "Setting k=|$1| to old value $2 returns it; map is unchaged"
              initTargetMap "$1" "$2"
              myMap="$targetMap"
    
              When call mapSet myMap "$1" "$2"
              The variable __ should equal "$2"
              The variable myMap should equal "$targetMap"
            End
            It "The new value k=|$1| v=|$3| can be retrieved"
              initTargetMap "$1" "$2"
              myMap="$targetMap"
              mapSet myMap "$1" "$2"
              
              When call mapGet myMap "$1"
              The variable __ should equal "$2"
            End

            It "Changing k=|$1| to new value |$3| and then to old value |$2| changes and then restores map"
              initTargetMap "$1" "$2"
              myMap="$targetMap"
              mapSet myMap "$1" "$3"
              changedMap="$myMap"
  
              When call mapSet myMap "$1" "$2"
              The variable myMap should not equal "$changedMap"
              The variable myMap should equal "$targetMap"
            End
          End
        End
        
        Describe "mapDelete()"
          It "Returns its v=|$2| when deleting k=|$1|"
            initTargetMap "$1" "$2"
            myMap="$targetMap"

            When call mapDelete myMap "$1"
            The variable __ should equal "$2"
            The variable myMap should not equal "$targetMap"
          End
          It "Key k=|$1| was deleted; getting it returns empty"
            initTargetMap "$1" "$2"
            myMap="$targetMap"

            mapDelete myMap "$1"
            When call mapGet myMap "$1"
            The variable __ should equal ""
          End
        End
        
        Describe "mapHas()"
          It "Returns true if finds key=|$1| without changing the map"
            initTargetMap "$1" "$2"
            myMap="$targetMap"
  
            When call mapHas myMap "$1"
            The variable __ should equal "true"
            The variable myMap should equal "$targetMap"
          End
        End

        Describe "mapHasValue()"
          It "Returns true if finds value=|$2| without changing the map"
            initTargetMap "$1" "$2"
            myMap="$targetMap"
  
            When call mapHasValue myMap "$2"
            The variable __ should equal "true"
            The variable myMap should equal "$targetMap"
          End
        End

      End
    End   # One KV map

    Describe "on a map with multiple key-values"
    
      initTargetMapStart() {
        key="$1"; value="$2"
        unset targetMap
        mapSet targetMap "$key" "$value"
        mapSet targetMap "newKey"   "newValue"
        mapSet targetMap "newerKey" "newerValue"
      }
      initTargetMapMiddle() {
        key="$1"; value="$2"
        unset targetMap
        mapSet targetMap "newKey"   "newValue"
        mapSet targetMap "$key" "$value"
        mapSet targetMap "newerKey" "newerValue"
      }
      initTargetMapEnd() {
        key="$1"; value="$2"
        unset targetMap
        mapSet targetMap "newKey"   "newValue"
        mapSet targetMap "newerKey" "newerValue"
        mapSet targetMap "$key" "$value"
      }
  
      Describe "Key does not exist"
        Describe "mapGet()"
          It "Returns the empty string when k=|$1| without changing the map"
            initTargetMapMiddle "xKey" "xValue"
            myMap="$targetMap"
            
            When call mapGet myMap "$1"
            The variable __ should equal ""
            The variable myMap should equal "$targetMap"
          End
        End
        
        Describe "mapSet()"
          It "Returns the empty string when k=|$1| while changes the map"
            initTargetMapStart "xKey" "xValue"
            myMap="$targetMap"
            
            When call mapSet myMap "$1" "$3"
            The variable __ should equal ""
            The variable myMap should not equal "$targetMap"
          End
        End
  
        Describe "mapDelete()"
          It "Returns the empty string when k=|$1| without changing the map"
            initTargetMapEnd "xKey" "xValue"
            myMap="$targetMap"
  
            When call mapDelete myMap "$1"
            The variable __ should equal ""
            The variable myMap should equal "$targetMap"
          End
        End
        
        Describe "mapHas()"
          It "Returns false when k=|$1| not found without changing the map"
            initTargetMapMiddle "xKey" "xValue"
            myMap="$targetMap"
            
            When call mapHas myMap "$1"
            The variable __ should equal "false"
            The variable myMap should equal "$targetMap"
          End
        End

        Describe "mapHasValue()"
          It "Returns false when value=|$2| not found without changing the map"
            initTargetMapMiddle "xKey" "xValue"
            myMap="$targetMap"
            
            When call mapHasValue myMap "$2"
            The variable __ should equal "false"
            The variable myMap should equal "$targetMap"
          End
        End
      End

      Describe "Key is first in map"
        Describe "mapGet()"
          It "Returns key=|$1| value=|$2| without changing the map"
            initTargetMapStart "$1" "$2"
            myMap="$targetMap"
  
            When call mapGet myMap "$1"
            The variable __ should equal "$2"
            The variable myMap should equal "$targetMap"
          End
        End

        Describe "mapGetKeyFor()"
          It "Returns key=|$1| for value=|$2| without changing the map"
            initTargetMapStart "$1" "$2"
            myMap="$targetMap"
  
            When call mapGetKeyFor myMap "$2"
            The variable __ should equal "$1"
            The variable myMap should equal "$targetMap"
          End
        End

        Describe "mapSet()"
          Describe "Can set key to new value, returning the old"
            It "Setting k=|$1| v=|$3| returns old v=|$2|"
              initTargetMapStart "$1" "$2"
              myMap="$targetMap"
    
              When call mapSet myMap "$1" "$3"
              The variable __ should equal "$2"
              The variable myMap should not equal "$targetMap"
            End
            It "The new value k=|$1| v=|$3| can be retrieved"
              initTargetMapStart "$1" "$2"
              myMap="$targetMap"
              mapSet myMap "$1" "$3"
              
              When call mapGet myMap "$1"
              The variable __ should equal "$3"
            End
          End
          
          Describe "Can set key to same value, returning it"
            It "Setting k=|$1| to old value $2 returns it; map is unchaged"
              initTargetMapStart "$1" "$2"
              myMap="$targetMap"
    
              When call mapSet myMap "$1" "$2"
              The variable __ should equal "$2"
              The variable myMap should equal "$targetMap"
            End
            It "Changing k=|$1| to new value |$3| and then to old value |$2| changes and then restores map"
              initTargetMapStart "$1" "$2"
              myMap="$targetMap"
              mapSet myMap "$1" "$3"
              changedMap="$myMap"
  
              When call mapSet myMap "$1" "$2"
              The variable myMap should not equal "$changedMap"
              The variable myMap should equal "$targetMap"
            End
          End
        End
        
        Describe "mapDelete()"
          It "Returns its v=|$2| when deleting k=|$1|"
            initTargetMapStart "$1" "$2"
            myMap="$targetMap"

            When call mapDelete myMap "$1"
            The variable __ should equal "$2"
            The variable myMap should not equal "$targetMap"
          End
          It "Key k=|$1| was deleted; getting it returns empty"
            initTargetMapStart "$1" "$2"
            myMap="$targetMap"

            mapDelete myMap "$1"
            When call mapGet myMap "$1"
            The variable __ should equal ""
          End
        End

        Describe "mapHas()"
          It "Returns true key=|$1| is found without changing the map"
            initTargetMapStart "$1" "$2"
            myMap="$targetMap"
  
            When call mapHas myMap "$1"
            The variable __ should equal "true"
            The variable myMap should equal "$targetMap"
          End
        End
        
        Describe "mapHasValue()"
          It "Returns true if value=|$2| is found without changing the map"
            initTargetMapStart "$1" "$2"
            myMap="$targetMap"
  
            When call mapHasValue myMap "$2"
            The variable __ should equal "true"
            The variable myMap should equal "$targetMap"
          End
        End
      End

      Describe "Key is in the middle of the map"
        Describe "mapGet()"
          It "Returns key=|$1| value=|$2| without changing the map"
            initTargetMapMiddle "$1" "$2"
            myMap="$targetMap"
  
            When call mapGet myMap "$1"
            The variable __ should equal "$2"
            The variable myMap should equal "$targetMap"
          End
        End
        
        Describe "mapGetKeyFor()"
          It "Returns key=|$1| for value=|$2| without changing the map"
            initTargetMapMiddle "$1" "$2"
            myMap="$targetMap"
  
            When call mapGetKeyFor myMap "$2"
            The variable __ should equal "$1"
            The variable myMap should equal "$targetMap"
          End
        End

        Describe "mapSet()"
          Describe "Can set key to new value, returning the old"
            It "Setting k=|$1| v=|$3| returns old v=|$2|"
              initTargetMapMiddle "$1" "$2"
              myMap="$targetMap"
    
              When call mapSet myMap "$1" "$3"
              The variable __ should equal "$2"
              The variable myMap should not equal "$targetMap"
            End
            It "The new value k=|$1| v=|$3| can be retrieved"
              initTargetMapMiddle "$1" "$2"
              myMap="$targetMap"
              mapSet myMap "$1" "$3"
              
              When call mapGet myMap "$1"
              The variable __ should equal "$3"
            End
          End
          
          Describe "Can set key to same value, returning it"
            It "Setting k=|$1| to old value $2 returns it; map is unchaged"
              initTargetMapMiddle "$1" "$2"
              myMap="$targetMap"
    
              When call mapSet myMap "$1" "$2"
              The variable __ should equal "$2"
              The variable myMap should equal "$targetMap"
            End
            It "Changing k=|$1| to new value |$3| and then to old value |$2| changes and then restores map"
              initTargetMapMiddle "$1" "$2"
              myMap="$targetMap"
              mapSet myMap "$1" "$3"
              changedMap="$myMap"
  
              When call mapSet myMap "$1" "$2"
              The variable myMap should not equal "$changedMap"
              The variable myMap should equal "$targetMap"
            End
          End
        End
        
        Describe "mapDelete()"
          It "Returns its v=|$2| when deleting k=|$1|"
            initTargetMapMiddle "$1" "$2"
            myMap="$targetMap"

            When call mapDelete myMap "$1"
            The variable __ should equal "$2"
            The variable myMap should not equal "$targetMap"
          End
          It "Key k=|$1| was deleted; getting it returns empty"
            initTargetMapMiddle "$1" "$2"
            myMap="$targetMap"

            mapDelete myMap "$1"
            When call mapGet myMap "$1"
            The variable __ should equal ""
          End
        End
        
        Describe "mapHas()"
          It "Returns true key=|$1| is found without changing the map"
            initTargetMapMiddle "$1" "$2"
            myMap="$targetMap"
  
            When call mapHas myMap "$1"
            The variable __ should equal "true"
            The variable myMap should equal "$targetMap"
          End
        End
        
        Describe "mapHasValue()"
          It "Returns true if value=|$2| is found without changing the map"
            initTargetMapMiddle "$1" "$2"
            myMap="$targetMap"
  
            When call mapHasValue myMap "$2"
            The variable __ should equal "true"
            The variable myMap should equal "$targetMap"
          End
        End
      End

      Describe "Key is last in map"
        Describe "mapGet()"
          It "Returns key=|$1| value=|$2| without changing the map"
            initTargetMapEnd "$1" "$2"
            myMap="$targetMap"
  
            When call mapGet myMap "$1"
            The variable __ should equal "$2"
            The variable myMap should equal "$targetMap"
          End
        End
        
        Describe "mapGetKeyFor()"
          It "Returns key=|$1| for value=|$2| without changing the map"
            initTargetMapEnd "$1" "$2"
            myMap="$targetMap"
  
            When call mapGetKeyFor myMap "$2"
            The variable __ should equal "$1"
            The variable myMap should equal "$targetMap"
          End
        End

        Describe "mapSet()"
          Describe "Can set key to new value, returning the old"
            It "Setting k=|$1| v=|$3| returns old v=|$2|"
              initTargetMapEnd "$1" "$2"
              myMap="$targetMap"
    
              When call mapSet myMap "$1" "$3"
              The variable __ should equal "$2"
              The variable myMap should not equal "$targetMap"
            End
            It "The new value k=|$1| v=|$3| can be retrieved"
              initTargetMapEnd "$1" "$2"
              myMap="$targetMap"
              mapSet myMap "$1" "$3"
              
              When call mapGet myMap "$1"
              The variable __ should equal "$3"
            End
          End
          
          Describe "Can set key to same value, returning it"
            It "Setting k=|$1| to old value $2 returns it; map is unchaged"
              initTargetMapEnd "$1" "$2"
              myMap="$targetMap"
    
              When call mapSet myMap "$1" "$2"
              The variable __ should equal "$2"
              The variable myMap should equal "$targetMap"
            End
            It "Changing k=|$1| to new value |$3| and then to old value |$2| changes and then restores map"
              initTargetMapEnd "$1" "$2"
              myMap="$targetMap"
              mapSet myMap "$1" "$3"
              changedMap="$myMap"
  
              When call mapSet myMap "$1" "$2"
              The variable myMap should not equal "$changedMap"
              The variable myMap should equal "$targetMap"
            End
          End
        End
        
        Describe "mapDelete()"
          It "Returns its v=|$2| when deleting k=|$1|"
            initTargetMapEnd "$1" "$2"
            myMap="$targetMap"

            When call mapDelete myMap "$1"
            The variable __ should equal "$2"
            The variable myMap should not equal "$targetMap"
          End
          It "Key k=|$1| was deleted; getting it returns empty"
            initTargetMapEnd "$1" "$2"
            myMap="$targetMap"

            mapDelete myMap "$1"
            When call mapGet myMap "$1"
            The variable __ should equal ""
          End
        End
        
        Describe "mapHas()"
          It "Returns true key=|$1| is found without changing the map"
            initTargetMapEnd "$1" "$2"
            myMap="$targetMap"
  
            When call mapHas myMap "$1"
            The variable __ should equal "true"
            The variable myMap should equal "$targetMap"
          End
        End
  
        Describe "mapHasValue()"
          It "Returns true if value=|$2| is found without changing the map"
            initTargetMapEnd "$1" "$2"
            myMap="$targetMap"
  
            When call mapHasValue myMap "$2"
            The variable __ should equal "true"
            The variable myMap should equal "$targetMap"
          End
        End
      End
    End
  End
  
  Describe "Map variable scope"
    Describe "mapSet()"
      It "Does not export local map variable"
        privateMap() {
          local localMap
          mapSet localMap "aKey" "aMap"
        }
          
        When call privateMap
        The variable localMap should be undefined
      End
    End
  End
End   # Library bash3map.sh

  