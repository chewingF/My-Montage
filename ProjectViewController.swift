//
//  ProjectViewController.swift
//  My Montage
//
//  Created by nian chen on 2017/6/1.
//  Copyright © 2017年 nche75. All rights reserved.
//

import UIKit
import MobileCoreServices
import ImageIO
import MobileCoreServices
import Photos
//import Social

class ProjectViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource {
    //project view is pretty inportant cause the product of users are shown here, a lot functions are requireed.
    
    //some variables may used later
    var currentProject: Project!
    var oriImageList: Array<UIImage>!
    var imageList: Array<UIImage>!
    var currentImageIndex: Int!
    //all bool
    var moreIsActive = false
    var speedIsX1 = true
    var isPlaying = true
    var filterChanged = false
    var playPauseChanged = false
    var _init = true
    var viewDidLayoutSubviewsCount = 0
    
    //views
    @IBOutlet var showImageView: UIImageView!
    @IBOutlet var ImageAreaView: UIView!
    @IBOutlet var filterCollectionView: UICollectionView!
    
    //@IBOutlet var filterPicker: UIPickerView!
    
    //all buttons and positions for annimation
    @IBOutlet var moreButton: RoundButton!
    @IBOutlet var forwardButton: RoundButton!
    @IBOutlet var locationButton: RoundButton!
    @IBOutlet var speedX1Button: RoundButton!
    @IBOutlet var speedX2Button: RoundButton!
    @IBOutlet var backButton: RoundButton!
    @IBOutlet var playPauseButton: RoundButton!
    @IBOutlet var lastButton: RoundButton!
    @IBOutlet var nextButton: RoundButton!
    @IBOutlet var cameraButton: RoundButton!
    
    var moreCenter: CGPoint!
    var forwardCenter : CGPoint!
    var locationCenter : CGPoint!
    var speedX1Center : CGPoint!
    var speedX2Center : CGPoint!
    var backCenter : CGPoint!
    var playPauseCenter : CGPoint!
    var lastCenter : CGPoint!
    var nextCenter : CGPoint!
    var cameraCenter : CGPoint!
    
    // filter Title, Name and sample list
    var filterTitleList: [String]!
    var filterNameList: [String]!
    var filterSampleList: [UIImage]!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        // set filter title list array.
        self.filterTitleList = ["Original" ,"Chrome", "Fade", "EffectInstant", "Mono", "Noir", "Process", "Tonal", "Transfer"]
        
        // set filter sample list array.
        self.filterSampleList = [#imageLiteral(resourceName: "Original"),#imageLiteral(resourceName: "Chrome"),#imageLiteral(resourceName: "Fade"),#imageLiteral(resourceName: "EffectInstant"),#imageLiteral(resourceName: "Mono"),#imageLiteral(resourceName: "Nior"),#imageLiteral(resourceName: "Process"),#imageLiteral(resourceName: "Tonal"),#imageLiteral(resourceName: "Transfer")]
        
        // set filter name list array.
        self.filterNameList = ["No Filter" ,"CIPhotoEffectChrome", "CIPhotoEffectFade", "CIPhotoEffectInstant", "CIPhotoEffectMono", "CIPhotoEffectNoir", "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer"]
        /*
        // set delegate for filter picker
        self.filterPicker.delegate = self
        self.filterPicker.dataSource = self
        
        // disable filter pickerView
        self.filterPicker.isUserInteractionEnabled = true
        */
        
        //set delegate for collectionview
        self.filterCollectionView.delegate = self
        self.filterCollectionView.dataSource = self
        

        projectImagesApply()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        projectImagesApply()
        if(isPlaying){
            playImages()
        }
    }
    
