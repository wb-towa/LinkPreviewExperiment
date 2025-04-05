//
//  MetadataCache.swift
//  LinkPreviewExperiment
//
//  Created by William B on 5/4/25.
//

import Foundation
import SwiftUI
import LinkPresentation



func getCacheDirectory() -> URL? {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    let cacheDir = paths[0].appendingPathComponent("MDCache")

    if !FileManager.default.fileExists(atPath: cacheDir.path) {
        do {
            try FileManager.default.createDirectory(atPath: cacheDir.path, withIntermediateDirectories: true)
        } catch {
            return nil
        }
    }
    return cacheDir
}

/**
 Original version relied on coredata and loading the data into an observed object rather than functions that just return it.

 So, this is a slightly rough first pass on converting it.

 The forced unwraps in the current use case are fine.

 Static functions only to possibly make it more readable elsewhere

 */
final class MetadataCache {

    static func set(for id: String, metadata: LPLinkMetadata) {

        do {
            guard let cacheDir = getCacheDirectory() else {
                print("could not get cache directory")
                return
            }

            let fileURL = cacheDir.appendingPathComponent("\(id).md")

            let data = try NSKeyedArchiver.archivedData(withRootObject: metadata, requiringSecureCoding: true)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("failed to save metadata to cache: \(error.localizedDescription)")
        }
    }

    static func get(for bookmark: Bookmark) async -> LPLinkMetadata {

        guard let cacheDir = getCacheDirectory() else {
            print("could not get cache directory")
            return LPLinkMetadata()
        }

        let fileURL = cacheDir.appendingPathComponent("\(bookmark.id).md")
        do {
            let d = try Data(contentsOf: fileURL)
            let metadata = try? NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: d)
            if let metadata {
                print("loaded metadata from cache")
                return metadata
            }
        } catch {
            print("metadata cache get failed: \(error.localizedDescription)")
            let freshMetadata = await MetadataCache.load(url: bookmark.url!)
            MetadataCache.set(for: bookmark.id, metadata: freshMetadata)
            return freshMetadata
        }
        return LPLinkMetadata()
    }

    static func empty() {
        guard let cacheDir = getCacheDirectory() else {
            print("could not get cache directory")
            return
        }
        for bookmark in bookmarks {
            let fileURL = cacheDir.appendingPathComponent("\(bookmark.id).md")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try? FileManager.default.removeItem(atPath: fileURL.path)
            }
        }
    }

    static func load(url: URL) async -> LPLinkMetadata {
        do {
            let metadata = try await withCheckedThrowingContinuation { @Sendable (continuation: CheckedContinuation<LPLinkMetadata, any Error>) in
                LPMetadataProvider().startFetchingMetadata(for: url) { lpLinkMetadata, error in
                    if let error { continuation.resume(throwing: error) }
                    if let lpLinkMetadata {
                        nonisolated(unsafe) let metadata = lpLinkMetadata
                        continuation.resume(returning: metadata)
                    }
                }
            }
            return metadata
        } catch {
            print("error: \(error.localizedDescription)")
        }
        return LPLinkMetadata()
    }
}
