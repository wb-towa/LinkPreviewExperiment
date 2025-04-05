//
//  Constants.swift
//  LinkPreviewExperiment
//
//  Created by William B on 17/03/2025.
//

import Foundation

// for testing purposes we just want associate a value to
// use for caching. id will be part of the filename
struct Bookmark {
    let id: String
    let url: URL?
}

let bookmarks = [
    Bookmark(id: "aa", url: URL(string: "https://www.anildash.com/2023/07/07/vc-qanon/")),
    Bookmark(id: "bb", url: URL(string: "https://www.alexanderlogan.co.uk/blog/")),
    Bookmark(id: "cc", url: URL(string: "https://apolloapp.io")),
    Bookmark(id: "dd", url: URL(string: "https://www.birdnote.org/")),
    Bookmark(id: "ee", url: URL(string: "https://appstoreconnect.apple.com")),
    Bookmark(id: "ff", url: URL(string: "https://old.reddit.com/r/apple/.json")),
    Bookmark(id: "gg", url: URL(string: "https://www.artemnovichkov.com/")),
    Bookmark(id: "hh", url: URL(string: "https://www.google.com")),
    Bookmark(id: "ii", url: URL(string: "https://www.backblaze.com")),
    Bookmark(id: "jj", url: URL(string: "https://www.barebones.com/products/bbedit/index.html")),
    Bookmark(id: "kk", url: URL(string: "https://www.macbartender.com/")),
    Bookmark(id: "ll", url: URL(string: "https://basicappleguy.com/")),
    Bookmark(id: "mm", url: URL(string: "https://www.bing.com")),
    Bookmark(id: "nn", url: URL(string: "https://danielsaidi.com/blog/")),
    Bookmark(id: "oo", url: URL(string: "https://www.bluesnews.com/")),
    Bookmark(id: "pp", url: URL(string: "https://bsky.app/")),
    Bookmark(id: "qq", url: URL(string: "https://techpod.content.town")),
    Bookmark(id: "rr", url: URL(string: "https://castro.fm")),
    Bookmark(id: "tt", url: URL(string: "https://m.youtube.com/watch?si=iNvsBqHqCJ6n1KVr&v=CKz8hZe9kTo&feature=youtu.be")),
    Bookmark(id: "uu", url: URL(string: "https://nine-nine.now.sh")),
    Bookmark(id: "vv", url: URL(string: "https://www.nasa.gov")),
    Bookmark(id: "ww", url: URL(string: "https://chiptune.app/")),
    Bookmark(id: "xx", url: URL(string: "https://mars.nasa.gov/")),
    Bookmark(id: "yy", url: URL(string: "https://y-n10.com")),
    Bookmark(id: "zz", url: URL(string: "https://freshairarchive.org")),
    Bookmark(id: "11", url: URL(string: "https://70s-sci-fi-art.ghost.io/")),
    Bookmark(id: "22", url: URL(string: "https://www.404media.co/"))
]
