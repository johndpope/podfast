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
