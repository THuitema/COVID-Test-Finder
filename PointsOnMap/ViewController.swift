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
import FloatingPanel

 
class customPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var latitude: Double
    var longitude: Double
    var phone: String
    var address: String
    
    init(pinTitle:String, location:CLLocationCoordinate2D, phone:String, address:String) {
        self.title = pinTitle
        self.coordinate = location
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.phone = phone
        self.address = address
        self.subtitle = "Phone: " + phone + " | Address: " + address
    }
    
    
}


class ViewController: UIViewController, MKMapViewDelegate, FloatingPanelControllerDelegate, UISearchBarDelegate {
    // Global Variables
    var data: Array<Array<String>> = []
    
    var locationLatitude = 0.0
    var locationLongitude = 0.0
    var name: String = " "
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var directionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        // Loading in data from CSV file
        var csv_data = readDataFromCSV(fileName: "locations2", fileType: "csv")
        csv_data = cleanRows(file: csv_data ?? "")
        var csvRows = csv(data: csv_data ?? "")
        csvRows.removeFirst()
        csvRows.removeLast()
        data = csvRows

        // Initial zoom to show all of Virginia
        let latitute:CLLocationDegrees = 39.5
        let longitute:CLLocationDegrees = -79.0
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 750000, longitudinalMeters: 750000)
        self.mapView.setRegion(region, animated: true)
        

    }
    
    func plotPins(data: Array<Array<String>>, zipLat: Double, zipLong: Double) {
        // Remove any existing pins on map
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        // Making a coordinate box 20 km wide around zip code entered
        let latMin = zipLat - (10000 / 1000 / 111)
        let latMax = zipLat + (10000 / 1000 / 111)
        let longMin = zipLong - (10000 / 1000 / 111)
        let longMax = zipLong + (10000 / 1000 / 111)
       
        var i = 0
        while(i < data.count) { // data.count
            let name = data[i][0]
            let address = data[i][1]
            let phone = data[i][2]


            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) {
                placemarks, error in
                let placemark = placemarks?.first
                let lat = placemark?.location?.coordinate.latitude
                let long = placemark?.location?.coordinate.longitude
                let pin = customPin(pinTitle: name,
                                    location: CLLocationCoordinate2D(latitude: Double(lat ?? 0.0), longitude: Double(long ?? 0.0)),
                                    phone: phone,
                                    address: address)
                
                // Plotting point only if it is within frame
                if (lat ?? 0.0 >= latMin && lat ?? 0.0 <= latMax && long ?? 0.0 >= longMin && long ?? 0.0 <= longMax) {
                    self.mapView.addAnnotation(pin)
                }

                self.mapView.delegate = self
            }

            i += 1
        }
    }
    
    // Receives user input from search bar, zooms into zip code if valid
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let zipCode: String = searchBar.text ?? ""
        print(zipCode)
        searchBar.endEditing(true) // Hides keyboard after pressing search
        
        // Getting coordinates of zip code
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(zipCode, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Invalid Zip Code")
                print(error)
            }
            
            if let placemark = placemarks?.first {
                let latitude = placemark.location?.coordinate.latitude ?? 0.0
                let longitude = placemark.location?.coordinate.longitude ?? 0.0
                let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
                
                self.zoomToZipCode(coordinates: coordinates)
                self.plotPins(data: self.data, zipLat: latitude, zipLong: longitude)
            }
        })
    }
    
    // This function zooms into the given zipcode during the app startup
    func zoomToZipCode(coordinates: CLLocationCoordinate2D) {
        // Zooming into zipcode
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 25000, longitudinalMeters: 25000)
        self.mapView.setRegion(region, animated: true)
    }
    
    // This function creates a popup box above pins when clicked
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.image = UIImage(named:"pin")
        annotationView.canShowCallout = true
        return annotationView
    }
    
    // When user clicks a pin
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        let fpc = FloatingPanelController()
        fpc.hide()
        fpc.delegate = self
        
        directionButton.isHidden = false
        directionButton.isEnabled = true
        directionButton.alpha = 1.0;
        
        locationLatitude = view.annotation?.coordinate.latitude ?? 0.0
        locationLongitude = view.annotation?.coordinate.longitude ?? 0.0
        name = ((view.annotation?.title ?? " hi") ?? " ")
        
        guard let contentVC = storyboard?.instantiateViewController(identifier: "fpc_content") as? ContentViewController
        else {
            return
        }
        
        var title = view.annotation?.title ?? ""
        var subtitle = view.annotation?.subtitle ?? ""
        
        
        if var title = view.annotation?.title, var subtitle = view.annotation?.subtitle { //
            title = String(title ?? "Title")
            subtitle = String(subtitle ?? "Info")
            
            let phone = String(subtitle ?? "").split(separator: "|")[0]
            var address = String(subtitle ?? "").split(separator: "|")[1]
            let latitude = Double(view.annotation?.coordinate.latitude ?? 0.0)
            let longitude = Double(view.annotation?.coordinate.longitude ?? 0.0)
            
            address.remove(at: address.startIndex) // removes space at beginning of address
            address.insert("\n", at: address.index(address.startIndex, offsetBy: 9)) // Putting address on new line after "Address: "

            // Setting rows in floating panel to location data
            contentVC.data = [String(title ?? ""),
                              String(phone ?? ""),
                              String(address ?? ""),
                ]
        }
        
        else {
            print("hmm... something's wrong")
        }
        
        fpc.set(contentViewController: contentVC)
        fpc.addPanel(toParent: self, animated: true)
    }
    
    // Open apple maps when clicking "directions" button
    func openMap(lat: Double, long: Double, name: String) {

        let latitute:CLLocationDegrees = lat
        let longitute:CLLocationDegrees = long

        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: options)

    }
    
    // Directions button clicked
    @IBAction func buttonClicked(_ sender: Any) {
        openMap(lat: locationLatitude, long: locationLongitude, name: name)
    }
    
    // reading csv data
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
    // reading csv data
    func readDataFromCSV(fileName:String, fileType: String)-> String!{
            guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
                else {
                    return nil
            }
            do {
                var contents = try String(contentsOfFile: filepath, encoding: .utf8)
                contents = cleanRows(file: contents)
                return contents
            } catch {
                print("File Read Error for file \(filepath)")
                return nil
            }
        }

    // cleaning csv data
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
}


