


Pod::Spec.new do |s|
  s.name         = "FCXUniversial"
  s.version      = "0.0.1"
  s.summary      = "FCX's FCXUniversial."
  s.description  = <<-DESC
                    FCXUniversial of FCX
                   DESC

  s.homepage     = "https://github.com/FCXPods/FCXUniversial"

  s.license      = "MIT"
  s.author             = { "fengchuanxiang" => "fengchuanxiang@126.com" }
  s.source       = { :git => "https://github.com/FCXPods/FCXUniversial.git", :tag => "0.0.1" }
  s.platform     = :ios, "6.0"

  s.source_files  = "FCXUniversial/FCXDiscover/", "FCXUniversial/FCXCategory/", "FCXUniversial/FCXUniversial/", "FCXUniversial/FCXAdvert/"
#, "FCXUniversial/FCXShare/"
#s.public_header_files = "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_Extra_Frameworks/TencentOpenAPI"

 s.vendored_libraries = "FCXUniversial/FCXAdvert/libGDTMobSDK.a"
 s.vendored_frameworks = "FCXUniversial/FCXAdvert/GoogleMobileAds.framework"

  s.frameworks  = "AdSupport", "CoreLocation", "SystemConfiguration", "CoreTelephony", "Security", "StoreKit", "QuartzCore", "AudioToolbox", "AVFoundation", "CoreGraphics", "CoreMedia", "EventKit", "EventKitUI", "MessageUI", "CoreMotion", "MediaPlayer", "MessageUI", "CoreLocation", "Foundation", "WebKit"


s.libraries = "z"

#s.frameworks  = "UIKit"

  s.dependency "SDWebImage", "~> 3.7.5"
  s.dependency "UMengAnalytics", "~> 3.6.6"
#s.dependency "UMengSocial", "~> 5.0"
  s.dependency "UMOnlineConfig", "~> 0.1.0"
  s.dependency "UMengFeedback", "~> 2.3.4"

end
