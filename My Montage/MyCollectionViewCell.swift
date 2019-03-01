//
//  myTableViewCell.swift
//  My Montage
//
//  Created by 陈念 on 17/5/8.
//  Copyright © 2017年 nche75. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    @IBOutlet var showImage: UIImageView!
    @IBOutlet var nameText: UILabel!
    
    var project : Project!
    
    //every collection cell represent a project so we use a project to do set up.
    func setUp(setProject : Project){
        self.project = setProject
        self.nameText.text = setProject.name//set name
        let imageArraySet = setProject.value(forKey: "photoCollection") as! NSOrderedSet
        var imageArray = imageArraySet.array
        let show_Photo = imageArray[0] as! Photo
        let image = UIImage(data: show_Photo.imageData! as Data, scale:1.0)
        //set cover image
        self.showImage.image = image
        self.showImage.contentMode = .scaleAspectFill
        self.layer.cornerRadius = 5;
    }
    
    func setUp(setName : String, setImage : UIImage){
        self.project = nil
        self.nameText.text = setName
        
        self.showImage.image = setImage.alpha(0.8)
        self.showImage.contentMode = .scaleAspectFill
        self.layer.cornerRadius = 5;
    }
    
    func updateFrame(parentFrame:CGRect, index:Int) {
        let oldWidth = frame.width
        let newWidth = (parentFrame.width) / 3 - 10
        let row = CGFloat(index%3)
        let colum = CGFloat(index/3)
        let newFrame = CGRect(x: frame.minX+(oldWidth-newWidth)*row/2, y: frame.minY + (newWidth-oldWidth)*colum, width: newWidth, height: newWidth)
        self.frame = newFrame
    }
}
