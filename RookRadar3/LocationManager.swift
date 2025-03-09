//
//  LocationManager 2.swift
//  RookRadar3
//
//  Created by Paul Hubbard on 1/5/25.
//


import Foundation
import CoreLocation
import SwiftData

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var location: String = "Idle"
    @Published var beaconEvents: [BeaconEvent] = [] // Logs for beacon events
    
    private var context: ModelContext // SwiftData context for persistence
    
    init(context: ModelContext) {
        self.context = context
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        fetchBeaconEvents()
    }

    func fetchBeaconEvents() {
        let fetchRequest = FetchDescriptor<BeaconEvent>()
        do {
            let fetchedEvents = try context.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.beaconEvents = fetchedEvents
            }
        } catch {
            print("Error fetching beacon events: \(error)")
        }
    }

    private func saveEvent(_ message: String) {
        let event = BeaconEvent(timestamp: Date(), message: message)
        context.insert(event)
        do {
            try context.save()
            DispatchQueue.main.async {
                self.beaconEvents.append(event)
            }
        } catch {
            print("Error saving beacon event: \(error)")
        }
    }

    // Handle entering a beacon region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            let message = "Entered \(beaconRegion.identifier)"
            saveEvent(message)
        }
    }

    // Handle exiting a beacon region
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            let message = "Exited \(beaconRegion.identifier)"
            saveEvent(message)
        }
    }

    // Handle ranging beacons
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
        for beacon in beacons {
            let proximity = self.proximityString(for: beacon.proximity)
            let message = "Ranged: accuracy: \(beacon.accuracy) RSSI: \(beacon.rssi) Proximity: \(proximity) at \(timestamp)"
            saveEvent(message)
        }
    }
}