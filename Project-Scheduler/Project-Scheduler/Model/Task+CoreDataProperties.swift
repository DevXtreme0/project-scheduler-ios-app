//
//  Task+CoreDataProperties.swift
//  Project-Scheduler
//
//  Created by user172177 on 5/29/20.
//  Copyright © 2020 MahelManjithaM. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var additionalNote: String?
    @NSManaged public var calendarIdentifier: String?
    @NSManaged public var endDate: Date?
    @NSManaged public var includeToCalendar: Bool
    @NSManaged public var progress: Float
    @NSManaged public var startDate: Date?
    @NSManaged public var taskName: String?
    @NSManaged public var project: Project?

}
