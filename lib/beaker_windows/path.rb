module BeakerWindows
  module Path

    # Combine string containing paths with mixed separators. Coerce the path
    # to Windows style automatically. (Configurable)
    #
    # ==== Attributes
    #
    # * +*paths+ - Two or more strings containing paths to be joined.
    # * +opts+ - An options hash - not required
    #   * +:path_sep+ - The desired path separator to use. (Default: "\")
    #   * +:strip_drive+ - A boolean flag indicating of the drive letter should be stripped.
    #
    # ==== Returns
    #
    # +string+ - An absolute path to the manifests for an environment on the master host.
    #
    # ==== Raises
    #
    # +ArgumentError+ - Too few arguments.
    #
    # ==== Example
    #
    # join_path('c:\meow', 'cats/', 'bats\')
    # join_path('c:\dog', 'bark', :strip_drive => true)
    def join_path(*args)
      # Init
      opts = args.last.is_a?(Hash) ? args.pop : {}
      opts[:path_sep] ||= "\\"
      opts[:strip_drive] ||= false

      combined_path = ''

      # Verify that the user provided at least two paths to combine
      raise(ArgumentError, "Too few arguments") if args.length < 2

      # Combine the paths
      args.each do |path|
        # Verify that the provided args are strings
        raise(ArgumentError, "Non-string provided as path") unless path.is_a?(String)

        combined_path << opts[:path_sep].to_s unless combined_path.empty?
        combined_path << path.gsub(/(\\|\/)/, opts[:path_sep].to_s)
      end

      # Remove duplicate path separators
      combined_path.gsub!(/(\\|\/){2,}/, opts[:path_sep].to_s)

      # Strip the drive letter if needed
      combined_path.sub!(/^\w:/, '') if opts[:strip_drive]

      return combined_path
    end

  end
end

module Beaker
  module DSL
    module Assertions

      # Assert that a Windows file/registry path is valid on a host.
      #
      # ==== Attributes
      #
      # * +host+ - A Windows Beaker host running PowerShell.
      # * +path+ - A path representing either a file system or registry path.
      #     If asserting registry paths they must be perpended with the correct hive.
      # * +path_type+ - The type of path expected.
      #   * +:any+ - Can be a container or leaf. (Default)
      #   * +:container+ - Path must be a file system folder or registry key.
      #   * +:leaf+ - Path must be a file system file or registry value.
      #
      # ==== Raises
      #
      # +ArgumentError+ - An invalid path type specified.
      # +Minitest::Assertion+ - Path does not exist or is the wrong type.
      #
      # ==== Example
      #
      # assert_win_path_on(host, 'C:\Windows')
      # assert_win_path_on(host, 'C:\Windows\System32', :container)
      # assert_win_path_on(host, 'C:\Windows\System32\kernel32.dll', :leaf)
      # assert_win_path_on(host, 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRoot')
      def assert_win_path_on(host, path, path_type=:any)
        # Init
        ps_cmd = "Test-Path -Path '#{path}' -Type "

        # Expected path type
        case path_type
          when :any
            ps_cmd << 'Any'
          when :container
            ps_cmd << 'Container'
          when :leaf
            ps_cmd << 'Leaf'
          else
            raise(ArgumentError, 'An invalid path type specified!')
        end

        # Test path
        result = on(host, exec_ps_cmd(ps_cmd,
                                      :verify_cmd => true,
                                      :EncodedCommand => true),
                    :accept_all_exit_codes => true)
        assert(0 == result.exit_code, 'Path does not exist or is the wrong type!')
      end

    end
  end
end
