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
        NavigationStack {
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
            .navigationTitle("link preview example")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    Button(role: .destructive, action: {
                        logger.info("deleting cache for \(bookmarks.count) bookmarks")
                        
                        for bookmark in bookmarks {
                            MetadataCache.delete(for: bookmark)
                        }

                    }) {
                        Label("delete cache", systemImage: "trash")
                            .labelStyle(.iconOnly)
                    }
                    .keyboardShortcut("d", modifiers: .control)
                }
            })
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
