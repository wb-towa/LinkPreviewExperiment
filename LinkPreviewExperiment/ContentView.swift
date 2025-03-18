//
//  ContentView.swift
//  LinkPreviewExperiment
//
//  Created by William B on 17/03/2025.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    var body: some View {
        VStack {
            List {
                ForEach(urls, id: \.self) { url in
                    ListRow(url: url) {
                        onCopy(for: url)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

func onCopy(for url: URL?) {
    UIPasteboard.general.string = url?.absoluteString ?? ""
    AudioServicesPlaySystemSound(1104)
}

#Preview {
    ContentView()
}
