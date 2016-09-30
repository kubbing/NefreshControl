Pod::Spec.new do |s|
  s.name         = "NefreshControl"
  s.version      = "1.1.6"
  s.license      = { :type => "Beerware", :file => 'LICENCE.txt' }
  s.summary      = "Killer Swift refresh control for iOS."
  s.homepage     = "https://github.com/kubbing/NefreshControl"
  s.author             = { "Jakub Hladík" => "kubbing@me.com" }
  s.social_media_url   = "http://twitter.com/ku33ing"

  s.ios.deployment_target = "8.0"
  s.ios.framework = 'UIKit' 
  s.source       = { :git => "https://github.com/kubbing/NefreshControl.git", :tag => s.version }
  s.source_files = 'NefreshControl/NefreshControl.swift'
  # s.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS[config=Debug]' => '-DDEBUG' }
end
