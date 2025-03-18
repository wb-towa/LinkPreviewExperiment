//
//  LinkPreview.swift
//  LinkPreviewExperiment
//
//  Created by William B on 17/03/2025.
//

import SwiftUI
import LinkPresentation


let maxHeight: CGFloat = 245

struct ListRow: View {

    @Environment(\.colorScheme) var colorScheme
    let url: URL?

    let onAction: () -> Void

    var body: some View {
        VStack {
            Button(action: {
                onAction()
            }) {
                LinkPreview(url: url)
                    .frame(height: maxHeight)
                    .disabled(true)
            }
        }
    }
}

/**
 Provides a LPLinkView that

 1. Uses a cache for metadata (Note: currently removed in this version)
 2. Internalize metadata loading by putting it into `updateUIView` (Note: problematic if you don't use caching - seen by scrolling list)

 The goal I'm going for is to optimize for list usage which why the LPLinkPreview ends up disabled in the row and I'm looking for ideal ways to restrict the height.
 */
struct LinkPreview: UIViewRepresentable {
    typealias UIViewType = LPLinkView

    let url: URL?

    func makeUIView(context: UIViewRepresentableContext<LinkPreview>) -> LinkPreview.UIViewType {
        guard let url = url else {
            return SizableLinkPreview()
        }
        let slp = SizableLinkPreview(url: url)
        return slp
    }

    func updateUIView(_ uiView: LinkPreview.UIViewType, context: UIViewRepresentableContext<LinkPreview>) {

        if let url {
            getMetadata(id: UUID(), url: url, uiView: uiView)
        }
    }

    private func getMetadata(id: UUID, url: URL, uiView: LinkPreview.UIViewType) {
        let provider = LPMetadataProvider()

        provider.startFetchingMetadata(for: url) { metadata, error in
            guard let metadata = metadata, error == nil else {
                return
            }
            // TODO: consider adding caching back and its logic here
            //RichLinkCache.set(for: id, metadata: metadata)

            Task { @MainActor in
                uiView.metadata = metadata
                uiView.sizeToFit()
            }
        }
    }
}

/**
 A LPLinkPreview that should adhere to the given frame size
 */
class SizableLinkPreview: LPLinkView {

    init() {
        super.init(frame: .zero)
    }

    override init(url: URL) {
        super.init(url: url)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.width, height: frame.height)
    }
}
