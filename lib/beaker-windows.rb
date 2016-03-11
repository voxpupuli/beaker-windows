%w( path powershell registry windows_feature).each do |lib|
  require "beaker-windows/#{lib}"
end

module Beaker
  class TestCase
    include BeakerWindows::Path
    include BeakerWindows::Powershell
    include BeakerWindows::Registry
    include BeakerWindows::WindowsFeature
  end
end
