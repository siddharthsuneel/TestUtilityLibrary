//
//  UtilExtensions.swift
//  DeserveCard
//
//  Created by Swapnil Jadhav on 13/11/19.
//  Copyright © 2019 Deserve Inc. All rights reserved.
//

import UIKit

extension UIStoryboard {
    class func vcFactory(_ storyBoardFileName: String,
                         _ storyBoardVCIdenitifier: String) -> UIViewController {
      return UIStoryboard(name: storyBoardFileName,
                          bundle: nil).instantiateViewController(withIdentifier: storyBoardVCIdenitifier)
    }
}

extension UIColor {
    convenience init(hex: String) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0
        var hex: String = hex

        if hex.hasPrefix("#") {
            let index = hex.index(hex.startIndex, offsetBy: 1)
            hex = String(hex[index...])
        }

        let scanner = Scanner(string: hex)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue) {
            switch hex.count {
            case 3:
                red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                blue  = CGFloat(hexValue & 0x00F)              / 15.0
            case 4:
                red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                alpha = CGFloat(hexValue & 0x000F)             / 15.0
            case 6:
                red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
            case 8:
                red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
            default:
                print(
                    "Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8",
                    terminator: "")
            }
        } else {
            print("Scan hex error")
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    func hexStringFromColor() -> String {
       let components = self.cgColor.components
       let red: CGFloat = components?[0] ?? 0.0
       let green: CGFloat = components?[1] ?? 0.0
       let blue: CGFloat = components?[2] ?? 0.0

       let hexString = String.init(
        format: "#%02lX%02lX%02lX",
        lroundf(Float(red * 255)),
        lroundf(Float(green * 255)),
        lroundf(Float(blue * 255)))
       return hexString
    }

    func lighter(by percentage: CGFloat = 10.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 10.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }

    func isLight(threshold: Float = 0.5) -> Bool? {
        let originalCGColor = self.cgColor

        // Now we need to convert it to the RGB colorspace.
        // UIColor.white / UIColor.black are greyscale and not RGB.
        // If you don't do this then you will crash when accessing components
        // index 2 below when evaluating greyscale colors.
        let RGBCGColor = originalCGColor
            .converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components else {
            return nil
        }
        guard components.count >= 3 else {
            return nil
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }

    // Get reverse color of current color. From white to black
    func oppositeColor() -> UIColor {
        var alpha: CGFloat = 1.0

        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue, alpha: alpha)
        }

        var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: 1.0 - hue, saturation: 1.0 - saturation, brightness: 1.0 - brightness, alpha: alpha)
        }

        var white: CGFloat = 0.0
        if self.getWhite(&white, alpha: &alpha) {
            return UIColor(white: 1.0 - white, alpha: alpha)
        }

        return self
    }
    // MARK: Color shades

    // For eg.
    // i/p: [0, 1, 2, 3, 4, 5], selectedIndex = 2
    // o/p: [white.alpha-x4, white.alpha-x5, white, white.alpha-x1, white.alpha-x2, white.alpha-x3]
    static func transperentColorShadesForWhite(
        startIndex: Int,
        count: Int,
        startAlphaPercentage: CGFloat,
        minmumAlpha: CGFloat = 10) -> [UIColor] {
        let shades = UIColor.transperentColorShadesForWhite(
        count: count,
        startAlphaPercentage: startAlphaPercentage,
        minmumAlpha: minmumAlpha)
        guard shades.count > 0 else {
            return []
        }

        let count = shades.count

        // Order the shades as per startIndex parameter. So startIndex will have the white color then remaining shades.
        var orderedShades: [UIColor] = Array(repeating: .black, count: count)
        var newIndex = -1
        for (index, shade) in shades.enumerated() {
            newIndex = index + startIndex
            if newIndex >= count {
                newIndex %= count
            }
            orderedShades[newIndex] = shade
        }

        return orderedShades
    }

    // For eg.
    // i/p: [0, 1, 2, 3, 4, 5]
    // o/p: [white, white.alpha-x1, white.alpha-x2, white.alpha-x3, white.alpha-x4, white.alpha-x5]
    static func transperentColorShadesForWhite(
        count: Int,
        startAlphaPercentage: CGFloat,
        minmumAlpha: CGFloat = 10) -> [UIColor] {
        guard count > 0 else { return [] }
        let whiteColor = UIColor.init(white: 1, alpha: 1)
        guard count > 1 else { return [whiteColor] }

        var shades: [UIColor] = [whiteColor]
        let minimumTransperency: CGFloat = 10
        let totalAvailablePercentage = startAlphaPercentage - minimumTransperency
        let alphaOffset: CGFloat = (totalAvailablePercentage/(CGFloat(count-1)))/100

        var iterator = 1
        var currentAlpha: CGFloat = startAlphaPercentage/100
        while iterator < count {
            let color = UIColor.init(white: 1, alpha: currentAlpha)
            currentAlpha -= alphaOffset
            shades.append(color)
            iterator += 1
        }
        return shades
    }
}

extension CGPoint {
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }

    func equal(from point: CGPoint) -> Bool {
        guard Float(x) == Float(point.x) && Float(y) == Float(point.y) else {
            return false
        }
        return true
    }
}

extension CGFloat {
    static func random(_ maxPoint: CGFloat) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * maxPoint
    }
}

extension UILabel {
    var actualNumberOfLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(
            with: maxSize,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }

    static func lineHeight(text: String?, width: CGFloat, height: CGFloat, font: UIFont) -> CGFloat {
        let label = UILabel(
            frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.text = text
        label.font = font
        label.numberOfLines = 2
        label.sizeToFit()
        label.lineBreakMode = .byWordWrapping
        return label.frame.height
    }
}

extension UIViewController {
    // This method will NEVER return VC of type UINavigationController/ UITabBarController/ UIAlertController.
    func topMostVC(includeChildVC: Bool = true) -> UIViewController {
        if let navigationVC = self as? UINavigationController,
            let topVC = navigationVC.topViewController {
            return topVC.topMostVC(includeChildVC: includeChildVC)
        }
        if let tabBarVC = self as? UITabBarController,
            let selectedVC = tabBarVC.selectedViewController {
            return selectedVC.topMostVC(includeChildVC: includeChildVC)
        }
        if let presentedVC = presentedViewController {
            if presentedVC is UIAlertController {
                return self
            } else {
                return presentedVC.topMostVC(includeChildVC: includeChildVC)
            }
        }

        if includeChildVC, let childVC = children.last {
            return childVC.topMostVC(includeChildVC: includeChildVC)
        }

        return self
    }

    func addNavRightButton(_ title: String, action: Selector?) {
        let closeBarButtonItem = UIBarButtonItem(
            title: title,
            style: .plain,
            target: self,
            action: action)
        navigationItem.rightBarButtonItem = closeBarButtonItem
    }
}
