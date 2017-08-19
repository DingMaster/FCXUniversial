


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

s.source_files  = "FCXUniversial/FCXAbout/", "FCXUniversial/FCXDiscover/", "FCXUniversial/FCXCategory/", "FCXUniversial/FCXUniversial/", "FCXUniversial/FCXUniversial/UIKit/", "FCXUniversial/FCXUniversial/Foundation/", "FCXUniversial/FCXAdvert/", "FCXUniversial/FCXAdvert/Baidu/", "FCXUniversial/FCXShare/", "FCXUniversial/FCXAdvert/Mediation Adapters/*.h", "MTA/*.h"

s.resources = "FCXUniversial/FCXShare/ShareIcon/*.png"

 s.vendored_libraries = "FCXUniversial/FCXAdvert/libGDTMobSDK.a", "MTA/*.a"
 s.vendored_frameworks = "FCXUniversial/FCXAdvert/GoogleMobileAds.framework", "FCXUniversial/FCXAdvert/Baidu/BaiduMobAdSDK.framework"

  s.frameworks  = "AdSupport", "CoreLocation", "SystemConfiguration", "CoreTelephony", "Security", "StoreKit", "QuartzCore", "AudioToolbox", "AVFoundation", "CoreGraphics", "CoreMedia", "EventKit", "EventKitUI", "MessageUI", "CoreMotion", "MediaPlayer", "MessageUI", "CoreLocation", "Foundation", "WebKit"


s.libraries = "z", "iconv", "sqlite3", "stdc++", "c++"


  s.dependency "SDWebImage", "~> 3.7.5"
  s.dependency "UMengAnalytics", "~> 4.2.4"
# s.dependency "UMOnlineConfig", "~> 0.1.0"
  s.dependency "UMengFeedback", "~> 2.3.4"
  s.dependency "UMengUShare/Social/Sina", "~> 6.4.5"
  s.dependency "UMengUShare/Social/WeChat", "~> 6.4.5"
  s.dependency "UMengUShare/Social/QQ", "~> 6.4.5"
  s.dependency "UMengUShare/Social/SMS", "~> 6.4.5"

end
