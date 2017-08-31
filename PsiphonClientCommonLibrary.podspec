#
# Be sure to run `pod lib lint PsiphonClientCommonLibrary.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PsiphonClientCommonLibrary'
  s.version          = '0.1.5'
  s.summary          = 'Psiphon iOS Shared Client Library.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A shared library that encapsulates common client code used across different Psiphon iOS apps.
                       DESC

  s.homepage         = 'https://github.com/Psiphon-Inc/psiphon-ios-client-common-library'
  s.license          = { :type => 'GPLv3', :file => 'LICENSE' }
  s.author           = { 'Psiphon Inc.' => 'info@psiphon.ca' }
  s.source           = { :git => 'https://github.com/Psiphon-Inc/psiphon-ios-client-common-library.git', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'

  s.source_files = 'PsiphonClientCommonLibrary/Classes/**/*'
  s.resource_bundles = {
     'PsiphonClientCommonLibrary' => ['Resources/*.xcassets'],
  }

  s.public_header_files = 'PsiphonClientCommonLibrary/Classes/**/*.h'
  s.dependency 'InAppSettingsKit'
end
