module Beaker
  class TestCase
    %w( path ).each do |lib|
      require "beaker_windows/#{lib}"
    end
    include BeakerWindows::Path
  end
end
