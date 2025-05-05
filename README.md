# LinkPreviewExperiment

This is a quick demonstration of how someone *might* replace the [LPLinkView](https://developer.apple.com/documentation/linkpresentation/lplinkview) 
with an custom designed one.

It will use the [LPLinkMetadata](https://developer.apple.com/documentation/linkpresentation/lplinkmetadata) and comes
with caching. The cahcing lasts forever until you click the trash can icon. You likely would not want to cache that
long but for development, especially offline, it comes in handy.

**Note:** This is a demo provided as-is and not expected to be production worthy.

The SwiftUI is somewhat hastily hacked together just to make the demo where list items look vaguely like a typical link
preview.

The parts you will likely care about more are:

1. `MetadataCache.swift` - more specifically the `Metadata` class
2.  `Extensions` directory and its support utility functions
3. `Shared/KMeansCluster.swift` - this does the real work in getting the dominant color (see function: `getDominantColor()`)

Once you understand what's going with the color extraction, you should be able to easily write a metadata 
provider / caching setup that suits your needs.

While it works perfectly fine, I probably wouldn't use the `Metadata` class as is. It certainly works but it too contains some hastily
worked out ideas to make the demo work. However, you can see how you may want to extract the various items from a URL's metadata.
