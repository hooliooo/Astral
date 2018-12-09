//
//  MainView.swift
//  AstralApp
//
//  Created by Julio Miguel Alorro on 12/9/18.
//

import UIKit

public final class MainView: UIView {

    public let loadButton: UIButton = {
        let view: UIButton = UIButton(type: UIButton.ButtonType.system)
        view.backgroundColor = UIColor.green
        view.setTitle("Upload", for: UIControl.State.normal)
        return view
    }()

    public let helloWorldButton: UIButton = {
        let view: UIButton = UIButton(type: UIButton.ButtonType.system)
        view.backgroundColor = UIColor.blue
        view.setTitle("Hello World", for: UIControl.State.normal)
        return view
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        [self.loadButton, self.helloWorldButton].forEach {
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        self.loadButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50.0).isActive = true
        self.loadButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        self.loadButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.loadButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        self.loadButton.widthAnchor.constraint(equalToConstant: 132.0).isActive = true

        self.helloWorldButton.bottomAnchor.constraint(equalTo: self.loadButton.topAnchor, constant: -50.0).isActive = true
        self.helloWorldButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.helloWorldButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        self.helloWorldButton.widthAnchor.constraint(equalToConstant: 132.0).isActive = true

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
