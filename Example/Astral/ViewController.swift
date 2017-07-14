//
//  ViewController.swift
//  Astral
//
//  Created by Julio Alorro on 05/21/2017.
//  Copyright © 2017 Julio Alorro. All rights reserved.
//

import UIKit
import Astral

fileprivate let queue: DispatchQueue = DispatchQueue(
    label: "pokeapi",
    qos: DispatchQoS.userInitiated,
    attributes: [DispatchQueue.Attributes.concurrent]
)

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let request: Request = PokemonRequest(id: 1)

        let dispatcher: RequestDispatcher = JSONRequestDispatcher(
            request: request, builderType: JSONRequestBuilder.self, printsResponse: true
        )

        dispatcher.dispatchURLRequest()
            .onSuccess(queue.context) { (response: Response) -> Void in
                print(response.payload.dictValue)
            }
            .onFailure(queue.context) { (error: NetworkingError) -> Void in
                print(error.localizedDescription)
            }
    }
}
