//
//  Group+CoreDataProperties.swift
//  BirthdayReminder
//
//  Created by Boban Jankovic on 19.06.2024..
//
//


import Foundation
import CoreData


extension Group {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Group> {
        return NSFetchRequest<Group>(entityName: "Group")
    }

    @NSManaged public var name: String?
    @NSManaged public var icon: String?
    @NSManaged public var color: String?
    @NSManaged public var birthdays: NSSet?

}

// MARK: Generated accessors for birthdays
extension Group {

    @objc(addBirthdaysObject:)
    @NSManaged public func addToBirthdays(_ value: Birthday)

    @objc(removeBirthdaysObject:)
    @NSManaged public func removeFromBirthdays(_ value: Birthday)

    @objc(addBirthdays:)
    @NSManaged public func addToBirthdays(_ values: NSSet)

    @objc(removeBirthdays:)
    @NSManaged public func removeFromBirthdays(_ values: NSSet)

}

extension Group : Identifiable {

}
