//
//  CameraViewController.swift
//  My Montage
//
//  Created by 陈念 on 17/6/1.
//  Copyright © 2017年 nche75. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, CLLocationManagerDelegate{

    //variables
    var currentProject : Project?
    var coverImage: UIImage!
    var imageArray: [UIImage]!
    var locationManager : CLLocationManager!
    var current_Location : CLLocation!
    var captureSession : AVCaptureSession!
    var cameraOutput : AVCapturePhotoOutput!
    var previewLayer : AVCaptureVideoPreviewLayer!
    var flashEnabled : Bool!
    var isCameraTorchOn : Bool!
    var canTakeNewPhoto: Bool!
    
    
    /// Enumeration for Camera Selection
    public enum CameraSelection {
        /// Camera on the back of the device
        case rear
        /// Camera on the front of the device
        case front
    }
    private(set) public var currentCamera = CameraSelection.rear

    //views
    var coverImageView : UIImageView!
    var whiteCover : UIView!
    @IBOutlet var ImageAreaView: UIView!
    @IBOutlet var BackButton: RoundButton!
    @IBOutlet var ShutterButton: RoundButton!
    @IBOutlet var RedoButton: RoundButton!
    @IBOutlet var UseButton: RoundButton!
    @IBOutlet var ChangeButton: RoundButton!
    @IBOutlet var FlashButton: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //lock oriention
        AppUtility.lockOrientation([.portrait], andRotateTo: .portrait)
        
        //make buttons situations set
        RedoButton.isEnabled = false
        RedoButton.alpha = 0
        UseButton.isEnabled = false
        UseButton.alpha = 0
        flashEnabled = false
        isCameraTorchOn = false
        canTakeNewPhoto = true
        
        //set up project data
        imageArray = Array<UIImage>()
        
        let imageArraySet = currentProject?.value(forKey: "photoCollection") as! NSOrderedSet
        let photoArray = imageArraySet.array
        
        for show_Photo in photoArray{
            let imageData = (show_Photo as! Photo).imageData
            let image = UIImage(data:imageData! as Data, scale: 1.0)
            imageArray.append(image!)
        }
        
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        //enable location manger
        if (!CLLocationManager.locationServicesEnabled()){
            return
        }
        
        //set up avcapture sessoion
        captureSession = AVCaptureSession()
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        cameraOutput = AVCapturePhotoOutput()
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        if let input = try? AVCaptureDeviceInput(device: device) {
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                if (captureSession.canAddOutput(cameraOutput)) {
                    captureSession.addOutput(cameraOutput)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer.frame = ImageAreaView.frame
                    ImageAreaView.layer.addSublayer(previewLayer)

                    captureSession.startRunning()
                }
            } else {
                print("issue here : captureSesssion.canAddInput")
            }
        } else {
            print("some problem here")
        }
        
        //set cover image
        if imageArray.count > 0 {
            coverImage = imageArray.last
        }
        
        //create coverimageview
        coverImageView = UIImageView()
        coverImageView.contentMode = .scaleAspectFit

        ImageAreaView.addSubview(coverImageView)
        
        if coverImage != nil {
            self.coverImageView.image = coverImage.alpha(0.3)
        }
        
    }
    
    //make sure size be correct for may screen size
    override func viewDidLayoutSubviews(){
        previewLayer.frame = ImageAreaView.bounds
        coverImageView.frame = ImageAreaView.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // make current location update all the time
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        current_Location = locations.last! as CLLocation
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        //lock oriention
        AppUtility.lockOrientation([.portrait], andRotateTo: .portrait)
    }
    
    //capture images and save to project, coredata
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print("error occure : \(error.localizedDescription)")
        }
        
        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            var image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
            if (self.currentCamera == .front) {
                //image = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: UIImageOrientation.leftMirrored)
                image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.leftMirrored)
            }
            
            
            //let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
            
            UIView.animate(withDuration:0.3, animations:{
                
                self.coverImageView.image = image
            })
            
            //make redo/use button function enable
            UIView.animate(withDuration: 0.3, animations: {
                //self.whiteCover.removeFromSuperview()
                self.RedoButton.alpha = 1
                self.RedoButton.isEnabled = true
                self.UseButton.alpha = 1
                self.UseButton.isEnabled = true
                self.FlashButton.alpha = 0
                self.FlashButton.isEnabled = false
                self.ChangeButton.alpha = 0
                self.ChangeButton.isEnabled = false
                self.ShutterButton.setImage(#imageLiteral(resourceName: "cam_button1"), for: UIControlState())
            })
        }
    }
    
    // function for use button, confirm to use the image taken.
    @IBAction func UseImage(_ sender: Any) {
        
        let newPhoto: Photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: MyDatabaseHelper.getContext()) as! Photo
        
        coverImage = coverImageView.image
        newPhoto.imageData = UIImageJPEGRepresentation(coverImage, 1) as NSData?
        
        newPhoto.imageLocation = current_Location
        
        currentProject?.addToPhotoCollection(newPhoto)
        MyDatabaseHelper.saveContext()
        imageArray.append(coverImage)
        //reset cover Image
        coverImageView.image = coverImage?.alpha(0.3)
        
        //make redo/use button function not enable
        UIView.animate(withDuration: 0.3, animations: {
            self.RedoButton.alpha = 0
            self.RedoButton.isEnabled = false
            self.UseButton.alpha = 0
            self.UseButton.isEnabled = false
            self.FlashButton.alpha = 1
            self.FlashButton.isEnabled = true
            self.ChangeButton.alpha = 1
            self.ChangeButton.isEnabled = true
        })
        canTakeNewPhoto = true
    }
    
    @IBAction func RedoImage(_ sender: Any) {
        //make coverimageView back
        if coverImage != nil {
            coverImageView.image = coverImage?.alpha(0.3)
        }else{
            coverImageView.image = nil
        }
        //make redo/use button function not enable
        UIView.animate(withDuration: 0.3, animations: {
            self.RedoButton.alpha = 0
            self.RedoButton.isEnabled = false
            self.UseButton.alpha = 0
            self.UseButton.isEnabled = false
            self.FlashButton.alpha = 1
            self.FlashButton.isEnabled = true
            self.ChangeButton.alpha = 1
            self.ChangeButton.isEnabled = true
        })
        canTakeNewPhoto = true
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            // error
        } else {
            // no error
        }
    }
    
    //when go back to last view, consider different situatiions make different operations
    @IBAction func goBack(_ sender: Any) {
        if imageArray.count == 0{
            //delete when no image taken for project
            MyDatabaseHelper.getContext().delete(currentProject!)
            MyDatabaseHelper.saveContext()
            _ = navigationController?.popViewController(animated: true)
        } else if currentProject?.name == nil{
            //ask for name for new projects
            askName()
        } else {
            //for created projects
            MyDatabaseHelper.saveContext()
            _ = navigationController?.popViewController(animated: true)
        }

    }
    
    //ask for name for new project
    func askName(){
        let alert = UIAlertController(title: "Name your new project", message: "Enter a name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "name"
        }
        alert.addAction(UIAlertAction(title: "Don't Save", style: .destructive, handler: {
            (_) in
            MyDatabaseHelper.getContext().delete(self.currentProject!)
            MyDatabaseHelper.saveContext()
            _ = self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField?.text != ""{
                self.currentProject?.name = textField?.text
            }else {
                self.currentProject?.name = "UnNamed"
            }
            MyDatabaseHelper.saveContext()
            _ = self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //flash function
    @IBAction func flashclicked(_ sender: Any) {
        if currentCamera == .front{
            return
        }
        
        flashEnabled = !flashEnabled
        
        if flashEnabled == true {
            FlashButton.setImage(#imageLiteral(resourceName: "flash"), for: UIControlState())
        } else {
            FlashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControlState())
        }
        toggleFlash()
    }
    
    
    /// Enable flash
    fileprivate func enableFlash() {
        if self.isCameraTorchOn == false {
            toggleFlash()
        }
    }
    
    /// Disable flash
    fileprivate func disableFlash() {
        if self.isCameraTorchOn == true {
            FlashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControlState())
            toggleFlash()
        }
    }
    
    /// Toggles between enabling and disabling flash
    fileprivate func toggleFlash() {
        guard self.currentCamera == .rear else {
            // Flash is not supported for front facing camera
            return
        }
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        // Check if device has a flash
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureTorchMode.on) {
                    device?.torchMode = AVCaptureTorchMode.off
                    self.isCameraTorchOn = false
                } else {
                    do {
                        try device?.setTorchModeOnWithLevel(1.0)
                        self.isCameraTorchOn = true
                    } catch {
                        print("[SwiftyCam]: \(error)")
                    }
                }
                device?.unlockForConfiguration()
            } catch {
                print("[SwiftyCam]: \(error)")
            }
        }
    }
    
    //swap camera
    @IBAction func changeClicked(_ sender: Any) {
        switch currentCamera {
        case .front:
            currentCamera = .rear
        case .rear:
            currentCamera = .front
            disableFlash()
        }
        switchCamera()
    }
    
    //function to apply camera swap
    func switchCamera() {
        //Indicate that some changes will be made to the session
        captureSession.beginConfiguration()
            
        //Remove existing input
        guard let currentCameraInput: AVCaptureInput = captureSession.inputs.first as? AVCaptureInput else {
            return
        }
            
        captureSession.removeInput(currentCameraInput)
        
        //Get new input
        var newCamera: AVCaptureDevice! = nil
        if let input = currentCameraInput as? AVCaptureDeviceInput {
            if (input.device.position == .back) {
                newCamera = cameraWithPosition(position: .front)
            } else {
                newCamera = cameraWithPosition(position: .back)
            }
        }
        
        //Add input to session
        var err: NSError?
        var newVideoInput: AVCaptureDeviceInput!
        do {
            newVideoInput = try AVCaptureDeviceInput(device: newCamera)
        } catch let err1 as NSError {
            err = err1
            newVideoInput = nil
        }
        
        if newVideoInput == nil || err != nil {
            print("Error creating capture device input: \(String(describing: err?.localizedDescription))")
        } else {
            captureSession.addInput(newVideoInput)
        }
        
        //Commit all the configuration changes at once
        captureSession.commitConfiguration()
    }

    
    // Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        if let discoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified) {
            for device in discoverySession.devices {
                if device.position == position {
                    return device
                }
            }
        }
        
        return nil
    }


    
    //Shuffer button function
    @IBAction func shufferClicked(_ sender: Any) {
        if !canTakeNewPhoto{
            return
        }
        //coverImageView.image = coverImage?.alpha(0)
        UIView.animate(withDuration: 0.3, animations: {
            self.ShutterButton.setImage(#imageLiteral(resourceName: "cam_button2"), for: UIControlState())
        })
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        print("TRACKER: taking photo")
        cameraOutput.capturePhoto(with: settings, delegate: self)
        canTakeNewPhoto = false
    }

}
