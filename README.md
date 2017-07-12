# Astral

[![CI Status](http://img.shields.io/travis/hooliooo/Astral.svg?style=flat)](https://travis-ci.org/hooliooo/Astral)
[![Version](https://img.shields.io/cocoapods/v/Astral.svg?style=flat)](http://cocoapods.org/pods/Astral)
[![License](https://img.shields.io/cocoapods/l/Astral.svg?style=flat)](http://cocoapods.org/pods/Astral)
[![Platform](https://img.shields.io/cocoapods/p/Astral.svg?style=flat)](http://cocoapods.org/pods/Astral)

## Requirements

Astral requires iOS 10.0 or higher and Swift 3.x

## Installation
### [CocoaPods](http://cocoapods.org/)

1. Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```ruby
pod 'Astral'
```
2. Integrate your dependencies using frameworks: add `use_frameworks!` to your Podfile. 
3. Run `pod install`.

## Example
Here's an example using the [Pokemon API](http://pokeapi.co)
```swift
struct PokeAPIConfiguration: Configuration {

    var scheme: URLScheme {
        return URLScheme.http
    }

    var host: String {
        return "pokeapi.co"
    }

    var basePathComponents: [String] {
        return [
            "api",
            "v2"
        ]
    }

    var baseHeaders: [String : Any] {
        return [
            "Content-Type": "application/json"
        ]
    }
}
```

```swift
struct PokemonRequest: Request {

    let id: Int

    var configuration: Configuration {
        return PokeAPIConfiguration()
    }

    var pathComponents: [String] {
        return [    
            "pokemon",
            "\(self.id)"
        ]
    }

    var method: HTTPMethod {
        return HTTPMethod.GET
    }

    var parameters: [String : Any] {
        return [:]
    }

    var headers: [String : Any] {
        return [:]
    }
}
```

```swift
let queue: DispatchQueue = DispatchQueue(label: "pokeapi", qos: DispatchQoS.userInitiated, attributes: [DispatchQueue.Attributes.concurrent])

let request: Request = PokemonRequest(id: 1)
let sender: RequestSender = JSONRequestSender<JSONRequestBuilder>(request: request, printsResponse: true)

sender.sendURLRequest()
    .onSuccess(queue.context) { (data: Data) -> Void in
        // Create and parse JSON
    }
    .onFailure(queue.context) { (error: NetworkingError) -> Void in
        // Handle the error
    }
    .onComplete(queue.context) { (result: Result<Data, NetworkingError>) -> Void in
        // Handle the completion of the network request
        // such as clean up of the UI
    }
```

## Author

[Julio Alorro](https://twitter.com/Hooliooo)

## License

Astral is available under the MIT license. See the LICENSE file for more info.
