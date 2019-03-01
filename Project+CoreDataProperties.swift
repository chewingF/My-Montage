//
//  Project+CoreDataProperties.swift
//  My Montage
//
//  Created by 陈念 on 17/5/23.
//  Copyright © 2017年 nche75. All rights reserved.
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project");
    }

    @NSManaged public var name: String?
    @NSManaged public var photoCollection: NSSet?

}

// MARK: Generated accessors for photoCollection
extension Project {

    @objc(addPhotoCollectionObject:)
    @NSManaged public func addToPhotoCollection(_ value: Photo)

    @objc(removePhotoCollectionObject:)
    @NSManaged public func removeFromPhotoCollection(_ value: Photo)

    @objc(addPhotoCollection:)
    @NSManaged public func addToPhotoCollection(_ values: NSSet)

    @objc(removePhotoCollection:)
    @NSManaged public func removeFromPhotoCollection(_ values: NSSet)

}
