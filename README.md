# Beaker Windows

Beaker helper library for testing on Windows.

## Installation

Add this line to your application's Gemfile:

    gem 'beaker_windows'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install beaker_windows

## Methods

### join_path

Join paths together with a "\" Windows style path separator. This method will
accept path segments with mixed separators as well as leading and trailing
separators. Optionally you can specify to use an alternate path separator or
strip the drive letter off the combined path.

#### Example 1

    join_path('c:\dog', 'bark')

#### Example 2

    join_path('c:\dog', 'bark', :path_sep => '/')

#### Example 3

    join_path('c:\dog', 'bark', :path_sep => '/', :strip_drive => true)

### exec_ps_cmd

Executes a PowerShell command on a host. Allow validation of command execution
and fail if PowerShell command throws an exception. Note: if quotes are
required then the single quote should be preferred. If double quotes are
required you will need to double escape the quotes!

#### Example 1

    on(hosts, exec_ps_cmd("Set-Content -path 'fu.txt' -value 'fu'"))

#### Example 2

You can specify custom PowerShell options.

    on(hosts, exec_ps_cmd("Set-Content -path 'fu.txt' -value 'fu'", :ExecutionPolicy => 'Unrestricted')

#### Example 3

Encode a command that contains nested quotes or Unicode.

    on(hosts, exec_ps_cmd("Set Content -path 'fu.txt', -value 'fu'", :EncodedCommand => true))

#### Example 4

Wrap the PowerShell command to guarantee an exit code of "1" if the command fails.

    on(hosts, exec_ps_cmd("1 -eq 2", :verify_cmd => true))

#### Example 5

If the command throws an exception then it should exit with "1". (Default)

    on(hosts, exec_ps_cmd("does.not.exist", :excep_fail => true))

### exec_ps_script_on

Execute a PowerShell script on a remote machine. (This method supports native
Unicode) Note: This method fails on Windows 2008 R2! See BKR-293 for more details.

#### Example 1

    exec_ps_script_on(host, 'Write-Host Hello')

#### Example 2

Can also be used in a block for granular verification.

    exec_ps_script_on(hosts, 'Write-Host Hello') do |result|
      assert_match(/Hello/, result.stdout)
    end
