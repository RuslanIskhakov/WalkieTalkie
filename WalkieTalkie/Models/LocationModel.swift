//
//  LocationModel.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import CoreLocation
import RxRelay

class LocationModel: BaseModelInitialisable, LocationModelProtocol {
    weak var appModel: AppModelProtocol?

    let lastLocation = BehaviorRelay<LocationBody?>(value: nil)

    private let queue = DispatchQueue(label: "LocationModel", qos: .utility)

    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation


        return locationManager
    }()

    func startTracking() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    func stopTracking() {
        self.locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }
}

extension LocationModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            self.lastLocation.accept(
                LocationBody(
                    latitude: lastLocation.coordinate.latitude,
                    longitude: lastLocation.coordinate.longitude)
            )
        }

    }
}
