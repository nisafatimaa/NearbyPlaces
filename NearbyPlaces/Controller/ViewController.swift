//
//  ViewController.swift
//  NearbyPlaces
//
//  Created by Macbook Pro on 08/06/2024.
//
/* CLLocationManager deals with all location data dealing.
 MKMapView is embedded map interface.
 */
import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView : MKMapView!
    
    var LocationManager = CLLocationManager()
    var placeSearchController = UISearchController()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        setupSearchBar()
        setupLocation()
        mapViewSetup()
    }
    
    func setupLocation(){
        LocationManager.delegate = self
            //user permission to use location
            LocationManager.requestWhenInUseAuthorization()
            //best accuracy
            LocationManager.desiredAccuracy = kCLLocationAccuracyBest
            //for currentlocation
            LocationManager.startUpdatingLocation()
    }
    
    func mapViewSetup(){
        mapView.delegate = self
        //for continuous tracking of location
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
    }
    
    func setupSearchBar() {
        
        let resultTableViewController = storyboard?.instantiateViewController(withIdentifier: K.tVCIdentifier) as? ResultTableViewController
        placeSearchController = UISearchController(searchResultsController: resultTableViewController)
        //the object which will show content of results
        placeSearchController.searchResultsUpdater = resultTableViewController
        resultTableViewController?.mapView = mapView
        
        let searchBar = placeSearchController.searchBar
        searchBar.placeholder = K.searchBarPlaceholder
        searchBar.showsCancelButton = true
        navigationItem.searchController = placeSearchController
        navigationItem.hidesSearchBarWhenScrolling = false 
        searchBar.sizeToFit()
    }
    
    func centreOnUserLoction() {
        if let location = LocationManager.location?.coordinate {
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion.init(center: location, span: span)
        mapView.setRegion(region, animated: true)
     }
   }
}



// MARK: - Location Manager Delegate & Map View Delegate
extension ViewController : CLLocationManagerDelegate , MKMapViewDelegate{
    //it is constantly being called to keep accuratte coordinates and we get array of locations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            //we extract coordinates of recent location and create a MKCoordinateRegion for mapView
            //where map will be centered
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            //height and width of visible region
            let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            
            let region = MKCoordinateRegion.init(center: center, span: span)
            
            mapView.setRegion(region, animated: true)
        }
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            centreOnUserLoction()
        }
    }
}
