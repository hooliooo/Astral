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

### [Carthage](https://github.com/Carthage/Carthage)

Add the following to your Cartfile:
```
github "hooliooo/Astral"
```

### [Swift Package Manager](https://swift.org/package-manager/)

Add the following  dependency in your Package.swift file:
```
.package(url: "https://github.com/hooliooo/Astral.git", from: "0.9.0")
```

## A Simple Example
Here's an example using the [Pokemon API](http://pokeapi.co) and the implementations of RequestBuilder and RequestDispatcher
provided by Astral.

Feel free to build and customize your own implementations. Simply adopt the appropriate protocols.

```swift
struct PokeAPIConfiguration: RequestConfiguration {

    let scheme: URLScheme = URLScheme.http

    let host: String = "pokeapi.co"

    let basePathComponents: [String] = [
        "api",
        "v2"
    ]

    let baseHeaders: Set<Header> = [
        Header(key: Header.Field.contentType, value: Header.Value.mediaType(MediaType.applicationJSON))
    ]
}
```

```swift
struct PokemonRequest: Request {

    let id: Int

    let configuration: RequestConfiguration = PokeAPIConfiguration()

    let method: HTTPMethod = HTTPMethod.get

    let pathComponents: [String] = [
        "pokemon",
        "\(self.id)"
    ]

    let parameters: [String : Any] = [:]

    let headers: Set<Header> = []
}
```

```swift
let queue: DispatchQueue = DispatchQueue(label: "pokeapi", qos: DispatchQoS.utility, attributes: [DispatchQueue.Attributes.concurrent])

let request: Request = PokemonRequest(id: 1)
let dispatcher: RequestDispatcher = BaseRequestDispatcher()

dispatcher.response(of: request)
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

## In-depth Example
Let's say you have a get request that requires url path components. An example of that request could be:

```swift
struct YourAPIConfiguration: RequestConfiguration {

    let scheme: URLScheme = URLScheme.https

    let host: String = "yourhost.com"

    let basePathComponents: [String] = [
        "api",
        "v1"
    ]

    let baseHeaders: Set<Header> = [
        Header(key: Header.Field.contentType, value: Header.Value.mediaType(MediaType.applicationJSON))
    ]
}
```

```swift
struct YourRequest: Request {

    let configuration: RequestConfiguration = YourAPIConfiguration()

    let method: HTTPMethod = HTTPMethod.get

    let pathComponents: [String] = [
        "your",
        "path",
        "components"
    ]

    let parameters: [String : Any] = [
        "yourKey": "yourValue,
        "anotherKey": "anotherValue"
    ]

    let headers: Set<Header> = [
        Header(key: Header.Field.accept, value: Header.Value.mediaType(MediaType.applicationJSON))
    ]
}
```

```swift
let queue: DispatchQueue = DispatchQueue(label: "NetworkQueue", qos: DispatchQoS.utility, attributes: [DispatchQueue.Attributes.concurrent])

let request: Request = YourRequest()
let dispatcher: RequestDispatcher = BaseRequestDispatcher(isDebugMode: true)

dispatcher.response(of: request)
```

With these lines of code, your hypothetical request would create the following URL:

```
https://yourhost.com/api/v1/your/path/components?yourKey=yourValue&anotherKey=anotherValue
```

The response would also have the following headers included:
```
Content-Type = application/json
Accept = application/json
```

In the case of when the RequestConfiguration AND the Request have each have a Header with identical keys, the Request WILL OVERWRITE the RequestConfiguration's Header.



## Author

[Julio Alorro](https://twitter.com/Hooliooo)

## License

Astral is available under the MIT license. See the LICENSE file for more info.
