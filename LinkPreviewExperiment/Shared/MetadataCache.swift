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

@Observable final class MetadataCache {

    init() {}

    static func set(for bookmark: Bookmark, metadata: LPLinkMetadata) {
        do {
            if let cacheDir = getCacheDirectory() {
                // TODO: probably shouldn't use markdown extension
                let fileURL = cacheDir.appendingPathComponent("\(bookmark.id).md")

                let data = try NSKeyedArchiver.archivedData(withRootObject: metadata, requiringSecureCoding: true)
                try? data.write(to: fileURL, options: [.atomic])
            }
        } catch let error {
            logger.error("failed to set cache for \(bookmark.id): \(error.localizedDescription)")
        }
    }

    static func get(for bookmark: Bookmark) -> LPLinkMetadata? {
        if let cacheDir = getCacheDirectory() {
            let fileURL = cacheDir.appendingPathComponent("\(bookmark.id).md")
            do {
                let d = try Data(contentsOf: fileURL)
                let metadata = try? NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: d)
                return metadata

            } catch {
                logger.error("failed to get cache for \(bookmark.id): \(error.localizedDescription)")
            }
        }
        return nil
    }

    static func delete(for bookmark: Bookmark) {
        if let cacheDir = getCacheDirectory() {
            let fileURL = cacheDir.appendingPathComponent("\(bookmark.id).md")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try? FileManager.default.removeItem(atPath: fileURL.path)
            }
        }
    }
}

@Observable
@MainActor
final class Metadata {

    // Layout Constants
    let headerHeight: CGFloat = 125
    let previewImageHeight: CGFloat =  125
    // Assets
    var url: String? = nil
    var title: String? = nil
    var image: UIImage? = nil
    var icon: UIImage? = nil
    var dominantColor: UIColor = .darkGray

    private var provider: LPMetadataProvider?
    /**
     Determine if the favicon should be used over the preview image

     This is only needed for the demo where we want to only show either the favicon with
     the dominant color or larger preview image.
     */
    var showFavIcon: Bool {

        guard let icon else {
            // 1. There is no favicon
            return false
        }

        guard let image else {
            // 2. There is no image
            return true
        }

        // Note: this is basically for reddit where it it uses
        // the sub-reddit image as the preview image and it can be up to
        // 10 times wider than its height which can causes the
        // row item to be too wide and really there is no way to make it
        if image.size.width > image.size.height {
            // TODO: cautious about division by zero.
            // It may not be needed as the scenario where width is greater
            // than height while height is 0 seems unlikely.
            // If you use something similar to this demo, this is probably an area to
            // think twice about.
            if (image.size.height > 0) && (image.size.width / image.size.height > 3) {
                return true
            }
        }

        // 3. The icon and the image are the same size, so there really isn't
        // a larger preview image.
        return icon.size == image.size
    }

    var showableImage: UIImage? {
        if !showFavIcon {
            return image
        }
        return nil
    }

    var showableIcon: UIImage? {
        if showFavIcon {
            return icon
        }
        return nil
    }

    var noImageOrIcon: Bool {
        image == nil && icon == nil
    }

    func loadMetadata(bookmark: Bookmark) async throws {

        guard let bookmarkURL = bookmark.url else {
            return
        }

        provider = LPMetadataProvider()

        var tempImage: UIImage?
        var tempIcon: UIImage?
        var tempDominantColor: UIColor = .darkGray


        if let metadata = MetadataCache.get(for: bookmark) {
            logger.debug("cached: yes")
            if let mdTitle = metadata.title {
                self.title = mdTitle
            }
            if let mdHost = metadata.url?.host() {
                self.url = mdHost
            }

            tempImage = try await convertToImage(metadata.imageProvider)

            tempIcon = try await convertToImage(metadata.iconProvider)

        } else {
            logger.debug("cached: no")
            guard let metadata = try? await provider?.startFetchingMetadata(for: bookmarkURL) else {
                return
            }

            try Task.checkCancellation()

                MetadataCache.set(for: bookmark, metadata: metadata)

                if let mdTitle = metadata.title {
                    self.title = mdTitle
                }
                if let mdHost = metadata.url?.host() {
                    self.url = mdHost
                }

            tempImage = try await convertToImage(metadata.imageProvider)

            tempIcon = try await convertToImage(metadata.iconProvider)
        }

        if tempImage != nil {
            tempDominantColor = try await getDominantColor(image: tempImage)
        } else if tempIcon != nil {
            tempDominantColor = try await getDominantColor(image: tempIcon)
        }

        withAnimation {
            dominantColor = tempDominantColor
            image = tempImage
            icon = tempIcon
        }
    }

    private func convertToImage(_ itemProvider: NSItemProvider?) async throws -> UIImage? {
        var uiImage: UIImage?

        if let itemProvider {

            if let type = itemProvider.registeredTypeIdentifiers().first {

                let item = try? await itemProvider.loadItem(forTypeIdentifier: type)

                try Task.checkCancellation()

                if item is UIImage {
                    uiImage = item as? UIImage
                }

                if item is URL {
                    guard let url = item as? URL,
                          let data = try? Data(contentsOf: url) else { return nil }

                    uiImage = UIImage(data: data)
                }

                if item is Data {
                    guard let data = item as? Data else { return nil }

                    uiImage = UIImage(data: data)
                }
            }
        }

        return uiImage
    }

}

/**
 Uses K-Means Clustering to find the dominant color in an image, falling back to a default color upon failure.

 Based off https://dev.to/neriusv/selecting-colors-using-an-image-in-swift-27l9

 I orginally writing something based off Apple libraries

 I may have done something wrong, but I believe you do not want to use the `CIFilter` based K-Means
 functionality found here: https://developer.apple.com/documentation/coreimage/cifilter/3547110-kmeans
 as it appears to blend the colors more giving more of an average dominant color.

 This sample project is more what you would want from what I can tell
 https://developer.apple.com/documentation/accelerate/calculating-the-dominant-colors-in-an-image

 As this was something new to me and that sample project had deprecated code, I've started with something that felt easier to understand
 the whole process. While Ihit issues with the code I've referenced, I've been able to fix it and I have a fuller understanding. It could make
 sense to take learnings from here, look at the specific bits of the Apple demo project and roll your own with Apple's libraries.
 */
func getDominantColor(image: UIImage?, width: CGFloat=100, height: CGFloat=100, fallback: UIColor = .black) async throws -> UIColor {

    if let image {

        let smallImage = image.resized(to: CGSize(width: width, height: height))

        let kMeans = KMeansCluster()

        let points = smallImage.getPixels().map({KMeansCluster.Point(from: $0)})

        let clusters = kMeans.calculate(points: points, into: 6).sorted(by: {$0.points.count > $1.points.count})

        try Task.checkCancellation()

        // TODO: uncomment if you would want all the colors - I just want one
        //let colors = clusters.map(({$0.center.toUIColor()}))

        guard let mainColor = clusters.first?.center.toUIColor() else {
            return fallback
        }
        return mainColor
    }
    return fallback
}
