Pod::Spec.new do |s|

  s.name         = "P9TutorialPlayer"
  s.version      = "1.0.0"
  s.summary      = "You can build general tutorial animation and managing logic with P9TutorialPlayer easily."
  s.homepage     = "https://github.com/P9SOFT/TutorialPlayer"
  s.license      = { :type => 'MIT' }
  s.author       = { "Tae Hyun Na" => "taehyun.na@gmail.com" }

  s.ios.deployment_target = '8.0'
  s.requires_arc = true

  s.source       = { :git => "https://github.com/P9SOFT/TutorialPlayer.git", :tag => "1.0.0" }
  s.source_files  = "Sources/*.{h,m}"
  s.public_header_files = "Sources/*.h"

end
