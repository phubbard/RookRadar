//
//  LocationManager 2.swift
//  RookRadar3
//
//  Created by Paul Hubbard on 1/5/25.
//

import Foundation
import CoreLocation

struct BeaconEventLog: Identifiable {
    let id = UUID()
    let timestamp: Date
    let eventType: String
    let regionIdentifier: String
}

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()

    /// Holds a list of all beacon events detected.
    @Published var eventLogs: [BeaconEventLog] = []

    /// Define your three beacon regions here.
    /// Replace the UUID strings and identifiers with your actual beacon data.
    private let beaconRegions: [CLBeaconRegion] = [
        CLBeaconRegion(uuid: UUID(uuidString: "426C7565-4368-6172-6D42-6561636F6E73")!, major: 3838, minor: 4949, identifier: "Home"),
        CLBeaconRegion(uuid: UUID(uuidString: "426C7565-4368-6172-6D42-6561636F6E74")!, identifier: "Office"),
        CLBeaconRegion(uuid: UUID(uuidString: "426C7565-4368-6172-6D42-6561636F6E75")!, identifier: "Car")
      ]

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }

    // MARK: - Public Methods

    func startMonitoring() {
        // Start monitoring for each region
        for region in beaconRegions {
            locationManager.startMonitoring(for: region)
        }
    }

    func stopMonitoring() {
        // Stop monitoring for each region
        for region in beaconRegions {
            locationManager.stopMonitoring(for: region)
        }
    }

    func sendStringToServer(_ string: String) {
        // 1. Construct the URL
        guard let url = URL(string: "https://perch.phfactor.net/datum") else {
            print("Invalid URL")
            return
        }

        // 2. Build the request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = string.data(using: .utf8)

        // 3. Create and run the data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle errors
            if let error = error {
                print("Error sending data:", error)
                return
            }

            // Optionally inspect the response
            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code:", httpResponse.statusCode)
            }

            if let data = data,
               let responseBody = String(data: data, encoding: .utf8) {
                print("Response body:", responseBody)
            }
        }

        task.resume()
    }

    /// Placeholder for your future REST call to notify server of beacon enter/exit
    func sendBeaconEventToServer(eventType: String, regionIdentifier: String) {
        // e.g. use URLSession to send an HTTP request
        print("Sending \(eventType) event for \(regionIdentifier) to server...")
        sendStringToServer("\(eventType) \(regionIdentifier)")
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let beaconRegion = region as? CLBeaconRegion else { return }
        let newEvent = BeaconEventLog(
            timestamp: Date(),
            eventType: "ENTER",
            regionIdentifier: beaconRegion.identifier
        )
        eventLogs.append(newEvent)

        // Hook for your REST call
        sendBeaconEventToServer(eventType: "enter", regionIdentifier: beaconRegion.identifier)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let beaconRegion = region as? CLBeaconRegion else { return }
        let newEvent = BeaconEventLog(
            timestamp: Date(),
            eventType: "EXIT",
            regionIdentifier: beaconRegion.identifier
        )
        eventLogs.append(newEvent)

        // Hook for your REST call
        sendBeaconEventToServer(eventType: "exit", regionIdentifier: beaconRegion.identifier)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            // You could automatically start monitoring if you want.
            // startMonitoring()
            break
        default:
            break
        }
    }
}