    //to handle the problem of different screen sizes, put all position define here instead of viewDidLoad
    override func viewDidLayoutSubviews(){
        print("tracking: view did layout subviews")
        viewDidLayoutSubviewsCount += 1
        //there are several situations that this function will be called again like change filter, pause images... so we have to set all situations.
        /*
        if filterChanged||playPauseChanged{
            popAll()
            self.speedX2Button.center = self.speedX2Center
            speedIsX1 = true
            moreIsActive = false
            if isPlaying{
                playImages()
            }
        }
 */
        if (viewDidLayoutSubviewsCount == 2){
        //init all position data
        print("forward center: ")
        print(forwardButton.center)
            moreCenter = moreButton.center
            forwardCenter = forwardButton.center
            locationCenter = locationButton.center
            speedX1Center = speedX1Button.center
            speedX2Center = speedX2Button.center
            backCenter = backButton.center
            playPauseCenter = playPauseButton.center
            lastCenter = lastButton.center
            nextCenter = nextButton.center
            cameraCenter = cameraButton.center
            hideAll()
            
            
            //to bot break the playing ot not state
            if isPlaying{
                self.lastButton.isEnabled = false
                self.nextButton.isEnabled = false
                self.lastButton.alpha = 0
                self.nextButton.alpha = 0
            }else{
                self.lastButton.isEnabled = true
                self.nextButton.isEnabled = true
                self.lastButton.alpha = 1
                self.nextButton.alpha = 1
            }
            
            
            //set up imageview frame
            showImageView.frame = ImageAreaView.bounds
            
            //_init = false
        }
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("project view memory warning")
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - picker view delegate and data source (to choose filter name)
    
    // how many component (i.e. column) to be displayed within picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // How many rows are there is each component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.filterTitleList.count
    }
    
