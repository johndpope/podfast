//
//  Stylist.swift
//  PodFast
//
//  Created by Orestis on 9/4/20.
//  Copyright © 2020 Orestis Papadopoulos. All rights reserved.
//

import UIKit

struct Colors {
    static let orange = UIColor(hexString: "#D7AD53")!
}

struct Stylist {
    public static  func font(weight: FontWeight, size: CGFloat) -> UIFont? {
        switch weight {
        case .medium:
            return UIFont(name: "TTCommons-Medium", size: size)
        case .regular:
            return UIFont(name: "TTCommons-Regular", size: size)
        case .thin:
            return UIFont(name: "TTCommons-Thin", size: size)
        case .bold:
            return UIFont(name: "TTCommons-Bold", size: size)
        }
    }
}
enum FontWeight {
    case medium
    case regular
    case thin
    case bold
}
