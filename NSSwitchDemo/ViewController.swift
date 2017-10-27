//
//  ViewController.swift
//

import Cocoa
import MapKit
import NSSwitch
import CoreLocation

class ViewController: NSViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func toggleSwitch(_ sender: NSSwitch) {
        if let id = sender.identifier {
            let newState = sender.on
            if (id.rawValue == "traffic") {
                mapView.showsTraffic = newState
            } else if (id.rawValue == "buildings") {
                mapView.showsBuildings = newState
            } else if (id.rawValue == "compass") {
                mapView.showsCompass = newState
            } else if (id.rawValue == "pointsOfInterest") {
                mapView.showsPointsOfInterest = newState
            }
        }
    }
    
    @IBAction func searchFieldChanged(_ sender: NSSearchField) {
        let query = sender.stringValue
        search(naturalLanguageQuery: query)
    }
    
    func search(naturalLanguageQuery: String) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = naturalLanguageQuery
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            if let mapItems = response?.mapItems {
                self.updateDisplay(mapItems: mapItems)
            }
        }
    }
    
    func updateDisplay(mapItems: [MKMapItem]) {
        if let coord = mapItems.first?.placemark.coordinate {
            let latDelta = 0.5
            let lonDelta = 0.5
            self.updateRegion(center: coord, latDelta: latDelta, lonDelta: lonDelta)
        }
    }
    
    func updateRegion(center: CLLocationCoordinate2D, latDelta: CLLocationDegrees, lonDelta: CLLocationDegrees) {
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }

    @IBAction func segmentedControlChanged(_ sender: NSSegmentedControl) {
        let index = sender.selectedSegment
        if (index == 0) {
            mapView.mapType = .standard
        } else {
            mapView.mapType = .hybrid
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsPointsOfInterest = false
        mapView.showsCompass = false
        mapView.showsBuildings = false
        mapView.showsTraffic = false
    }
}
