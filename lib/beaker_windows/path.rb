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
