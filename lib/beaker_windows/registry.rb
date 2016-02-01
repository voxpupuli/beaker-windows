module BeakerWindows
  module Registry

    # Get the data from a registry value.
    #
    # ==== Attributes
    #
    # * +hive+ - A symbol representing the following hives:
    #   * +:hklm+ - HKEY_LOCAL_MACHINE.
    #   * +:hkcu+ - HKEY_CURRENT_USER.
    #   * +:hku+ - HKEY_USERS.
    #
    # ==== Returns
    #
    # +String+ - A string representing the PowerShell hive path.
    #
    # ==== Raises
    #
    # +ArgumentError+ - Invalid registry hive specified!
    #
    # ==== Example
    #
    # get_registry_value_on(host, :hklm, "SOFTWARE\Microsoft\Windows NT\CurrentVersion", "SystemRoot")
    def _get_hive(hive)
      # Translate hives.
      case hive
        when :hklm
          return "HKLM:\\"
        when :hkcu
          return "HKCU:\\"
        when :hku
          return "HKU:\\"
        else
          raise(ArgumentError, 'Invalid registry hive specified!')
      end
    end

    # Get the data from a registry value.
    #
    # ==== Attributes
    #
    # * +host+ - A Windows Beaker host.
    # * +hive+ - The hive containing the registry value. Allowed values:
    #   * +:hklm+ - HKEY_LOCAL_MACHINE.
    #   * +:hkcu+ - HKEY_CURRENT_USER.
    #   * +:hku+ - HKEY_USERS.
    # * +path+ - The key containing the desired registry value.
    # * +value+ - The name of the registry value.
    #
    # ==== Returns
    #
    # +String+ - A string representing the registry value data. (Always returns a string
    #    even for DWORD/QWORD and Binary value types.)
    #
    # ==== Raises
    #
    # +ArgumentError+ - Invalid registry hive specified!
    # +RuntimeError+ - The specified key or path does not exist.
    #
    # ==== Example
    #
    # get_registry_value_on(host, :hklm, "SOFTWARE\Microsoft\Windows NT\CurrentVersion", "SystemRoot")
    def get_registry_value_on(host, hive, path, value)
      # Init
      ps_cmd = "(Get-Item -Path '#{_get_hive(hive)}#{path}').GetValue('#{value}')"

      # Parse output
      result = on(host, exec_ps_cmd(ps_cmd, :EncodedCommand => true), :accept_all_exit_codes => true)

      raise(RuntimeError, 'Registry path or value does not exist!') if result.exit_code == 1

      return result.stdout.rstrip
    end

    # Create or update the data for a registry value.
    #
    # ==== Attributes
    #
    # * +host+ - A Windows Beaker host.
    # * +hive+ - The hive containing the registry value. Allowed values:
    #   * +:hklm+ - HKEY_LOCAL_MACHINE.
    #   * +:hkcu+ - HKEY_CURRENT_USER.
    #   * +:hku+ - HKEY_USERS.
    # * +path+ - The key containing the desired registry value.
    # * +value+ - The name of the registry value.
    # * +data+ - The data for the specified registry value.
    # * +data_type+ - The data type for the specified registry value:
    #   * +:string+ - REG_SZ .
    #   * +:multi+ - REG_MULTI_SZ.
    #   * +:expand+ - REG_EXPAND_SZ.
    #   * +:dword+ - REG_DWORD.
    #   * +:qword+ - REG_QWORD.
    #   * +:bin+ - REG_BINARY. This needs to be a string of comma-separated hex values.
    #       (example: "be,ef,f0,0d")
    #
    # ==== Raises
    #
    # +ArgumentError+ - Invalid registry hive specified!
    # +ArgumentError+ - Invalid format for binary data!
    # +ArgumentError+ - Invalid data type specified!
    # +RuntimeError+ - The specified key or path does not exist.
    #
    # ==== Example
    #
    # set_registry_value_on(host, :hkcu, 'SOFTWARE\test_key', 'string_value', 'test_data')
    # set_registry_value_on(host, :hkcu, 'SOFTWARE\test_key', 'dword_value', 255, :dword)
    # set_registry_value_on(host, :hkcu, 'SOFTWARE\test_key', 'bin_value', 'be,ef,f0,0d', :bin)
    def set_registry_value_on(host, hive, path, value, data, data_type=:string)
      # Init
      ps_cmd = "New-ItemProperty -Force -Path '#{_get_hive(hive)}#{path}' -Name '#{value}'"

      # Data type coercion.
      case data_type
        when :string
          ps_cmd << " -Value '#{data.to_s}' -PropertyType String"
        when :multi
          ps_cmd << " -Value '#{data.to_s}' -PropertyType MultiString"
        when :expand
          ps_cmd << " -Value '#{data.to_s}' -PropertyType ExpandString"
        when :dword
          ps_cmd << " -Value #{data.to_s} -PropertyType DWord"
        when :qword
          ps_cmd << " -Value #{data.to_s} -PropertyType QWord"
        when :bin
          raise(ArgumentError, 'Invalid format for binary data!') unless data =~ /^(,?[\da-f]{2})+$/

          hexified = ''
          data.split(',').each do |hex|
            hexified << ',' unless hexified.empty?
            hexified << "0x#{hex}"
          end

          ps_cmd << " -Value ([byte[]](#{hexified})) -PropertyType Binary"
        else
          raise(ArgumentError, 'Invalid data type specified!')
      end

      # Parse output
      result = on(host, exec_ps_cmd(ps_cmd, :EncodedCommand => true), :accept_all_exit_codes => true)

      raise(RuntimeError, 'Registry path or value does not exist!') if result.exit_code == 1
    end

    # Remove a registry value.
    #
    # ==== Attributes
    #
    # * +host+ - A Windows Beaker host.
    # * +hive+ - The hive containing the registry value. Allowed values:
    #   * +:hklm+ - HKEY_LOCAL_MACHINE.
    #   * +:hkcu+ - HKEY_CURRENT_USER.
    #   * +:hku+ - HKEY_USERS.
    # * +path+ - The key containing the desired registry value.
    # * +value+ - The name of the registry value.
    #
    # ==== Returns
    #
    # +String+ - A string representing the registry value data. (Always returns a string
    #    even for DWORD/QWORD and Binary value types.)
    #
    # ==== Raises
    #
    # +ArgumentError+ - Invalid registry hive specified!
    # +RuntimeError+ - The specified key or path does not exist.
    #
    # ==== Example
    #
    # remove_registry_value_on(host, :hkcu, 'SOFTWARE\test_key', 'string_value')
    def remove_registry_value_on(host, hive, path, value)
      # Init
      ps_cmd = "Remove-ItemProperty -Force -Path '#{_get_hive(hive)}#{path}' -Name '#{value}'"

      # Parse output
      result = on(host, exec_ps_cmd(ps_cmd, :EncodedCommand => true), :accept_all_exit_codes => true)

      raise(RuntimeError, 'Registry path or value does not exist!') if result.exit_code == 1
    end

    # Create a new registry key. If the key already exists then this method will
    # silently fail. This method will create parent intermediate parent keys if they
    # do not exist.
    #
    # ==== Attributes
    #
    # * +host+ - A Windows Beaker host.
    # * +hive+ - The hive containing the registry value. Allowed values:
    #   * +:hklm+ - HKEY_LOCAL_MACHINE.
    #   * +:hkcu+ - HKEY_CURRENT_USER.
    #   * +:hku+ - HKEY_USERS.
    # * +path+ - The path of the registry key to create.
    #
    # ==== Raises
    #
    # +ArgumentError+ - Invalid registry hive specified!
    # +RuntimeError+ - The specified key or path does not exist.
    #
    # ==== Example
    #
    # new_registry_key_on(host, :hkcu, 'SOFTWARE\some_new_key')
    def new_registry_key_on(host, hive, path)
      # Init
      ps_cmd = "New-Item -Force -Path '#{_get_hive(hive)}#{path}'"

      # Parse output
      result = on(host, exec_ps_cmd(ps_cmd, :EncodedCommand => true), :accept_all_exit_codes => true)

      raise(RuntimeError, 'Registry path or value does not exist!') if result.exit_code == 1
    end

    # Remove a registry key. The method will not remove a registry key if the key contains
    # nested subkeys and values. Use the "recurse" argument to force deletion of nested
    # registry keys.
    #
    # ==== Attributes
    #
    # * +host+ - A Windows Beaker host.
    # * +hive+ - The hive containing the registry value. Allowed values:
    #   * +:hklm+ - HKEY_LOCAL_MACHINE.
    #   * +:hkcu+ - HKEY_CURRENT_USER.
    #   * +:hku+ - HKEY_USERS.
    # * +path+ - The key containing the desired registry value.
    # * +recurse+ - Recursively delete nested subkeys and values. (Default: false)
    #
    # ==== Returns
    #
    # +String+ - A string representing the registry value data. (Always returns a string
    #    even for DWORD/QWORD and Binary value types.)
    #
    # ==== Raises
    #
    # +ArgumentError+ - Invalid registry hive specified!
    # +RuntimeError+ - The specified key or path does not exist.
    #
    # ==== Example
    #
    # remove_registry_key_on(host, :hkcu, 'SOFTWARE\test_key')
    def remove_registry_key_on(host, hive, path, recurse=false)
      # Init
      ps_cmd = "Remove-Item -Force -Path '#{_get_hive(hive)}#{path}'"

      # Recursively delete key if requested
      ps_cmd << " -Recurse" if recurse

      # Parse output
      result = on(host, exec_ps_cmd(ps_cmd, :EncodedCommand => true), :accept_all_exit_codes => true)

      raise(RuntimeError, 'Registry path or value does not exist!') if result.exit_code == 1
    end

  end
end
