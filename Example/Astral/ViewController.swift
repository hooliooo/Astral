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

        let sender: RequestSender = JSONRequestSender<JSONRequestBuilder>(request: request, printsResponse: true)

        sender.sendURLRequest()
            .onSuccess(queue.context) { (data: Data) -> Void in
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        else { fatalError("Not a JSON Response") }

                    print(json)
                } catch {

                    print(error.localizedDescription)

                }
            }
            .onFailure(queue.context) { (error: NetworkingError) -> Void in
                print(error.localizedDescription)
            }
    }
}
