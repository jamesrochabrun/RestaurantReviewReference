//
//  YelpSearchController.swift
//  RestaurantReviews
//
//  Created by Pasan Premaratne on 5/9/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import UIKit
import MapKit

class YelpSearchController: UIViewController {
    
    // MARK: - Properties
    lazy var locationManager: LocationManager = {
        return LocationManager(delegate: self, permissionDelegate: nil)
    }()
    
    lazy var client: YelpClient = {
        let yelpAccount = YelpAccount.loadFromKeychain()
        //if its nil provide a popup to ask for permisson, dont force unwrapp like this
        let oauthToken = yelpAccount!.accessToken
        return YelpClient(oauthToken: oauthToken)
    }()
    
    var coordinate: Coordinate? {
        didSet {
            if let coordinate = coordinate {
                self.showNearbyRestaurants(at: coordinate)
            }
        }
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var tableView: UITableView!
    
    let dataSource = YelpSearchResultsDataSource()
    
    var isAuthorized: Bool {
        let isAuthorizedWithYelpToken = YelpAccount.isAuthorized
        let isAuthorizedForLocation = LocationManager.isAuthorized
        return isAuthorizedWithYelpToken && isAuthorizedForLocation
    }

    let queue = OperationQueue()
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupTableView()
        //KVO
       // addObserver(self, forKeyPath: #keyPath(YelpBusinessDetailsOperation.isFinished), options: [.new, .old], context: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isAuthorized {
            locationManager.requestLocation()
        } else {
            checkPermissions()
        }
    }
    
    // MARK: - Table View
    func setupTableView() {
        self.tableView.dataSource = dataSource
        self.tableView.delegate = self
    }
    
    // MARK: - client method to load nearby restaurants
    fileprivate func showNearbyRestaurants(withTerm term: String = "", at coordinate: Coordinate) {
        
        client.search(withTerm: term, at: coordinate) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let businesses):
                strongSelf.dataSource.update(with: businesses)
                strongSelf.tableView.reloadData()
                
                strongSelf.mapView.removeAnnotations(strongSelf.mapView.annotations)
                let annotations: [MKPointAnnotation] = businesses.map { business   in
                    let point = MKPointAnnotation()
                    point.coordinate = CLLocationCoordinate2D(latitude: business.location.latitude, longitude: business.location.longitude)
                    
                    point.title = business.name
                    point.subtitle = business.isClosed ? "Closed" : "Open"
                    return point
                }
                
                strongSelf.mapView.addAnnotations(annotations)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Search
    func setupSearchBar() {
        self.navigationItem.titleView = searchController.searchBar
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
    }
    
    // MARK: - Permissions
    
    /// Checks (1) if the user is authenticated against the Yelp API and has an OAuth
    /// token and (2) if the user has authorized location access for whenInUse tracking.
    func checkPermissions() {
        
        let isAuthorizedForLocation = LocationManager.isAuthorized
        let isAuthorizedWithToken = YelpAccount.isAuthorized
        
        let permissionsController = PermissionsController(isAuthorizedForLocation: isAuthorizedForLocation, isAuthorizedWithToken: isAuthorizedWithToken)
        present(permissionsController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension YelpSearchController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let business = dataSource.object(at: indexPath)
        
        let detailsOperation = YelpBusinessDetailsOperation(business: business, client: self.client)
        let reviewsOperation = YelpBusinessReviewsOperation(business: business, client: self.client)
        reviewsOperation.addDependency(detailsOperation)
        
        reviewsOperation.completionBlock = {
            DispatchQueue.main.async {
                self.dataSource.update(business, at: indexPath)
                self.performSegue(withIdentifier: "showBusiness", sender: self)
            }
        }
        queue.addOperation(detailsOperation)
        queue.addOperation(reviewsOperation)
    }
}

// MARK: - Search Results
extension YelpSearchController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchTerm = searchController.searchBar.text, let coordinate = coordinate else { return }
        
        if !searchTerm.isEmpty {
            self.showNearbyRestaurants(withTerm: searchTerm, at: coordinate)
        }
    }
}

// MARK: - Navigation
extension YelpSearchController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBusiness" {
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let business = dataSource.object(at: indexPath)
                if let detailController = segue.destination as? YelpBusinessDetailController {
                    detailController.business = business
                    detailController.dataSource.updateData(business.reviews)
                }
            }
        }
    }
}

//MARK: Location manager delegate
extension YelpSearchController: LocationManagerDelegate {
    
    func obtainedCoordinates(_ coordinate: Coordinate) {
        self.coordinate = coordinate
        adjustMap(wit: coordinate)
    }
    
    func failedWithError(_ error: LocationError) {
        
    }
}

//MARK: Observer
extension YelpSearchController {
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//
//    }
}


//MARK: MpaKit
extension YelpSearchController {
    
    func adjustMap(wit coordinate: Coordinate) {
        
        let coordinate2D = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let span = MKCoordinateRegionMakeWithDistance(coordinate2D, 2500, 2500)
    .span ///zoom
        let region = MKCoordinateRegion(center: coordinate2D, span: span)
        mapView.setRegion(region, animated: true)
        
    }
}











