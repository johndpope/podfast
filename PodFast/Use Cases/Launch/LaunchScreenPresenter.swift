//
//  LaunchScreenPresenter.swift
//  PodFast
//
//  Created by Orestis on 30/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import Promises

class LaunchScreenPresenter {
    private let launchInteractor: LaunchInteractor
    weak private var launchViewDelegate : LaunchViewDelegate?

    init(withLaunchInteractor interactor: LaunchInteractor = Launch()){
        launchInteractor = interactor
    }

    func viewDidLoad() {
        launchInteractor.updatePodcasts().then { _ in
            self.launchViewDelegate?.nextScreen()
            }.catch { error in
                print(error)
        }
    }

    func setViewDelegate(launchViewDelegate: LaunchViewDelegate?){
        self.launchViewDelegate = launchViewDelegate
    }
}
