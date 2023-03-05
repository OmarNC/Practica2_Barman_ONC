//
//  Helper.swift
//  Practica2_Barman_ONC
//
//  Created by Omar Nieto on 03/03/23.
//

import Foundation
import UIKit

class Helper
{
    static let dateFormatter : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter
    }()
    
    
    static func validateText(text : String) -> Bool{
        if (text.trimmingCharacters(in: .whitespaces).isEmpty) {
            return false
        }
        return true
    }
    
    
    static func AlertMessageOk(title : String?, message : String, viewController : UIViewController)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: NSLocalizedString("ALERT_OK", comment: "ALERT_OK"), style: .default)
        alert.addAction(alertAction)
        viewController.present(alert, animated: true)
    }
}
