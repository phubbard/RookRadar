//
//  ContentView 2.swift
//  RookRadar3
//
//  Created by Paul Hubbard on 1/5/25.
//


import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @StateObject private var locationManager: LocationManager
    @State private var isMonitoring = false // Track monitoring state

    init() {
        let manager = LocationManager(context: ModelContext.default)
        _locationManager = StateObject(wrappedValue: manager)
    }

    var body: some View {
        VStack {
            Text("Beacon Events")
                .font(.headline)
                .padding()

            List(locationManager.beaconEvents, id: \.id) { event in
                VStack(alignment: .leading) {
                    Text(event.message)
                    Text(event.timestamp, style: .time)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding()

            Spacer()

            Button(action: {
                toggleMonitoring()
            }) {
                Text(isMonitoring ? "Stop Monitoring" : "Start Monitoring")
                    .padding()
                    .background(isMonitoring ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }

    private func toggleMonitoring() {
        if isMonitoring {
            locationManager.stopMonitoringBeacons()
        } else {
            locationManager.startMonitoringBeacons()
        }
        isMonitoring.toggle()
    }
}