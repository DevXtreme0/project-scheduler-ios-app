//
//  ProgressbarColours.swift
//  Project-Scheduler
//
//  Created by user172177 on 5/10/20.
//  Copyright © 2020 MahelManjithaM. All rights reserved.
//

import Foundation
import UIKit

public class Colours {
    public func getProgressGradient(_ percentage: Int, negative: Bool = false) -> [UIColor] {
        let _default: [UIColor] = [UIColor.red, UIColor.orange]
        
        if !negative {
            if percentage <= 35 {
                return [UIColor(red: 255/255, green: 50/255, blue: 0/255, alpha: 1.00), UIColor(red: 255/255, green: 69/255, blue: 69/255, alpha: 1.00)]
            } else if percentage <= 60 {
                return [UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1.00), UIColor(red: 255/255, green: 155/255, blue: 57/255, alpha: 1.00)]
            } else if percentage <= 80 {
                return [UIColor(red: 255/255, green: 233/255, blue: 0/255, alpha: 1.00), UIColor(red: 255/255, green: 155/255, blue: 57/255, alpha: 1.00)]
            } else if percentage <= 100 {
                return [UIColor(red: 106/255, green: 255/255, blue: 0/255, alpha: 1.00), UIColor(red: 151/255, green: 255/255, blue: 49/255, alpha: 1.00)]
            }
            return _default
        } else {
            if percentage <= 35 {
                return [UIColor(red: 106/255, green: 255/255, blue: 0/255, alpha: 1.00), UIColor(red: 151/255, green: 255/255, blue: 49/255, alpha: 1.00)]
            } else if percentage <= 60 {
                return [UIColor(red: 255/255, green: 233/255, blue: 0/255, alpha: 1.00), UIColor(red: 255/255, green: 155/255, blue: 57/255, alpha: 1.00)]
            } else if percentage <= 80 {
                return [UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1.00), UIColor(red: 255/255, green: 155/255, blue: 57/255, alpha: 1.00)]
            } else if percentage <= 100 {
                return [UIColor(red: 255/255, green: 50/255, blue: 0/255, alpha: 1.00), UIColor(red: 255/255, green: 69/255, blue: 69/255, alpha: 1.00)]
            }
            return _default
        }
        return _default
    }
}
