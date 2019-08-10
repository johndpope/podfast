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
