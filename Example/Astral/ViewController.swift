//
//  ViewController.swift
//  Astral
//
//  Created by hooliooo on 05/21/2017.
//  Copyright (c) 2017 hooliooo. All rights reserved.
//

import UIKit
import Astral

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


        let request: Request = PokemonRequest(id: 1)

        let sender: RequestSender = JSONRequestSender<JSONRequestBuilder>(request: request, printsResponse: true)

        sender.sendURLRequest()
            .onSuccess { (data: Data) -> Void in

                do {
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        else { fatalError("Not a JSON response") }

                    print(json)
                } catch {

                    print("Error: \(error.localizedDescription)")

                }
            }
            .onFailure { (error: NetworkingError) in
                print("Network Error: \(error.localizedDescription)")
            }

    }
}