    // title/content for row in given component
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: self.filterTitleList[row], attributes: [NSForegroundColorAttributeName:UIColor.white])
    }
    
    // called when row selected from any component within picker view
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //change bool and filter using,
        filterChanged = true
        self.applyFilter(selectedFilterIndex: row)
        
    }
 */
    
    func projectImagesApply(){
        
        //get image data
        let imageArraySet = currentProject.value(forKey: "photoCollection") as! NSOrderedSet
        let imageArray = imageArraySet.array as! [Photo]
        
        imageList = Array<UIImage>()
        oriImageList = Array<UIImage>()
        
        //add all images to array
        for p in imageArray{
            imageList.append(UIImage(data: p.imageData! as Data , scale: 1.0)!)
            oriImageList.append(UIImage(data: p.imageData! as Data , scale: 1.0)!)
            if showImageView.image == nil{
                showImageView.image = UIImage(data: p.imageData! as Data , scale: 1.0)!
                currentImageIndex = 0
            }
        }
        showImageView.contentMode = .scaleAspectFit
    }
    
    // MARK: - collection view delegate and data source (to choose filter name)
    
    //refresh the collectionview whenever call
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collection_cell" , for: indexPath) as! MyCollectionViewCell
        //let show_Project:Project = projectList[indexPath.row]
        let filterNmae:String = self.filterTitleList[indexPath.row]
        let filterSampleImage = self.filterSampleList[indexPath.row]
        //set up finlter name and sample images for each cell

        cell.setUp(setName: filterNmae, setImage: filterSampleImage)
        
        return cell
    }
    
    
    //return items number
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return filterTitleList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //change bool and filter using,
        filterChanged = true
        self.applyFilter(selectedFilterIndex: indexPath.row)
        
    }


    
    
    // MARK: - main functions

    //play all images function, use image animation
    func playImages(){
        showImageView.animationImages = imageList
        if speedIsX1{
            showImageView.animationDuration = 1
        }else{
            showImageView.animationDuration = 0.5
        }
        showImageView.startAnimating()
    }
    
    //show next image
    func changeNext(){
        if currentImageIndex == (imageList.count - 1){
            currentImageIndex = 0
        }
        else{
            currentImageIndex = currentImageIndex + 1
        }
        showImageView.image = imageList[currentImageIndex!]
        
    }
    
    //show last image
    func changeLast(){
        if currentImageIndex == 0{
            currentImageIndex = (imageList.count - 1)
        }
        else{
            currentImageIndex = currentImageIndex - 1
        }
        showImageView.image = imageList[currentImageIndex]
    }

    //hide all button under more and make invisable
    func hideAll(){
        UIView.animate(withDuration: 0.3, animations: {
            self.forwardButton.center = self.moreCenter
            self.locationButton.center = self.moreCenter
            self.speedX1Button.center = self.moreCenter
            self.speedX2Button.center = self.moreCenter
            self.cameraButton.center = self.moreCenter
            
            self.forwardButton.isEnabled = false
            self.locationButton.isEnabled = false
            self.speedX1Button.isEnabled = false
            self.speedX2Button.isEnabled = false
            self.cameraButton.isEnabled = false
            
            self.forwardButton.alpha = 0
            self.locationButton.alpha = 0
            self.speedX1Button.alpha = 0
            self.speedX2Button.alpha = 0
            self.cameraButton.alpha = 0
        })
    }
    
    //pop out all buttons
    func popAll(){
        UIView.animate(withDuration: 0.3, animations: {

            self.forwardButton.center = self.forwardCenter
            self.locationButton.center = self.locationCenter
            self.speedX1Button.center = self.speedX1Center
            self.speedX2Button.center = self.speedX1Center
            self.cameraButton.center = self.cameraCenter
            //self.backButton.center = self.backCenter
            
            self.forwardButton.isEnabled = true
            self.locationButton.isEnabled = true
            if self.speedIsX1 {
                self.speedX1Button.isEnabled = true
            } else {
                self.speedX2Button.isEnabled = true
            }
            self.cameraButton.isEnabled = true
            
            self.forwardButton.alpha = 1
            self.locationButton.alpha = 1
            if self.speedIsX1 {
                self.speedX1Button.alpha = 1
            } else {
                self.speedX2Button.alpha = 1
            }
            self.cameraButton.alpha = 1
        })
    }
    
    //dunction when more button clicked, show or hide aother buttons
    @IBAction func moreClicked(_ sender: Any) {
        if moreIsActive {
            hideAll()
        } else {
            popAll()
        }
        self.moreIsActive = !self.moreIsActive
    }
    
    //when speedX1 clicked, have different things to do for the current speed
    @IBAction func X1Clicked(_ sender: Any) {
        if speedIsX1{
            if speedX2Button.isEnabled{
                //hide x2
                UIView.animate(withDuration: 0.3, animations: {
                    self.speedX2Button.center = self.speedX1Center
                    self.speedX2Button.alpha = 0
                    self.speedX2Button.isEnabled = false
                })
            }else {
                //show x2
                UIView.animate(withDuration: 0.3, animations: {
                    self.speedX2Button.center = self.speedX2Center
                    self.speedX2Button.alpha = 1
                    self.speedX2Button.isEnabled = true
                })
            }
        } else {
            //swap x1 x2 active X1
            UIView.animate(withDuration: 0.3, animations: {
                self.speedX1Button.center = self.speedX1Center
                self.speedX2Button.center = self.speedX2Center
                
                self.speedIsX1 = true
                if self.isPlaying{
                    self.playImages()
                }
            })
        }
    }
    
    //when speedX2 clicked, have different things to do for the current speed
    @IBAction func X2Clicked(_ sender: Any) {
        if !speedIsX1{
            if speedX1Button.isEnabled{
                //hide x1
                UIView.animate(withDuration: 0.3, animations: {
                    self.speedX1Button.center = self.speedX1Center
                    self.speedX1Button.alpha = 0
                    self.speedX1Button.isEnabled = false
                })
            }else {
                //show x1
                UIView.animate(withDuration: 0.3, animations: {
                    self.speedX1Button.center = self.speedX2Center
                    self.speedX1Button.alpha = 1
                    self.speedX1Button.isEnabled = true
                })
            }
        } else {
            //swap x1 x2 active X2
            UIView.animate(withDuration: 0.3, animations: {
                self.speedX2Button.center = self.speedX1Center
                self.speedX1Button.center = self.speedX2Center
                
                self.speedIsX1 = false
                if self.isPlaying{
                    self.playImages()
                }
                
            })
        }
    }
    
    //to go back last view
    @IBAction func BackClicked(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    //when playing pause, otherwise start to play, images of the button has to be changed as well.
    @IBAction func PlayPauseClicked(_ sender: Any) {
        if self.isPlaying{
            
            showImageView.stopAnimating()
            showImageView.image = imageList[currentImageIndex]//currentImage

            UIView.animate(withDuration: 0.3, animations: {
                self.lastButton.isEnabled = true
                self.nextButton.isEnabled = true
                self.lastButton.alpha = 1
                self.nextButton.alpha = 1
            })
            
            playPauseButton.setImage(#imageLiteral(resourceName: "play-btn"), for: UIControlState())
            isPlaying = false
            
        }else if !self.isPlaying{
            
            
            UIView.animate(withDuration: 0.3, animations: {
                self.lastButton.isEnabled = false
                self.nextButton.isEnabled = false
                self.lastButton.alpha = 0
                self.nextButton.alpha = 0
        })
            playPauseButton.setImage(#imageLiteral(resourceName: "pause-btn"), for: UIControlState())
            
            playImages()
            isPlaying = true
        }
        //chage bool state
        playPauseChanged = true
    }
    
    //meant to be shared directly but don't have time to do more... it's noly saving now.
    @IBAction func shareClicked(_ sender: Any) {
        if isPlaying {
            //save gif when it is playing
            let documentsURL = FileManager.default.urls(for: .documentDirectory,
                                                        in: .userDomainMask).first
            var delay = 0.4
            if !speedIsX1{
                delay = 0.2
            }
            let path = documentsURL!.appendingPathComponent(currentProject.name!+".gif")
            createGIF(name: path, frameDelay: delay)
            // you can check the path and open it in Finder, then you can see the file
            print(path)

            
            let gifData = NSData(contentsOf: path)
            CustomPhotoAlbum.sharedInstance.save(gif: gifData!)
            self.showAlertMessage(alertTitle: "Success", alertMessage: "Gif of the project Saved To Photo Gallery")
            
        }else{
            //save single image hwne not playing.
            CustomPhotoAlbum.sharedInstance.save(image: imageList[currentImageIndex])
            self.showAlertMessage(alertTitle: "Success", alertMessage: "Image No.\(currentImageIndex+1) Saved To Photo Gallery")
        }
    }
    
    //project data to send has been sent in segue part
    @IBAction func locationClicked(_ sender: Any) {
    }
    
    //project data to send has been sent in segue part
    @IBAction func cameraClicked(_ sender: Any) {
        showImageView.stopAnimating()
    }
    
    //go back to last image(loop)
    @IBAction func lastClicked(_ sender: Any) {
        changeLast()
    }
    
    //show next image(loop)
    @IBAction func nextClicked(_ sender: Any) {
        changeNext()
    }
    
    //gif function
    func createGIF(name: URL, loopCount: Int = 0, frameDelay: Double) {
        
        let destinationURL = name
        let destinationGIF = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypeGIF, imageList.count, nil)!
        
        // This dictionary controls the delay between frames
        // If you don't specify this, CGImage will apply a default delay
        let properties = [
            (kCGImagePropertyGIFDictionary as String): [(kCGImagePropertyGIFDelayTime as String): frameDelay]
        ]
        let size:CGFloat = 0.3
        /*
        let alert = UIAlertController(title: "Choose gif size", message: "", preferredStyle: .alert)
        
        /*alert.addAction(UIAlertAction(title: "Don't Save", style: .destructive, handler: {
            (_) in
            return
        }))*/
        alert.addAction(UIAlertAction(title: "Save small", style: .default, handler: { [weak alert] (_) in
            size = 0.1
        }))
        alert.addAction(UIAlertAction(title: "Save large", style: .default, handler: { [weak alert] (_) in
            size = 0.5
        }))
        
        self.present(alert, animated: true, completion: nil)
        */
        for img in imageList {
            let cgImage = img.cgImage
            let rotatedCgImage = createMatchingBackingDataWithImage(imageRef: cgImage,scale: size, orienation: .left)
            // Add the frame to the GIF image
            CGImageDestinationAddImage(destinationGIF, rotatedCgImage!, properties as CFDictionary?)
        }
        
        // Write the GIF file to disk
        CGImageDestinationFinalize(destinationGIF)
        
    }
    
    //filter applys
    func applyFilter(selectedFilterIndex filterIndex: Int) {
        
        self.imageList.removeAll()
        
        for image in oriImageList{
            // if No filter selected then apply default image and return.
            if filterIndex == 0 {
            
                self.imageList.append(image)
                
            }else{

                // Create and apply filter
                // 1 - create source image
                let sourceImage = CIImage(image: image)
        
                // 2 - create filter using name
                let myFilter = CIFilter(name: self.filterNameList[filterIndex])
                myFilter?.setDefaults()
        
                // 3 - set source image
                myFilter?.setValue(sourceImage, forKey: kCIInputImageKey)
        
                // 4 - create core image context
                let context = CIContext(options: nil)
        
                // 5 - output filtered image as cgImage with dimension.
                let outputCGImage = context.createCGImage(myFilter!.outputImage!, from: myFilter!.outputImage!.extent)
        
                // 6 - convert filtered CGImage to UIImage
                let filteredImage = UIImage(cgImage: outputCGImage!, scale: 1.0, orientation: .right)
        
                // 7 - set filtered image to preview
                self.imageList.append(filteredImage)
            }
        }
        
        if isPlaying{
            playImages()
        }
        else{
            self.showImageView.image = imageList[currentImageIndex!]
        }
    }
    
    // Show alert message with OK button
    func showAlertMessage(alertTitle: String, alertMessage: String) {
        
        let myAlertVC = UIAlertController( title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        
        myAlertVC.addAction(okAction)
        
        self.present(myAlertVC, animated: true, completion: nil)
    }
    

    
    //cdimage rotation, cause transfer UIImage to CGImage has rotation problems
    func createMatchingBackingDataWithImage(imageRef: CGImage?,scale: CGFloat, orienation: UIImageOrientation) -> CGImage?
    {
        var orientedImage: CGImage?
        
        if let imageRef = imageRef {
            let originalWidth = imageRef.width
            let outputWidth = CGFloat(originalWidth) * scale
            let originalHeight = imageRef.height
            let outputHeight = CGFloat(originalHeight) * scale
            let bitsPerComponent = imageRef.bitsPerComponent
            let bytesPerRow = imageRef.bytesPerRow
            
            let colorSpace = imageRef.colorSpace
            let bitmapInfo = imageRef.bitmapInfo
            
            var degreesToRotate: Double
            var swapWidthHeight: Bool
            var mirrored: Bool
            switch orienation {
            case .up:
                degreesToRotate = 0.0
                swapWidthHeight = false
                mirrored = false
                break
            case .upMirrored:
                degreesToRotate = 0.0
                swapWidthHeight = false
                mirrored = true
                break
            case .right:
                degreesToRotate = 90.0
                swapWidthHeight = true
                mirrored = false
                break
            case .rightMirrored:
                degreesToRotate = 90.0
                swapWidthHeight = true
                mirrored = true
                break
            case .down:
                degreesToRotate = 180.0
                swapWidthHeight = false
                mirrored = false
                break
            case .downMirrored:
                degreesToRotate = 180.0
                swapWidthHeight = false
                mirrored = true
                break
            case .left:
                degreesToRotate = -90.0
                swapWidthHeight = true
                mirrored = false
                break
            case .leftMirrored:
                degreesToRotate = -90.0
                swapWidthHeight = true
                mirrored = true
                break
            }
            let radians = degreesToRotate * .pi / 180
            
            var width: CGFloat
            var height: CGFloat
            if swapWidthHeight {
                width = outputHeight
                height = outputWidth
            } else {
                width = outputWidth
                height = outputHeight
            }
            
            let contextRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace!, bitmapInfo: bitmapInfo.rawValue)
            contextRef!.translateBy(x: CGFloat(width) / 2.0, y: CGFloat(height) / 2.0)
            if mirrored {
                contextRef!.scaleBy(x: -1.0, y: 1.0)
            }
            contextRef!.rotate(by: CGFloat(radians))
            if swapWidthHeight {
                contextRef!.translateBy(x: -CGFloat(height) / 2.0, y: -CGFloat(width) / 2.0)
            } else {
                contextRef!.translateBy(x: -CGFloat(width) / 2.0, y: -CGFloat(height) / 2.0)
            }
            contextRef?.draw(imageRef, in: CGRect(0.0, 0.0, outputWidth, outputHeight))
            //CGContextDrawImage(contextRef, CGRectMake(0.0, 0.0, CGFloat(originalWidth), CGFloat(originalHeight)), imageRef)
            orientedImage = contextRef!.makeImage()
        }
        
        return orientedImage
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLocationSegue" {
            //give project data to show all pins
            let controller = (segue.destination as! MapViewController)
            controller.showingProject = self.currentProject
        }
        else if segue.identifier == "moreImageSegue" {
            //show current project to keep working
            let controller = (segue.destination as! CameraViewController)
            controller.currentProject = self.currentProject
        }
    }

}
