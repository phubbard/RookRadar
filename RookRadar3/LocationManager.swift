//
//  LocationManager.swift
//  RookRadar3
//
//  Created by Paul Hubbard on 12/8/24.
//



import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var location: String = "Fetching location..."
    @Published var beaconEvents: [String] = [] // Logs for beacon events

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization() // Required for iBeacon monitoring
        locationManager.startUpdatingLocation()
    }
    
    // Add iBeacon region monitoring
    func startMonitoringBeacons() {
        let beaconRegions = [
            CLBeaconRegion(uuid: UUID(uuidString: "UUID-1-HERE")!, identifier: "Home"),
            CLBeaconRegion(uuid: UUID(uuidString: "UUID-2-HERE")!, identifier: "Office"),
            CLBeaconRegion(uuid: UUID(uuidString: "UUID-3-HERE")!, identifier: "Car")
        ]

        for region in beaconRegions {
            locationManager.startMonitoring(for: region)
            locationManager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: region.uuid))
        }
    }
    
    // Handle entering a beacon region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            DispatchQueue.main.async {
                self.beaconEvents.append("Entered region: \(beaconRegion.identifier)")
            }
        }
    }

    // Handle exiting a beacon region
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            DispatchQueue.main.async {
                self.beaconEvents.append("Exited region: \(beaconRegion.identifier)")
            }
        }
    }

    // Handle ranging beacons
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], satisfying constraint: CLBeaconIdentityConstraint) {
        for beacon in beacons {
            DispatchQueue.main.async {
                let proximity = self.proximityString(for: beacon.proximity)
                self.beaconEvents.append("Ranged beacon: UUID \(constraint.uuid), Proximity: \(proximity)")
            }
        }
    }

    private func proximityString(for proximity: CLProximity) -> String {
        switch proximity {
        case .immediate: return "Immediate"
        case .near: return "Near"
        case .far: return "Far"
        default: return "Unknown"
        }
    }
}


