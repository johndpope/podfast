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

    private var phaseOneHasFinished = false
    private var timeOut = 20.0
    private var secondsRetrying = 0.0

    func nextScreen() {
        // animation has finished
        if phaseOneHasFinished {
            presentMainVC()
        } else {
            if secondsRetrying < timeOut {
                retry(block: {
                    self.nextScreen()
                }, after: 0.5)
            } else {
                // something has gone very wrong here
                presentMainVC()
            }
        }
    }

    private func presentMainVC() {
        if let vc = DiscoveryScreenViewController.fromStoryboard(name: "Main", identifier: "discovery"){
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }

    private func retry(block: @escaping () -> Void, after: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            block()
        }
    }

    private let presenter = LaunchScreenPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setViewDelegate(launchViewDelegate: self)
        presenter.viewDidLoad()
        print("controller - view Did load")
    }

    override func viewDidAppear(_ animated: Bool) {
        animateLabel()
    }

    @IBOutlet weak var labelOutOfViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!

    private func animateLabel() {
        // trailing to safe area = 8
        labelOutOfViewConstraint.isActive = false
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.phaseOneHasFinished = true
            self.textLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 8.0).isActive = true
            self.view.layoutIfNeeded()
        })
    }
}

extension LaunchScreenViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeAnimator(fadingViews: [self.logoImageView, self.textLabel])
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}

final class FadeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    static let duration: TimeInterval = 0.8
    let fadingViews: [UIView]

    init(fadingViews: [UIView]) {
        self.fadingViews = fadingViews
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Self.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!

        let fromView = fromViewController.view
        let toView = toViewController.view
        let container = transitionContext.containerView
        container.addSubview(toView!)

        toView?.frame = transitionContext.finalFrame(for: toViewController)
        toView?.alpha = 0

        let duration = self.transitionDuration(using: transitionContext)

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            self.fadingViews.forEach({
                $0.alpha = 0
            })
            toView?.alpha = 1.0
        }, completion: { finished in
            if finished {
                toView?.alpha = 1.0
            }
          fromView?.alpha = 1
          fromView?.removeFromSuperview()
          transitionContext.completeTransition(true)
        })
    }
}
