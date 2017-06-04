# Astral

[![CI Status](http://img.shields.io/travis/hooliooo/Astral.svg?style=flat)](https://travis-ci.org/hooliooo/Astral)
[![Version](https://img.shields.io/cocoapods/v/Astral.svg?style=flat)](http://cocoapods.org/pods/Astral)
[![License](https://img.shields.io/cocoapods/l/Astral.svg?style=flat)](http://cocoapods.org/pods/Astral)
[![Platform](https://img.shields.io/cocoapods/p/Astral.svg?style=flat)](http://cocoapods.org/pods/Astral)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Astral requires iOS 10 or higher and Swift 3.x

## Installation

Astral is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Astral"
```

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

struct PokemonRequest: Request {

    let id: Int

    var configuration: Configuration {
        return PokeAPIConfiguration()
    }

    var method: HTTPMethod {
        return HTTPMethod.GET
    }

    var pathComponents: [String] {
        return [
            "pokemon",
            "\(self.id)"
        ]
    }

    var parameters: [String : Any] {
        return [:]
    }

    var headers: [String : Any] {
        return [:]
    }
}

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

Julio Alorro, alorro3@gmail.com

## License

Astral is available under the MIT license. See the LICENSE file for more info.
