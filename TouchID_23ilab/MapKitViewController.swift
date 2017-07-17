//
//  MapKitViewController.swift
//  TouchID_23ilab
//
//  Created by Bruno Augusto Mendes Barreto Alves on 15/07/2017.
//  Copyright © 2017 Bruno Augusto Mendes Barreto Alves. All rights reserved.
//

import UIKit
import MapKit

enum ErrorMap : Error {
    case CouldNotFindAddress
}

class MapKitViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    let locationManager = CLLocationManager()
    var routeIsSet = false
    var location = CLLocationCoordinate2D()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        self.map.delegate = self
        
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.requestWhenInUseAuthorization()
    
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }
   
    @IBAction func findTheAddress(_ sender: UITextField) {
        map.removeOverlays(map.overlays)
        map.removeAnnotations(map.annotations)
        
        if sender.text != ""{
            self.getCoordinateFromAddress(address: sender.text!, completion: { (location, error) in
                
                    guard let loc = location else{
                        self.presentAlert(message: "Was not possible to find a address!")
                        return
                    }
                    self.setRoute(latSource: self.location.latitude, longSource: self.location.longitude, latDestination: loc.coordinate.latitude, longDestination: loc.coordinate.longitude)
               
                
            })

        }else{
            self.presentAlert(message: "Please insert the correct address!")
        }
    }
    
    
    func setRoute(latSource: CLLocationDegrees, longSource: CLLocationDegrees, latDestination: CLLocationDegrees, longDestination: CLLocationDegrees){
    
        let sourceLocation = CLLocationCoordinate2D(latitude: latSource, longitude: longSource)
        let destinationLocation = CLLocationCoordinate2D(latitude: latDestination, longitude: longDestination)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "You are Here!"
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
       
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "Going Here!"
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.map.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )

        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
       
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    self.presentAlert(message: error.localizedDescription)
                }
                return
            }
            
            let route = response.routes[0]
            self.map.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.map.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
        
    }
    
    
    func getCoordinateFromAddress(address: String, completion: @escaping (_ location: CLLocation?,_ err: Error?) -> Void) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let loc = placemarks.first?.location
                else {
                    completion(nil,error!)
                    return
            }
            completion(loc,nil)
            
        }
    }
    
    func presentAlert(message: String){
        
        let alert = UIAlertController(title: "Warning!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: MKMapViewDelegate functions
extension MapKitViewController: MKMapViewDelegate{

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
}

// MARK: CLLocationManagerDelegate functions
extension MapKitViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        if !routeIsSet {
            location = locValue
            self.setRoute(latSource: locValue.latitude,longSource: locValue.longitude, latDestination: 47.126739, longDestination: 9.523817)
            routeIsSet = true
        }
    }

}

// MARK: UITextFieldDelegate functions
extension MapKitViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
