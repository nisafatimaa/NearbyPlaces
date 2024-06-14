//
//  ResultTableViewController.swift
//  NearbyPlaces
//
//  Created by Macbook Pro on 09/06/2024.
//

import UIKit
import MapKit

class ResultTableViewController: UITableViewController {

    var matchingLocations : [MKMapItem] = []
    var mapView : MKMapView?
    
// MARK: - Table View DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingLocations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.tVCCIdentifier, for: indexPath)
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = matchingLocations[indexPath.row].name
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = matchingLocations[indexPath.row].name
        }
        return cell
    }
    
    
    
// MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: K.seguaIdentifier, sender: indexPath)
    }
    //perfoms segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.seguaIdentifier ,
            let nextScene = segue.destination as? DetailsViewController ,
            let indexPath = self.tableView.indexPathForSelectedRow {
            let selectedRow = matchingLocations[indexPath.row]
            nextScene.mapData = selectedRow
        }
    }
}



// MARK: - search Result Updating
//it contain methods that helps in using results of information that user adds in search bar
extension ResultTableViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let map = mapView , let searchBarText = searchController.searchBar.text else {
            fatalError("no text in searchbar or no map")
        }
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBarText
        searchRequest.region = map.region
        
        let result = MKLocalSearch(request: searchRequest)
        result.start { response, error in
            if let response = response {
                self.matchingLocations = response.mapItems
                self.tableView.reloadData()
            }
        }
    }
}
