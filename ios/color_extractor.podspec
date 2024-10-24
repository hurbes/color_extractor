#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint color_extractor.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'color_extractor'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter package for extracting dominant colors from images using c with ffi.'
  s.description      = <<-DESC
A new Flutter FFI plugin project.
                       DESC
  s.homepage         = 'http://banerjeearnab.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Personal' => 'me@banerjeearnab.com' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../ffi/*` so that the C sources can be shared among all target platforms.
  
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
