//
//  PokemonRequest.swift
//  Astral
//
//  Created by Julio Alorro on 6/4/17.
//  Copyright © 2017 Julio Alorro. All rights reserved.
//

import Astral

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
