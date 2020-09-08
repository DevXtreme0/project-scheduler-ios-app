//
//  Project+CoreDataProperties.swift
//  Project-Scheduler
//
//  Created by user172177 on 5/29/20.
//  Copyright © 2020 MahelManjithaM. All rights reserved.
//
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var academicLevel: String?
    @NSManaged public var additionalNote: String?
    @NSManaged public var assessmentName: String?
    @NSManaged public var awardedMark: Int16
    @NSManaged public var calendarIdentifier: String?
    @NSManaged public var dueDate: Date?
    @NSManaged public var includeToCalendar: Bool
    @NSManaged public var moduleName: String?
    @NSManaged public var moduleWeight: Int16
    @NSManaged public var startDate: Date?
    @NSManaged public var task: NSSet?

}

// MARK: Generated accessors for task
extension Project {

    @objc(addTaskObject:)
    @NSManaged public func addToTask(_ value: Task)

    @objc(removeTaskObject:)
    @NSManaged public func removeFromTask(_ value: Task)

    @objc(addTask:)
    @NSManaged public func addToTask(_ values: NSSet)

    @objc(removeTask:)
    @NSManaged public func removeFromTask(_ values: NSSet)

}
