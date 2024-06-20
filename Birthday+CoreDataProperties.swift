//
//  Birthday+CoreDataProperties.swift
//  BirthdayReminder
//
//  Created by Boban Jankovic on 19.06.2024..
//
//

import Foundation
import CoreData


extension Birthday {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Birthday> {
        return NSFetchRequest<Birthday>(entityName: "Birthday")
    }

    @NSManaged public var name: String?
    @NSManaged public var date: Date?
    @NSManaged public var comment: String?
    @NSManaged public var group: Group?

}

extension Birthday : Identifiable {

}
