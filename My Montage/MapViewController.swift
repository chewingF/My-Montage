//
//  MapViewController.swift
//  My Montage
//
//  Created by 陈念 on 17/5/8.
//  Copyright © 2017年 nche75. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreTelephony

class MapViewController: UIViewController, MKMapViewDelegate {
    //views
    @IBOutlet var myMap: MKMapView!
    @IBOutlet var toMapButton: UIButton!
    
    //variablesl
    var showingProject:Project?
    let regionRadius: CLLocationDistance = 1000
    var appleMapsURL: URL?
    var count = 0

    //set up map when view load
    override func viewDidLoad() {
        super.viewDidLoad()
        AppUtility.lockOrientation([.portrait], andRotateTo: .portrait)
        myMap.delegate = self
        
        // Do any additional setup after loading the view.
        
        let imageArraySet = showingProject?.value(forKey: "photoCollection") as! NSOrderedSet
        let imageArray = imageArraySet.array as! [Photo]
        
        for show_Photo in imageArray{
            count += 1
            if count == 1{
                //let coordinateRegion = MKCoordinateRegionMakeWithDistance((show_Photo.imageLocation?.coordinate)!, regionRadius * 2.0, regionRadius * 2.0)
                //myMap.setRegion(coordinateRegion, animated: true)
            }
            let photoPin = myMapPin(myPhoto: show_Photo)
            photoPin.setSubTitle(newSub: "No.\(count)")
            myMap.addAnnotation(photoPin)
            
            toMapButton.isEnabled = false
            toMapButton.alpha = 0
        }
    }
    
    //this function adds points on the map based on all images
    func addPin(pinPhoto : Photo) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = (pinPhoto.imageLocation?.coordinate)!
        annotation.title = "No.\(count)"
        myMap.addAnnotation(annotation)
    }
    
    //set up map
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            let lattitude = annotation.coordinate.latitude
            let longitude = annotation.coordinate.longitude
            appleMapsURL = URL(string: "http://maps.apple.com/?q=\(lattitude),\(longitude)")
            UIView.animate(withDuration: 0.3, animations:
                {self.toMapButton.isEnabled = true;
                    self.toMapButton.alpha = 0.9})
        }
    }
    
    //override point setting like image and above info
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            /// show the callout "bubble" when annotation view is selected
            //annotationView?.frame = CGRect(x:0,y:0,width:500,height:500)
            annotationView?.canShowCallout = true
            annotationView?.setSelected(true, animated: false)
        }
        // Set the "pin" image of the annotation view
        let pinImage = #imageLiteral(resourceName: "pin map")
        annotationView?.image = pinImage
        
        let myAnnotation = annotation as! myMapPin
        let leftCalloutImageView = UIImageView(frame: CGRect(x:0,y:0,width:50,height:50))
        leftCalloutImageView.image = myAnnotation.image
        annotationView?.leftCalloutAccessoryView = leftCalloutImageView
        
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        UIView.animate(withDuration: 0.3, animations:
        {self.toMapButton.isEnabled = false;
            self.toMapButton.alpha = 0})
    }
    
    //send user to app map with the location loaded
    @IBAction func openAppleMap(_ sender: Any) {
        UIApplication.shared.open(self.appleMapsURL!, options: [:], completionHandler: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        //lock oriention
        AppUtility.lockOrientation([.portrait], andRotateTo: .portrait)
    }
    
    //navigation go back
    @IBAction func goBack(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
