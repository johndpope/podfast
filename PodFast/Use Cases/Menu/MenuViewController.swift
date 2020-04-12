//
//  MenuViewController.swift
//  PodFast
//
//  Created by Orestis on 12/4/20.
//  Copyright © 2020 Orestis Papadopoulos. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class MenuViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var orjpapWebsiteLinkLabel: TTTAttributedLabel!
    @IBOutlet weak var kroutsefWebsiteLinkLabel: TTTAttributedLabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private let linkAttributes = [
        NSAttributedString.Key.font.rawValue: Stylist.font(weight: .bold, size: 20) ?? UIFont.systemFont(ofSize: 20),
        NSAttributedString.Key.foregroundColor.rawValue: UIColor.white.cgColor,
        NSAttributedString.Key.underlineStyle.rawValue: true,
    ] as [String : Any]

    private let activeLinkAttributes = [
        NSAttributedString.Key.font.rawValue: Stylist.font(weight: .bold, size: 20) ?? UIFont.systemFont(ofSize: 20),
        NSAttributedString.Key.foregroundColor.rawValue: UIColor.white.cgColor,
        NSAttributedString.Key.underlineStyle.rawValue: true,
    ] as [String : Any]

    private func setupView() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.versionLabel.text = "Version: \(version)\nBuild: \(buildNumber)"
        }

        orjpapWebsiteLinkLabel.activeLinkAttributes = self.activeLinkAttributes
        orjpapWebsiteLinkLabel.linkAttributes = self.linkAttributes
        var text = "orjpap.github.io"
        var nstitle = text as NSString
        orjpapWebsiteLinkLabel.text = text
        orjpapWebsiteLinkLabel.addLink(to: URL(string: "https://orjpap.github.io")!, with: nstitle.range(of: text))
        orjpapWebsiteLinkLabel.delegate = self

        kroutsefWebsiteLinkLabel.activeLinkAttributes = self.activeLinkAttributes
        kroutsefWebsiteLinkLabel.linkAttributes = self.linkAttributes
        text = "www.kroutsef.com"
        nstitle = text as NSString
        kroutsefWebsiteLinkLabel.addLink(to: URL(string: "https://www.kroutsef.com")!, with: nstitle.range(of: text))

        kroutsefWebsiteLinkLabel.delegate = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MenuViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
