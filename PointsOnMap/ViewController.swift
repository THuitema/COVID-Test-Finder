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


class ViewController: UIViewController, MKMapViewDelegate, FloatingPanelControllerDelegate {
    var locationLatitude = 0.0
    var locationLongitude = 0.0
    
    //@IBOutlet var mapView: MKMapView!
    @IBOutlet weak var mapView: MKMapView!
//    @IBOutlet weak var directionButton: UIButton!
    
    @IBOutlet weak var directionButton: UIButton!
    @IBAction func buttonClicked(_ sender: Any) {
        print("clicked")
        
//        let latitude = view.annotation?.coordinate.latitude
//        let longitude = view.annotation?.coordinate.longitude
        print(locationLatitude ?? 0.0)
        print(locationLongitude ?? 0.0)
        openMap(lat: locationLatitude, long: locationLongitude, name: "HI")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loading in data from CSV file
        var csv_data = readDataFromCSV(fileName: "locations2", fileType: "csv")
        csv_data = cleanRows(file: csv_data ?? "")
        var csvRows = csv(data: csv_data ?? "")
        csvRows.removeFirst()
        csvRows.removeLast()
        let data = csvRows
        
        // Plotting each location

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
                
                
//                print(Double(lat ?? 0.0))
//                print(Double(long ?? 0.0))
                
                let pin = customPin(pinTitle: name,
                                    location: CLLocationCoordinate2D(latitude: Double(lat ?? 0.0), longitude: Double(long ?? 0.0)),
                                    phone: phone,
                                    address: address)
                
                
                self.mapView.addAnnotation(pin)
                self.mapView.delegate = self
            }
            
            i += 1
        }
        zoomToZipCode(zipcode: "22033")
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
        
        locationLatitude = view.annotation?.coordinate.latitude ?? 0.0
        locationLongitude = view.annotation?.coordinate.longitude ?? 0.0

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
            let address = String(subtitle ?? "").split(separator: "|")[1]
            let latitude = Double(view.annotation?.coordinate.latitude ?? 0.0)
            let longitude = Double(view.annotation?.coordinate.longitude ?? 0.0)
            
            
            // Set the 'click here' substring to be the link
            
            contentVC.data = [String(title ?? ""),
                              String(phone ?? ""),
                              String(address ?? ""),
                ]
        }
        else {
            print("hmm")
        }
        

                        
        fpc.set(contentViewController: contentVC)
        fpc.addPanel(toParent: self, animated: true)
    }
    // This function zooms into the given zipcode during the app startup
    func zoomToZipCode(zipcode: String) {
        // Zooming into zipcode
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(zipcode, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error)
            }
            if let placemark = placemarks?.first {
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                // zooms into a 50 x 50 km square
                let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 100000, longitudinalMeters: 100000)
                self.mapView.setRegion(region, animated: true)
            }
        })
    }
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
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


    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";;", with: "")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";\n", with: "")
        return cleanFile
    }
    
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
        mapItem.name = "Hello"
        mapItem.openInMaps(launchOptions: options)

    }
}


