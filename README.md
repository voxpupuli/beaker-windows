# Beaker Windows

Beaker helper library for testing on Windows.

## Installation

Add this line to your application's Gemfile:

    gem 'beaker-windows'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install beaker-windows

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

### get_windows_features_on

Get a list (returns an Array) of Windows features on a host. Allow for
filtering of installed or available features.

#### Example 1

Get all features regardless of installation state.

    get_windows_features_on(host)

#### Example 2

Filter for installed features.

    get_windows_features_on(host, :filter => :installed)

#### Example 3

Filter for available features.

    get_windows_features_on(host, :filter => :available)

### install_windows_feature_on

Install a Windows role or feature on a host.

#### Example 1

    install_windows_feature_on(host, 'Print-Server')

#### Example 2

Optionally failures can be suppressed which allows for delayed verification
of feature installation. (See
[assert_windows_feature_on](#assert_windows_feature_on) for more details.)

    install_windows_feature_on(host, 'Bad-Feature', :suppress_fail => true)

### remove_windows_feature_on

Remove a Windows role or feature on a host.

#### Example 1

    remove_windows_feature_on(host, 'Print-Server')

#### Example 2

Optionally failures can be suppressed which allows for delayed verification
of feature removal. (See
[assert_windows_feature_on](#assert_windows_feature_on) for more details.)

    remove_windows_feature_on(host, 'Bad-Feature', :suppress_fail => true)

### assert_windows_feature_on

Assert that a Windows feature is installed or not on a host. The advantage
of this assert is that is will report as a Beaker test failure if the
assertion fails.

#### Example 1

Assert that a Windows feature is installed.

    assert_windows_feature_on(host, 'Print-Server')

#### Example 2

Assert that a Windows feature is available.

    assert_windows_feature_on(host, 'WINS', :state => :available)

### get_registry_value_on

Get the data from a registry value.

#### Example 1

    get_registry_value_on(host, :hklm, "SOFTWARE\Microsoft\Windows NT\CurrentVersion", "SystemRoot")

### set_registry_value_on

Set the data for a registry value.

#### Example 1

Set data for a REG_SZ registry value.

    set_registry_value_on(host, :hkcu, 'SOFTWARE\test_key', 'string_value', 'test_data')

#### Example 2

Set data for a REG_DWORD registry value.

    set_registry_value_on(host, :hkcu, 'SOFTWARE\test_key', 'dword_value', 255, :dword)

#### Example 3

Set data for a REG_BINARY registry value.

    set_registry_value_on(host, :hkcu, 'SOFTWARE\test_key', 'bin_value', 'be,ef,f0,0d', :bin)

### remove_registry_value_on

Remove a registry value.

#### Example 1

    remove_registry_value_on(host, :hkcu, 'SOFTWARE\test_key', 'string_value')

### new_registry_key_on

Create a new registry key. If the key already exists then this method will
silently fail. This method will create parent intermediate parent keys if they
do not exist.

#### Example 1

    new_registry_key_on(host, :hkcu, 'SOFTWARE\some_new_key')

### remove_registry_key_on

Remove a registry key. The method will not remove a registry key if the key contains
nested subkeys and values. Use the "recurse" argument to force deletion of nested
registry keys.

#### Example 1

    remove_registry_key_on(host, :hkcu, 'SOFTWARE\test_key')
