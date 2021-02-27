//
//  ViewController.swift
//  PointsOnMap
//
//  Created by Thomas Huitema on 2/26/21.
//

import UIKit
import MapKit
import Foundation
import CoreLocation


class customPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(pinTitle:String, pinSubtitle:String, location:CLLocationCoordinate2D) {
        self.title = pinTitle
        self.subtitle = pinSubtitle
        self.coordinate = location
    }
}

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Determine the file name
        let filename = Bundle.main.path(forResource: "addresses", ofType: "txt")

         //Read the contents of the specified file
        let contents = try! String(contentsOfFile: filename ?? "instance is nil")

        // Split the file into separate lines
        let lines = contents.split(separator:"\n")
        
        // Plotting each location
        var i = 0
        while(i < lines.count) {
            let latitude_line: String = String(lines[i])
            let longitude_line: String = String(lines[i + 1])
            let latitude: Double? = Double(latitude_line)
            let longitude: Double? = Double(longitude_line)
            
            let pin = customPin(pinTitle: "School", pinSubtitle: "a school", location: CLLocationCoordinate2D(latitude: latitude ?? 0.0, longitude: longitude ?? 0.0))
            
            self.mapView.addAnnotation(pin)
            self.mapView.delegate = self
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude ?? 0.0, longitude: longitude ?? 0.0)
//            annotation.title = "School"
//           // createInfoBox(annotation: annotation)
//            self.mapView.addAnnotation(annotation)
            i += 2

        }
        
        zoomToZipCode(zipcode: "22033")
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.image = UIImage(named:"pin")
        annotationView.canShowCallout = true
        
        let button = UIButton(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = button
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let ac = UIAlertController(title: "School", message: "info", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func zoomToZipCode(zipcode: String) {
        // Zooming into zipcode
        let geocoder = CLGeocoder()
        //let zipcode = "22033" // hard-coded zipcode for now, maybe later let user enter theirs
        
        geocoder.geocodeAddressString(zipcode, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error)
            }
            if let placemark = placemarks?.first {
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                // zooms into a 50 x 50 km square
                let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 50000, longitudinalMeters: 50000)
                self.mapView.setRegion(region, animated: true)
            }
        })
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        let identifier = "School"
//
//        var annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//        annotationView.canShowCallout = true
//
//        let button = UIButton(type: .detailDisclosure)
//        annotationView.rightCalloutAccessoryView = button
//
//        mapView.showAnnotations(annotationView, animated: true)
//        return annotationView
//    }
    }
}
