//
//  ContentView 2.swift
//  RookRadar3
//
//  Created by Paul Hubbard on 1/5/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var isMonitoring = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Beacon Monitoring Demo")
                .font(.headline)

            Toggle("Monitoring", isOn: $isMonitoring)
                .onChange(of: isMonitoring) { newValue in
                    if newValue {
                        locationManager.startMonitoring()
                    } else {
                        locationManager.stopMonitoring()
                    }
                }
                .padding()

            // Show a list of all the logged events
            List(locationManager.eventLogs) { event in
                VStack(alignment: .leading) {
                    Text("\(event.timestamp.formatted(date: .abbreviated, time: .standard))")
                    Text("\(event.eventType) - \(event.regionIdentifier)")
                        .bold()
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}
