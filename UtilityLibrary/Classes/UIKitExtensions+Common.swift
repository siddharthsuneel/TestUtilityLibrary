//
//  UIViewExtension+Common.swift
//  Deserve
//
//  Created by Amit Bobade on 28/12/20.
//  Copyright © 2020 Deserve Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreTelephony
import Alamofire

enum IPhoneScreenWidthType: Int {
    case unknown = 0
    case small = 320
    case medium = 375
    case large = 414
}

extension UILabel {
    func setHeaderAttributedString(
        with title: String?,
        lineHeight: CGFloat,
        font: UIFont,
        attributes: [NSAttributedString.Key: Any]? = nil) {
        text = nil
        let headerString = title ?? ""
        let attrString = NSMutableAttributedString(
            string: headerString,
            attributes: [.font: font])
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = lineHeight
        if let attributes = attributes {
            attrString.addAttributes(attributes, range: NSRange(location: 0, length: headerString.length))
        }
        attrString.addAttribute(
            .paragraphStyle,
            value: style,
            range: NSRange(location: 0, length: headerString.length))
        attributedText = attrString
    }
}

extension UICollectionViewCell {
    static var reusableIdentifier: String {
        return String(describing: self)
    }

    static var nibName: String {
        return String(describing: self)
    }
}

extension UITableViewHeaderFooterView {
    static var reusableIdentifier: String {
        return String(describing: self)
    }

    static var nibName: String {
        return String(describing: self)
    }
}

extension UIColor {
    class func rgbColor(red: Float, green: Float, blue: Float, alpha: Float = 1.0) -> UIColor {
        return UIColor(red: CGFloat(red/255.0),
                       green: CGFloat(green/255.0),
                       blue: CGFloat(blue/255.0),
                       alpha: CGFloat(alpha))
    }
}

extension UIViewController {
    func presentFullScreen(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
        viewControllerToPresent.modalPresentationStyle = .overCurrentContext
        present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

extension UIDatePicker {
    func setDateRange(_ minDate: Date, _ maxDate: Date) {
        maximumDate = maxDate
        minimumDate = minDate
    }

    func setMinAgeForDob(_ age: Int) {
        let currentDate: Date = Date()
        var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        if let timeZone = TimeZone(identifier: "UTC") {
            calendar.timeZone = timeZone
        }
        var components: DateComponents = DateComponents()
        components.calendar = calendar
        components.year = -age
        if let maxDate: Date = calendar.date(byAdding: components, to: currentDate) {
            maximumDate = maxDate
        }
        components.year = -150
        if let minDate: Date = calendar.date(byAdding: components, to: currentDate) {
            minimumDate = minDate
        }
    }
}
extension UIDevice {
    static func iPhoneScreenWidthType() -> IPhoneScreenWidthType {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            return .unknown
        }

        let deviceWidth = UIScreen.main.bounds.size.width
        return IPhoneScreenWidthType(rawValue: Int(deviceWidth)) ?? .unknown
    }

    static var hasSafeArea: Bool {
        guard let bottom = UIApplication.shared.delegate?.window??.safeAreaInsets.bottom else {
            return false
        }
        return bottom > 0
    }

    // Reference: https://stackoverflow.com/questions/49194968/detect-jailbroken-in-ios-11-or-later
    static var hasJailbreak: Bool {
        guard TARGET_IPHONE_SIMULATOR != 1 else {
            return false
        }

        // Check 1 : existence of files that are common for jailbroken devices
        if FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
        || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
        || FileManager.default.fileExists(atPath: "/bin/bash")
        || FileManager.default.fileExists(atPath: "/usr/sbin/sshd")
        || FileManager.default.fileExists(atPath: "/etc/apt")
        || FileManager.default.fileExists(atPath: "/private/var/lib/apt/")
        || UIApplication.shared.canOpenURL(URL(string: "cydia://package/com.example.package")!) {
            return true
        }

        // Check 2 : Reading and writing in system directories (sandbox violation)
        let stringToWrite = "Jailbreak Test"
        do {
            try stringToWrite.write(
                toFile: "/private/JailbreakTest.txt",
                atomically: true,
                encoding: String.Encoding.utf8)
            // Device is jailbroken
            return true
        } catch {
            return false
        }
    }

    // swiftlint:disable line_length
    // Reference: https://stackoverflow.com/questions/28454344/how-can-i-get-details-about-the-device-data-provider-like-verizon-att-of-an-i
    // swiftlint:enable line_length

    static var carrierName: String? {
        let networkStatus = CTTelephonyNetworkInfo()
        guard
            let info = networkStatus.serviceSubscriberCellularProviders,
            let carrier = info["serviceSubscriberCellularProvider"]
        else {
            return nil
        }
        return carrier.carrierName
    }

    // Reference: https://stackoverflow.com/questions/30748480/swift-get-devices-wifi-ip-address
    static var ipAddress: String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }

