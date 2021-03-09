Pod::Spec.new do |spec|

  spec.name                       = "LocationLogger"
  spec.version                    = "0.1.1"
  spec.summary                    = "Framework dedicated to simplifying the acquisition of the user's geolocation and registering it in a chosen endpoint"
  spec.homepage                   = "https://github.com/ThiagoFerrao/location-logger"
  spec.license                    = { :type => "MIT", :file => "LICENSE" }
  spec.author                     = "Thiago Ferrao"

  spec.source                     = { :git => "https://github.com/ThiagoFerrao/location-logger.git", :tag => "#{spec.version}" }
  spec.source_files               = "LocationLogger/**/*.swift"
  spec.frameworks                 = "Foundation", "CoreLocation"
  spec.dependency                   "Alamofire", "~> 5.4"
  spec.dependency                   "RxCocoa", "~> 6.1"
  spec.dependency                   "RxSwift", "~> 6.1"

  spec.platform                   = :ios, "10.0"
  spec.swift_version              = "5.1"

end
