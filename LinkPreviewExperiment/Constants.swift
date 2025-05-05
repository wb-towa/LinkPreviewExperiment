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
    let title: String
    let url: URL?
}

let bookmarks = [
    Bookmark(id: "aa", title: "Anil Dash", url: URL(string: "https://www.anildash.com/2023/07/07/vc-qanon/")),
    Bookmark(id: "bb", title: "Blog", url: URL(string: "https://www.alexanderlogan.co.uk/blog/")),
    Bookmark(id: "cc", title: "Apollo", url: URL(string: "https://apolloapp.io")),
    Bookmark(id: "dd", title: "Bird Note", url: URL(string: "https://www.birdnote.org/")),
    Bookmark(id: "ee", title: "app store connect", url: URL(string: "https://appstoreconnect.apple.com")),
    Bookmark(id: "ff", title: "/r/apple.json", url: URL(string: "https://old.reddit.com/r/apple/.json")),
    Bookmark(id: "gg", title: "Blog example", url: URL(string: "https://www.artemnovichkov.com/")),
    Bookmark(id: "hh", title: "Google", url: URL(string: "https://www.google.com")),
    Bookmark(id: "ii", title: "Backblaze", url: URL(string: "https://www.backblaze.com")),
    Bookmark(id: "jj", title: "bbedit", url: URL(string: "https://www.barebones.com/products/bbedit/index.html")),
    Bookmark(id: "kk", title: "Bartender", url: URL(string: "https://www.macbartender.com/")),
    Bookmark(id: "ll", title: "Basic Apple Guy", url: URL(string: "https://basicappleguy.com/")),
    Bookmark(id: "mm", title: "Bing", url: URL(string: "https://www.bing.com")),
    Bookmark(id: "nn", title: "Blog Example", url: URL(string: "https://danielsaidi.com/blog/")),
    Bookmark(id: "oo", title: "Bluews News", url: URL(string: "https://www.bluesnews.com/")),
    Bookmark(id: "pp", title: "Bluesky", url: URL(string: "https://bsky.app/")),
    Bookmark(id: "qq", title: "Techpod", url: URL(string: "https://techpod.content.town")),
    Bookmark(id: "rr", title: "Castro", url: URL(string: "https://castro.fm")),
    Bookmark(id: "tt", title: "Youtube Example", url: URL(string: "https://m.youtube.com/watch?si=iNvsBqHqCJ6n1KVr&v=CKz8hZe9kTo&feature=youtu.be")),
    Bookmark(id: "uu", title: "99 Now", url: URL(string: "https://nine-nine.now.sh")),
    Bookmark(id: "vv", title: "Nasa", url: URL(string: "https://www.nasa.gov")),
    Bookmark(id: "ww", title: "Chiptune", url: URL(string: "https://chiptune.app/")),
    Bookmark(id: "xx", title: "Mars - Nasa", url: URL(string: "https://mars.nasa.gov/")),
    Bookmark(id: "yy", title: "Yamauchi Family Office", url: URL(string: "https://y-n10.com")),
    Bookmark(id: "zz", title: "Fresh Air Archive", url: URL(string: "https://freshairarchive.org")),
    Bookmark(id: "11", title: "70's sci-fi art", url: URL(string: "https://70s-sci-fi-art.ghost.io/")),
    Bookmark(id: "22", title: "404 Media", url: URL(string: "https://www.404media.co/"))
]
