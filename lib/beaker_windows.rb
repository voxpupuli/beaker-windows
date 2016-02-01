%w( path powershell windows_feature).each do |lib|
  require "beaker_windows/#{lib}"
end

module Beaker
  class TestCase
    include BeakerWindows::Path
    include BeakerWindows::Powershell
    include BeakerWindows::WindowsFeature
  end
end
