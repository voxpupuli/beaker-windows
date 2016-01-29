module BeakerWindows
  module WindowsFeature

    # Retrieve a list of Windows roles and features from a host. The list can be filtered
    # to available or installed.
    #
    # ==== Attributes
    #
    # * +host+ - A Windows Beaker host running PowerShell 3 or greater.
    # * +opts:filter+ - Filter the list of Windows features.
    #   * +:all+ - Do not filter anything from the list. (Default)
    #   * +:available+ - Filter the list to only the available Windows features.
    #   * +:installed+ - Filter the list to only the installed Windows features.
    #
    # ==== Returns
    #
    # +Array+ - An array of strings representing Windows features.
    #
    # ==== Raises
    #
    # +ArgumentError+ - An invalid filter was specified.
    # +RuntimeError+ - The host does not have PowerShell 3 or greater available.
    #
    # ==== Example
    #
    # get_windows_features_on(host)
    # get_windows_features_on(host, :filter => :available)
    # get_windows_features_on(host, :filter => :installed)
    def get_windows_features_on(host, opts={})
      # Init
      opts[:filter] ||= :all

      ps_cmd = 'Get-WindowsFeature'

      # Filter features
      case opts[:filter]
        when :available
          ps_cmd << ' | Where { \$_.Installed -Eq \$false }'
        when :installed
          ps_cmd << ' | Where { \$_.Installed -Eq \$true }'
        else
          error_message = 'Unknown filter! Specify :all, :available or :installed.'
          raise(ArgumentError, error_message) unless opts[:filter] == :all
      end

      # Select only the feature name
      ps_cmd << ' | Select -ExpandProperty Name'

      # Parse output
      result = on(host, exec_ps_cmd(ps_cmd), :accept_all_exit_codes => true)

      raise(RuntimeError, 'This method requires PowerShell 3 or greater!') if result.exit_code == 1

      return result.stdout.rstrip.split("\n")
    end

    # Install a Windows role or feature on a host.
    #
    # ==== Attributes
    #
    # * +host+ - A Windows Beaker host running PowerShell 3 or greater.
    # * +feature_name+ - The name of the Windows feature to install. (NOT THE DISPLAY NAME!)
    # * +opts:suppress_fail+ - Suppress raising exception on feature installation failure.
    #   * +:true+ - Suppress the raising a RuntimeError exception.
    #   * +:false+ - Allow RuntimeError to be raised if feature fails to install. (Default)
    #
    # ==== Returns
    #
    # +Array+ - An array of strings representing Windows features.
    #
    # ==== Raises
    #
    # +RuntimeError+ - Failed to install the feature.
    # +RuntimeError+ - The host does not have PowerShell 3 or greater available.
    #
    # ==== Example
    #
    # install_windows_feature_on(host, 'Print-Server')
    # install_windows_feature_on(host, 'Bad-Feature', :suppress_fail => true)
    def install_windows_feature_on(host, feature_name, opts={})
      # Init
      opts[:suppress_fail] ||= false

      ps_cmd = "(Install-WindowsFeature -Name '#{feature_name}' -ErrorAction 'Stop').Success"

      # Parse output
      result = on(host, exec_ps_cmd(ps_cmd), :accept_all_exit_codes => true)

      unless opts[:suppress_fail]
        raise(RuntimeError, 'Invalid feature name or incorrect PowerShell version!') if result.exit_code == 1
        raise(RuntimeError, 'Failed to install feature!') unless result.stdout =~ /True/
      end
    end

    # Remove a Windows role or feature on a host.
    #
    # ==== Attributes
    #
    # * +host+ - A Windows Beaker host running PowerShell 3 or greater.
    # * +feature_name+ - The name of the Windows feature to remove. (NOT THE DISPLAY NAME!)
    # * +opts:suppress_fail+ - Suppress raising exception on feature installation failure.
    #   * +:true+ - Suppress the raising a RuntimeError exception.
    #   * +:false+ - Allow RuntimeError to be raised if feature fails to be removed. (Default)
    #
    # ==== Returns
    #
    # +Array+ - An array of strings representing Windows features.
    #
    # ==== Raises
    #
    # +RuntimeError+ - Failed to remove the feature.
    # +RuntimeError+ - The host does not have PowerShell 3 or greater available.
    #
    # ==== Example
    #
    # remove_windows_feature_on(host, 'Print-Server')
    # remove_windows_feature_on(host, 'Bad-Feature', :suppress_fail => true)
    def remove_windows_feature_on(host, feature_name, opts={})
      # Init
      opts[:suppress_fail] ||= false

      ps_cmd = "(Remove-WindowsFeature -Name '#{feature_name}' -ErrorAction 'Stop').Success"

      # Parse output
      result = on(host, exec_ps_cmd(ps_cmd), :accept_all_exit_codes => true)

      unless opts[:suppress_fail]
        raise(RuntimeError, 'Invalid feature name or incorrect PowerShell version!') if result.exit_code == 1
        raise(RuntimeError, 'Failed to remove feature!') unless result.stdout =~ /True/
      end
    end

  end
end

module Beaker
  module DSL
    module Assertions

      # Assert that a Windows feature is installed or not on a host.
      #
      # ==== Attributes
      #
      # * +host+ - A Windows Beaker host running PowerShell 3 or greater.
      # * +feature_name+ - The name of the Windows feature to verify if installed.
      #     (NOT THE DISPLAY NAME!)
      # * +opts:state+ - Assert the state of the Windows feature.
      #   * +:installed+ - Feature is installed. (Default)
      #   * +:available+ - Feature is not installed.
      #
      # ==== Returns
      #
      # +nil+
      #
      # ==== Raises
      #
      # +ArgumentError+ - An invalid state was specified.
      # +Minitest::Assertion+ - The feature is not in the desired state or does not exist.
      #
      # ==== Example
      #
      # assert_windows_feature_on(host, 'Print-Server')
      # assert_windows_feature_on(host, 'WINS', :state => :available)
      # assert_windows_feature_on(host, 'Powershell-V2', :state => :installed)
      def assert_windows_feature_on(host, feature_name, opts={})
        # Init
        opts[:state] ||= :installed

        ps_cmd = "(Get-WindowsFeature -Name '#{feature_name}').InstallState -Eq "

        # Desired state
        case opts[:state]
          when :available
            ps_cmd << "'Available'"
          when :installed
            ps_cmd << "'Installed'"
          else
            raise(ArgumentError, 'Unknown feature state! Specify either :available or :installed.')
        end

        # Parse output
        result = on(host, exec_ps_cmd(ps_cmd), :accept_all_exit_codes => true)

        raise(RuntimeError, 'This method requires PowerShell 3 or greater!') if result.exit_code == 1

        assert_match(/True/, result.stdout, 'The feature is not in the desired state or does not exist!')
      end

    end
  end
end

