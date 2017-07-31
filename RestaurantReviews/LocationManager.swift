//
//  LocationManager.swift
//  RestaurantReviews
//
//  Created by James Rochabrun on 7/30/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import Foundation
import CoreLocation

extension Coordinate {
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
}

protocol LocationPermissionsDelegate: class {
    func authSucceded()
    func authFailedWithStaus(_ status: CLAuthorizationStatus)
}

protocol LocationManagerDelegate: class {
    func obtainedCoordinates(_ coordinate: Coordinate)
    func failedWithError(_ error: LocationError)
}

class LocationManager: NSObject {
    
    private let manager = CLLocationManager()
    weak var permissionDelegate: LocationPermissionsDelegate?
    weak var delegate: LocationManagerDelegate?
    static var isAuthorized: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }
    
    init(delegate: LocationManagerDelegate?, permissionDelegate: LocationPermissionsDelegate?) {
        self.permissionDelegate = permissionDelegate
        self.delegate = delegate
        super.init()
        manager.delegate = self
        //MARK: default but just to show we can modifiy the accuracy
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    //MARK: Asking for permission
    func requestLocationAuthorization() throws {
        
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .restricted || authStatus == .denied {
            throw LocationError.dissallowedByUser
        } else if authStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            return
        }
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            permissionDelegate?.authSucceded()
        } else {
            permissionDelegate?.authFailedWithStaus(status)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        guard let error = error as? CLError else {
            delegate?.failedWithError(.unknownError)
            return
        }
        
        switch error.code {
        case .locationUnknown, .network:
            delegate?.failedWithError(.unableToFindLocation)
        case .denied:
            delegate?.failedWithError(.dissallowedByUser)
        default: return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {
            delegate?.failedWithError(.unableToFindLocation)
            return
        }
        let coordinate = Coordinate(location: location)
        delegate?.obtainedCoordinates(coordinate)
    }
}

enum LocationError: Error {
    
    case unknownError
    case dissallowedByUser
    case unableToFindLocation
    
    
}











