//
//  My_MontageTests.swift
//  My MontageTests
//
//  Created by 陈念 on 17/5/8.
//  Copyright © 2017年 nche75. All rights reserved.
//

import XCTest
import CoreData
import CoreLocation
@testable import My_Montage

class My_MontageTests: XCTestCase {
    var roundButtonUnderTest: RoundButton!
    var mapPinUnderTest: myMapPin!
    var location: CLLocation!
    var photoUnderTest: Photo!
    var projectUnderTest: Project!
    var myCollectionViewCellUnderTest: MyCollectionViewCell!
    var customPhotoAlbumUnderTest: CustomPhotoAlbum!
    
    override func setUp() {
        super.setUp()
        roundButtonUnderTest = RoundButton()
        
        photoUnderTest = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: MyDatabaseHelper.getContext()) as! Photo
        location = CLLocation(latitude: 100, longitude: 100)
        photoUnderTest.imageLocation = location
        photoUnderTest.imageData = UIImageJPEGRepresentation(#imageLiteral(resourceName: "test"), 1) as NSData?
        
        projectUnderTest = NSEntityDescription.insertNewObject(forEntityName: "Project", into: MyDatabaseHelper.getContext()) as! Project
        
        projectUnderTest.addToPhotoCollection(photoUnderTest)
        projectUnderTest.name = "testP"
        
        mapPinUnderTest = myMapPin(myPhoto: photoUnderTest)
        projectUnderTest = Project()
        
        myCollectionViewCellUnderTest.setUp(setProject: projectUnderTest)
        
        customPhotoAlbumUnderTest = CustomPhotoAlbum()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        roundButtonUnderTest = nil
        location = nil
        mapPinUnderTest = nil
        MyDatabaseHelper.getContext().delete(projectUnderTest)
        MyDatabaseHelper.getContext().delete(photoUnderTest)
        photoUnderTest = nil
        projectUnderTest = nil
        myCollectionViewCellUnderTest = nil
        customPhotoAlbumUnderTest = nil
        super.tearDown()
    }
    
    func testExample() {
        mapPinUnderTest.setSubTitle(newSub: "test")
        XCTAssertEqual(mapPinUnderTest.title, "test", "the title of map pin is wrong")
        do{
            MyDatabaseHelper.saveContext()
        }catch let error as NSError{
            XCTFail("Error: \(error.domain)")
        }
        do{
            customPhotoAlbumUnderTest.createAlbum()
        }catch let error as NSError{
            XCTFail("Error: \(error.domain)")
        }
        do{
            _ = customPhotoAlbumUnderTest.fetchAssetCollectionForAlbum()
        }catch let error as NSError{
            XCTFail("Error: \(error.domain)")
        }
        do{
            customPhotoAlbumUnderTest.save(image: #imageLiteral(resourceName: "test"))
        }catch let error as NSError{
            XCTFail("Error: \(error.domain)")
        }
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    
}
