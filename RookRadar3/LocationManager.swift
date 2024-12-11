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
    
    @Published var location: String = "Idle"
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
            CLBeaconRegion(uuid: UUID(uuidString: "426C7565-4368-6172-6D42-6561636F6E73")!, major: 3838, minor: 4949, identifier: "Home"),
            CLBeaconRegion(uuid: UUID(uuidString: "426C7565-4368-6172-6D42-6561636F6E74")!, identifier: "Office"),
            CLBeaconRegion(uuid: UUID(uuidString: "426C7565-4368-6172-6D42-6561636F6E75")!, identifier: "Car")
        ]

        for region in beaconRegions {
            locationManager.startMonitoring(for: region)
            locationManager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: region.uuid, major: region.major?.uint16Value ?? 0,
                                                                                       minor: region.minor?.uint16Value ?? 0))
        }
        location = "Beacon monitoring started..."
    }
    
    // Handle entering a beacon region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            DispatchQueue.main.async {
                let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .long)
                DispatchQueue.main.async {
                    self.beaconEvents.append("Entered region: \(beaconRegion.identifier) at \(timestamp)")
                }
            }
        }
    }

    // Handle exiting a beacon region
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .long)
            DispatchQueue.main.async {
                self.beaconEvents.append("Exited region: \(beaconRegion.identifier) at \(timestamp)")
            }
        }
    }

    // Handle ranging beacons
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .long)

        for beacon in beacons {
            DispatchQueue.main.async {
                let proximity = self.proximityString(for: beacon.proximity)
                self.beaconEvents.append("Ranged beacon: UUID \(beaconConstraint.uuid), Proximity: \(proximity) at \(timestamp)")
            }
        }
    }

    func stopMonitoringBeacons() {
        locationManager.monitoredRegions.forEach { region in
            if let beaconRegion = region as? CLBeaconRegion {
                locationManager.stopMonitoring(for: beaconRegion)
            }
        }

        locationManager.rangedBeaconConstraints.forEach { constraint in
            locationManager.stopRangingBeacons(satisfying: constraint)
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