                guard let interface = ptr?.pointee else { return "" }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                    // wifi = ["en0"]
                    // wired = ["en2", "en3", "en4"]
                    // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]

                    let name: String = String(cString: (interface.ifa_name))
                    if  name == "en0" || name == "en2" || name == "en3" || name == "en4" ||
                            name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" ||
                            name == "pdp_ip3" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(
                            interface.ifa_addr,
                            socklen_t((interface.ifa_addr.pointee.sa_len)),
                            &hostname,
                            socklen_t(hostname.count),
                            nil,
                            socklen_t(0),
                            NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }

    static var internetConnectionType: String {
        guard let reachabilityManager = NetworkReachabilityManager() else {
            return "unknown"
        }
        if reachabilityManager.isReachable && reachabilityManager.isReachableOnEthernetOrWiFi {
            return "wifi"
        }
        if reachabilityManager.isReachable && reachabilityManager.isReachableOnCellular {
            return "cellular"
        }
        return "unknown"
    }
}

extension UINib {
    class func instanceFromNib(_ nibName: String, owner: Any? = nil) -> UIView? {
        let nib = UINib(
            nibName: nibName,
            bundle: nil)
        let nibs = nib.instantiate(
            withOwner: owner,
            options: nil)
        guard
            nibs.count > 0,
            let view = nibs[0] as? UIView else {
            DLog("Failed to find '\(nibName)' nib file", logLevel: .error)
            return nil
        }
        return view
    }
}

extension Bundle {
    static func appVersionStr() -> String? {
        guard let info = Bundle.main.infoDictionary else { return nil }
        var buildInfo: String = ""

        if let appName = info["CFBundleName"] as? String {
            buildInfo += "\(appName)"
        }

        if let appVersion = info["CFBundleShortVersionString"] as? String {
            buildInfo += " V-\(appVersion)"
        }

        if let bundleVersion = info["CFBundleVersion"] as? String {
            buildInfo += "(\(bundleVersion))"
        }

        return buildInfo.count > 0 ? buildInfo : nil
    }

    static var appVersion: String? {
        guard let info = Bundle.main.infoDictionary else { return nil }
        var buildInfo: String = ""

        if let appVersion = info["CFBundleShortVersionString"] as? String {
            buildInfo += " \(appVersion)"
        }

        if let bundleVersion = info["CFBundleVersion"] as? String {
            buildInfo += "(\(bundleVersion))"
        }

        return buildInfo.isEmpty ? nil : buildInfo
    }

    static var env: String? {
        #if DEV
        return "DEV"

        #elseif SND || SND_V2
        return "SND"

        #elseif QA
        return "QA"

        #elseif STG
        return "STG"

        #elseif PROD
        return "PROD"

        #elseif QA_PROD
        return "QA_PROD"

        #elseif APPCLIP
        return "APPCLIP"
        #endif
    }

    static var appName: String? {
        guard let info = Bundle.main.infoDictionary else { return nil }
        var buildInfo: String = ""

        if let appName = info["CFBundleName"] as? String {
            buildInfo += "\(appName)"
        }

        return buildInfo.isEmpty ? nil : buildInfo
    }
}
