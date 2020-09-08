//
//  DateFormat.swift
//  Project-Scheduler
//
//  Created by user172177 on 5/10/20.
//  Copyright © 2020 MahelManjithaM. All rights reserved.
//

import Foundation

public class Formatter {
    // Helper to format date
    public func formatDate(_ date: Date) -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
}
