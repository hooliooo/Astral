# Astral
Astral is a minimal HTTP Networking library that aims to simplify an application's networking layer by abstracting
the steps needed to create a network request into an easy to use API. Astral uses Swift's async/await concurrency features.

## Requirements

Astral requires Swift 5.6

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
.package(url: "https://github.com/hooliooo/Astral.git", from: "3.0.0")
```

## A Simple Example
Here's an example using the [Pokemon API](http://pokeapi.co)

```swift
class PokemonAPIClient {

    let client: Client = Client()
    private let baseURL: String = "https://pokeapi.co/api/v2"

    func getPokemon(id: Int) async throws -> (Pokemon, URLResponse) {
        return try await client
            .get("\(self.baseURL)/pokemon/\(id)")
            .headers(
                headers: [
                    Header(key: Header.Key.accept, value: Header.Value.mediaType(.applicationJSON)),
                ]
            )
            .send()
    }

}
```

## Author

[Julio Alorro](https://twitter.com/Hooliooo)

## License

Astral is available under the MIT license. See the LICENSE file for more info.
