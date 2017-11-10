# Astral
Astral is a minimal HTTP Networking library that aims to simplify an application's networking layer by abstracting
the steps needed to create a network request into multiple objects.

It aims to shy away from the typical network layer singleton by encapsulating each part of network request as an object.

Astral makes use of the [BrightFutures](https://github.com/Thomvis/BrightFutures) library to flatten the asynchronous calls
associated with networking, making your code base as readable as possible.

Inspired by Soroush Khanlou's [blog post](http://khanlou.com/2016/05/protocol-oriented-programming/) on Protocol Oriented 
Programming.

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
Here's an example using the [Pokemon API](http://pokeapi.co) and the implementations of RequestBuilder and RequestDispatcher
provided by Astral.

Feel free to build and customize your own implementations. Simply adopt the appropriate protocols.

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
        return HTTPMethod.get
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
let queue: DispatchQueue = DispatchQueue(label: "pokeapi", qos: DispatchQoS.utility, attributes: [DispatchQueue.Attributes.concurrent])

let request: Request = PokemonRequest(id: 1)
let dispatcher: RequestDispatcher = JSONRequestDispatcher(request: request)

dispatcher.dispatchURLRequest()
    .onSuccess(queue.context) { (response: Response) -> Void in
        // let responseData: Data = response.data
        // Do something with data
        // or
        // let dictionary: [String: Any] = response.json.dictValue
        // Do something with dictionary
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
