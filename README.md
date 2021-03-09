# LocationLogger

`LocationLogger` is a simple framework dedicated to simplifying the acquisition of the user's geolocation and registering it in a chosen endpoint

## Installation

`LocationLogger` is fully integrated with `Cocoapods`, so you can use it by adding in to your `Podfile`:

```ruby
pod 'LocationLogger'
```

Then, run the following command in the `Podfile` directory:

```bash
$ pod install
```

## Dependencies

Currently, `LocationLogger` depends on the following libraries:
```ruby
pod 'Alamofire', '~> 5.4'
pod 'RxCocoa', '~> 6.1'
pod 'RxSwift', '~> 6.1'
```

## How to Use

The `log` function will request the user's authorization to use the location services, retrive the geolocation data and do a request, with the retrived data, to a chosen endpoint.

```swift
log(requestDomain:timestamp:extraText:callback:) 
```

The `requestLocationAuthorization` function will request the user's authorization. It's recommended to use it before calling the `log` function.

```swift
requestLocationAuthorization(callback:)
```

The `requestLocationAuthorizationAndAccuracy` function has the same use as `requestLocationAuthorization`, but with the new full accuracy authorization add for devices with iOS14+.

```swift
requestLocationAuthorizationAndAccuracy(purposeKey:callback:)
```

## Heads Up

This framework will request authorization to access the location data on the user's device. So it's essential, to the app that will use this framework, to add to the key `NSLocationWhenInUseUsageDescription` to its `Info.plist` file with a message that tells its users why the app is requesting access to theirs location informations. In the case of apps that support devices with iOS14+, it is also recommended to add a key to `NSLocationTemporaryUsageDescriptionDictionary` dictionary which will make the permission to temporarily use location services with full accuracy available for use.

## Any Questions?

An example of the framework use is available in this repository. The app with the framework integrated is in the `LocationLoggerExample` folder.
