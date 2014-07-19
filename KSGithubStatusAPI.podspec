Pod::Spec.new do |s|
  s.name         = 'KSGithubStatusAPI'
  s.version      = '0.2.2'
  s.summary      = 'A simple Objective-C API controller for status.github.com.'
  s.homepage     = 'https://github.com/Keithbsmiley/KSGithubStatusAPI'
  s.license      = 'MIT'
  s.author       = { 'Keith Smiley' => 'keithbsmiley@gmail.com' }
  s.source       = { :git => 'https://github.com/Keithbsmiley/KSGithubStatusAPI.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.source_files = '*.{h,m}'
  s.requires_arc = true
  s.dependency 'Reachability', '~> 3.1.0'
end
