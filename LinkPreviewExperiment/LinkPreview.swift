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


struct LinkPreview: View {

    @Environment(\.colorScheme) var colorScheme

    let bookmark: Bookmark

    @State var pv: Metadata = Metadata()

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 0) {
                LinkHeader(pv: $pv, bookmark: bookmark)
                VStack(alignment: .leading) {
                    Text(pv.title ?? bookmark.title) // TODO: not ideal
                        .bold()
                        .lineLimit(2, reservesSpace: true)
                        .foregroundStyle(Color(pv.dominantColor).adaptedTextColor())
                    Text(bookmark.url?.absoluteString ?? "url-error")
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundStyle(Color(pv.dominantColor).adaptedTextColor().opacity(0.7))
                }
                .padding(8)
            }
        }
        .buttonStyle(.borderless)
        .background(Color(pv.dominantColor))
        .transition(.opacity)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .task(id: bookmark.id) {
            do {
                try await pv.loadMetadata(bookmark: bookmark)
            } catch {
                logger.error("metadata loading error: \(error.localizedDescription)")
            }
        }
    }
}

struct LinkHeader: View {

    @Environment(\.colorScheme) var colorScheme

    @Binding var pv: Metadata

    let bookmark: Bookmark

    var body: some View {
        ZStack {
            previewImage(image: pv.showableImage)

            HStack(alignment: .top) {
                iconImage()
                Spacer()
            }
            .padding([.top, .leading, .trailing])
            .frame(maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: pv.headerHeight,
            alignment: .topLeading
        )
    }

    @ViewBuilder
    func iconImage() -> some View {

        if let icon = pv.showableIcon {
            Image(uiImage: icon)
                .resizable()
                .scaledToFill()
                .frame(width: 45, height: 45)
                .cornerRadius(14)
        } else if pv.noImageOrIcon {
            Image(systemName: "exclamationmark.octagon")
                .resizable()
                .frame(width: 45, height: 45)
                .foregroundStyle(Color.white.opacity(0.4))
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func previewImage(image: UIImage?) -> some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                .frame(height: pv.previewImageHeight, alignment: .center)
                .clipped()
        } else {
            Color(pv.dominantColor).adaptedTextColor().opacity(0.1)
                .frame(height: pv.previewImageHeight, alignment: .center)
            .transition(.opacity)
        }
    }
}


