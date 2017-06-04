//
//  PokeAPIConfiguration.swift
//  Astral
//
//  Created by Julio Alorro on 6/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Astral

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
