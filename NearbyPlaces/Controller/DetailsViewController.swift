//
//  DetailsViewController.swift
//  NearbyPlaces
//
//  Created by Macbook Pro on 10/06/2024.
//

import UIKit
import MapKit
import CoreLocation

class DetailsViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet var detailsTable: UITableView!
    @IBOutlet var mapView: MKMapView!
    
    //show pin on map using this item placemark
    var mapData : MKMapItem?
    var categoryData : [MKMapItem] = []
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        
        locationManager.delegate = self
        getLocations(K.resturant)
    
        navigationItem.title = K.navTitle
    }
    
    
    func getLocations(_ categoryName : String) {
        categoryData = []
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = categoryName
        searchRequest.region = mapView.region
        
        let results = MKLocalSearch(request: searchRequest)
        results.start { [self] response, error in
            if let response = response {
                categoryData = response.mapItems
                detailsTable.reloadData()
            }
        }
    }
    
    func setupMapView(){
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        if mapData != nil {
            drawPinOnMap(mapData!)
        }
    }
    
    //adds pin on the location that we pass from resultsTableViewController
    func drawPinOnMap(_ item : MKMapItem){
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.title = item.name
        annotation.coordinate = item.placemark.coordinate

        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
    }

    
    // MARK: - Buttons
    @IBAction func resturantClicked(_ sender: UIButton) {
        getLocations(K.resturant)
    }
    
    @IBAction func groceryClicked(_ sender: UIButton) {
        getLocations(K.grocery)
    }
    
    @IBAction func parksClicked(_ sender: UIButton) {
        getLocations(K.park)
    }
    
    @IBAction func shoppingClicked(_ sender: UIButton) {
        getLocations(K.shopping)
    }
    
    @IBAction func ATMClicked(_ sender: UIButton) {
        getLocations(K.atm)
    }
    
    @IBAction func pharmacyClicked(_ sender: UIButton) {
        getLocations(K.pharmacy)
    }
}
    



// MARK: - Map View Delegate
extension DetailsViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            //it strokes the line for route
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.lineWidth = 5
            renderer.strokeColor = .blue
            return renderer
        }
        return MKCircleRenderer(overlay: overlay)
    }
}



// MARK: - Table View Datasource
extension DetailsViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.detailsTVCIdentifier, for: indexPath)
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = categoryData[indexPath.row].name
            content.secondaryText = categoryData[indexPath.row].phoneNumber
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = categoryData[indexPath.row].name
            cell.detailTextLabel?.text = categoryData[indexPath.row].phoneNumber
        }
        return cell
    }
}



// MARK: - Table View Delegate
extension DetailsViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = categoryData[indexPath.row].placemark.coordinate
        showDirections(destinationCoordinate: selectedItem)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //requesting for route
    func showDirections(destinationCoordinate: CLLocationCoordinate2D) {
        guard let userLocation = locationManager.location else {
            fatalError("cannot get user location") }

        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil))
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
     
            let result = MKDirections(request: request)
            result.calculate { [self] response, error in
                if let response = response {
                    if let route = response.routes.first {
                        mapView.removeOverlays(mapView.overlays)
                        //polyline shows complete route
                        mapView.addOverlay(route.polyline)
                        mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                    }
                }else {
                    print("error in getting response \(error!)")
                }
            }
        }
    }




