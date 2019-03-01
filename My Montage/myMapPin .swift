//
//  myMapPin .swift
//  My Montage
//
//  Created by 陈念 on 17/5/23.
//  Copyright © 2017年 nche75. All rights reserved.
//

import Foundation
import MapKit

class myMapPin: NSObject, MKAnnotation{
    //self define map pins
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    var image: UIImage?
    
    //can use photo object to setup directtly.
    init(myPhoto : Photo) {
        image = UIImage(data : myPhoto.imageData! as Data)
        self.title = myPhoto.belongsTo?.name
        self.subtitle = "..."
        self.coordinate = (myPhoto.imageLocation?.coordinate)!
    }
    
    //in case more info needed
    func setSubTitle(newSub: String){
        self.subtitle = newSub
    }
}
