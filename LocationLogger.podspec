Pod::Spec.new do |spec|

  spec.name                       = "LocationLogger"
  spec.version                    = "0.1.0"
  spec.summary                    = "Framework dedicated to simplifying the acquisition of the user's geolocation and registering it in a chosen endpoint"
  spec.homepage                   = "https://github.com/ThiagoFerrao/location-logger"
  spec.license                    = { :type => "MIT", :file => "LICENSE" }
  spec.author                     = "Thiago Ferrao"

  spec.source                     = { :git => "https://github.com/ThiagoFerrao/location-logger.git", :tag => "#{spec.version}" }
  spec.source_files               = "LocationLogger/**/*.swift"

  spec.ios.deployment_target      = "9.0"
  spec.osx.deployment_target      = "10.9"
  spec.watchos.deployment_target  = "3.0"
  spec.tvos.deployment_target     = "9.0"
  spec.swift_version              = "5.1"

end