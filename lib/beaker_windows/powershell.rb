module BeakerWindows
  module Powershell

    # Executes a PowerShell command on a host. Allow validation of command execution and fail if
    # PowerShell command throws an exception. Note: if quotes are required then the single quote
    # should be preferred. If double quotes are required you will need to double escape the quotes!
    #
    # ==== Attributes
    #
    # * +command+ - The PowerShell command to execute on the host.
    # * +opts+ - Either command-line options to pass to PowerShell or the following:
    #   * +:excep_fail+ - Command will return exit code 1 if an exception is caught.
    #     (Default: true)
    #   * +:verify_cmd+ - Command will return exit code 1 if the outcome of the command
    #     is "$false". (Default: false)
    #   * +:EncodedCommand+ - Will encode the command in base64. Useful for commands
    #      with nested quoting or containing Unicode characters. (Default: false)
    #
    # ==== Returns
    #
    # +Beaker::Command+ - An object for executing powershell commands on a host
    #
    # ==== Raises
    #
    # +nil+
    #
    # ==== Example
    #
    # on(hosts, exec_ps_cmd("Set-Content -path 'fu.txt' -value 'fu'"))
    # on(hosts, exec_ps_cmd("Set-Content -path 'fu.txt' -value 'fu'", :ExecutionPolicy => 'Unrestricted')
    # on(hosts, exec_ps_cmd("Set Content -path 'fu.txt', -value 'fu'", :EncodedCommand => true))
    # on(hosts, exec_ps_cmd("1 -eq 2", :verify_cmd => true))
    # on(hosts, exec_ps_cmd("does.not.exist", :excep_fail => true))
    def exec_ps_cmd(command, opts={})
      # Init
      opts[:verify_cmd] ||= false
      opts[:excep_fail] = true if opts[:excep_fail].nil?

      ps_opts = {} # Command-line options to pass to PowerShell

      # Determine how the command should be wrapped for execution
      if opts[:verify_cmd]
        command = "if ( #{command} ) { exit 0 } else { exit 1 }"
      end

      if opts[:excep_fail]
        # Only prefix escape character if not encoded
        var_accessor = opts[:EncodedCommand] ? '$_' : '\$_'

        command = "try { #{command} } catch { Write-Host #{var_accessor}.Exception.Message; exit 1 }"
      end

      # Wrap the command in quotes when not encoded
      command = "\"#{command}\"" unless opts[:EncodedCommand]

      # Coerce all keys to be strings.
      opts.each do |k, v|
        ps_opts[k.to_s] = v unless (k == :verify_cmd) || (k == :excep_fail)
      end

      return powershell(command, ps_opts)
    end

    # Execute a PowerShell script on a remote machine. (This method support native Unicode)
    # Note: This method fails on Windows 2008 R2! See BKR-293 for more details.
    #
    # ==== Attributes
    #
    # * +hosts+ - A Windows Beaker host(s) running PowerShell.
    # * +ps_script+ - A PowerShell script to execute on the remote host.
    #
    # ==== Returns
    #
    # +Beaker::Result+
    #
    # ==== Raises
    #
    # +nil+
    #
    # ==== Examples
    #
    # exec_ps_script_on(host, 'Write-Host Hello')
    def exec_ps_script_on(hosts, ps_script, &block)
      #Init
      script_path = "C:/Windows/Temp/beaker_powershell_script_#{Time.now.to_i}.ps1"
      utf8_ps_script = "\xEF\xBB\xBF".force_encoding('UTF-8') + ps_script.force_encoding('UTF-8')

      block_on(hosts) do |host|
        #Create remote file with UTF-8 BOM
        create_remote_file(host, script_path, utf8_ps_script)

        #Execute PowerShell script on host
        @result = on(host, powershell('', {'File' => script_path}), :accept_all_exit_codes => true)

        #Also, let additional checking be performed by the caller.
        if block_given?
          case block.arity
            #block with arity of 0, just hand back yourself
            when 0
              yield self
            #block with arity of 1 or greater, hand back the result object
            else
              yield @result
          end
        end
        @result
      end
    end

  end
end
