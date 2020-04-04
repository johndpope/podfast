//
//  LaunchScreenViewController.swift
//  PodFast
//
//  Created by Orestis on 30/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import UIKit

protocol LaunchViewDelegate: NSObjectProtocol {
    func nextScreen()
}

class LaunchScreenViewController: UIViewController, LaunchViewDelegate {

    func nextScreen() {
        if let vc = DiscoveryScreenViewController.fromStoryboard(name: "Main", identifier: "discovery"){
            self.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }

    private let presenter = LaunchScreenPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setViewDelegate(launchViewDelegate: self)
        presenter.viewDidLoad()
        print("controller - view Did load")
    }

}
