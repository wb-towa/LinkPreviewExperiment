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
                ForEach(bookmarks, id: \.id) { bookmark in
                    ListRow(bookmark: bookmark) {
                        onCopy(for: bookmark.url)
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
