//
//  Photo+CoreDataProperties.swift
//  My Montage
//
//  Created by 陈念 on 17/5/23.
//  Copyright © 2017年 nche75. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Phsoto");
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var imageLocation: CLLocation?
    @NSManaged public var belongsTo: Project?

}
