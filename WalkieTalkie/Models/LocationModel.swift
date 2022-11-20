//
//  LocationModel.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import CoreLocation
import RxSwift
import RxRelay

class LocationModel: BaseModelInitialisable, LocationModelProtocol {
    weak var appModel: AppModelProtocol?

    let lastLocation = BehaviorRelay<LocationBody?>(value: nil)
    let peerDistance = BehaviorRelay<Int?>(value: nil)

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

    func requestPermission() {
        self.locationManager.requestAlwaysAuthorization()
    }

    func startTracking() {

        self.queue.async {[unowned self] in
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()

            self.appModel?.serverModel.clientLocation
                .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
                .observe(on: SerialDispatchQueueScheduler(qos: .utility))
                .subscribe(onNext: { [weak self] location in
                    guard let self, let _lastLocation = self.lastLocation.value else { return }
                    let lastLocation = CLLocation(
                        latitude: _lastLocation.latitude,
                        longitude: _lastLocation.longitude
                    )
                    let peerLocation = CLLocation(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                    self.peerDistance.accept(
                        Int(lastLocation.distance(from: peerLocation))
                    )
                })
                .disposed(by: self.disposeBag)
        }
    }

    func stopTracking() {
        self.queue.async {[unowned self] in
            self.peerDistance.accept(nil)
            self.disposeBag = DisposeBag()
            self.locationManager.stopUpdatingLocation()
            self.locationManager.stopMonitoringSignificantLocationChanges()
        }
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
