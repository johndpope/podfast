//
//  Extensions.swift
//  PodFast
//
//  Created by Orestis on 30/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {

    class func fromStoryboard(name: String, identifier: String? = .none, bundle: Bundle? = .none) -> Self? {
        return fromStoryboardHelper(type: self, name: name, identifier: identifier, bundle: bundle)
    }

    private class func fromStoryboardHelper<T: UIViewController>(type: T.Type, name: String, identifier: String?, bundle: Bundle?) -> T? {
        if let identifier = identifier {
            return UIStoryboard(name: name, bundle: bundle).instantiateViewController(withIdentifier: identifier) as? T
        } else {
            return UIStoryboard(name: name, bundle: bundle).instantiateInitialViewController() as? T
        }
    }
}

extension Notification.Name {
    static let appWillResignActive = Notification.Name("appWillResignActive")
    static let appDidBecomeActive = Notification.Name("completedLengthyDownload")
}

extension String {
    var sentences: [String] {
        var sentences = [String]()
        var sentenceNumber = 0
        var currentSentence: String? = ""

        var period = 0

        for (index, char) in self.enumerated() {
            currentSentence! += "\(char)"
            if (char == ".") {
                period = index

                if (period == self.count-1) {
                    sentences.append(currentSentence!)
                }
            } else if ((char == " " && period == index-1 && index != 1) || period == (self.count-1)) {

                sentences.append(currentSentence!)
                currentSentence = ""
                sentenceNumber = sentenceNumber + 1
            }
        }

        return sentences
    }

    func limitTo(numberOfSentences n: Int) -> String {
        return self.sentences.prefix(n).reduce("", +)
    }

    func stripHtml() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}

extension UIView {
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }

    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }

    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }

    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
}

extension UIColor {
    convenience init?(hexString: String) {
        var chars = Array(hexString.hasPrefix("#") ? hexString.dropFirst() : hexString[...])
        switch chars.count {
        case 3: chars = chars.flatMap { [$0, $0] }; fallthrough
        case 6: chars = ["F","F"] + chars
        case 8: break
        default: return nil
        }
        self.init(red: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                green: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                 blue: .init(strtoul(String(chars[6...7]), nil, 16)) / 255,
                alpha: .init(strtoul(String(chars[0...1]), nil, 16)) / 255)
    }
}
