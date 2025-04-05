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
    let bookmark: Bookmark

    let onAction: () -> Void

    var body: some View {
        VStack {
            Button(action: {
                onAction()
            }) {
                LinkPreview(bookmark: bookmark)
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

    let bookmark: Bookmark

    func makeUIView(context: UIViewRepresentableContext<LinkPreview>) -> LinkPreview.UIViewType {
        let slp = SizableLinkPreview(metadata: LPLinkMetadata())
        return slp
    }

    func updateUIView(_ uiView: LinkPreview.UIViewType, context: UIViewRepresentableContext<LinkPreview>) {

        getMetadata(bookmark: bookmark, uiView: uiView)
    }

    private func getMetadata(bookmark: Bookmark, uiView: LinkPreview.UIViewType) {
        // a bit sad but it gets the job done for now
        Task {
            let metadata = await MetadataCache.get(for: bookmark)
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

    override init(metadata: LPLinkMetadata) {
        super.init(metadata: metadata)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.width, height: frame.height)
    }
}
