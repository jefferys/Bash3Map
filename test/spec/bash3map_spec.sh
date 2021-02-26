Describe "Library bash3map.sh"

  Include "./lib/bash3map.sh"

  Describe "sayErr"
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
  End
End

Describe "Script bash3map.sh"
    It "Exits with error if executed"
        When run script "lib/bash3map.sh"
        The error should equal "ERROR: This is a bash library; it should only be sourced, not executed."
        The status should equal 2
    End
End
  