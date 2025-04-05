# TODO

1. Minimum viable app to load list of URLS ✅
2. Minimum viable caching ✅
3. Custom view to act as a full replacement of `LPLinkView`
   1. Extract favicon and preview image
   2. Display view that is either more full with preview image or something that resembles the 'no metadata view' but with the favicon
   3. Extract the dominant colors from image (or favicon) to help with coloring of the view like `LPLinkView`
   4. As the image is either or, test that the image is the right image and not an intended favicon. iirc, the icon can sometiems come through as the image so size checks may be needed.
4. Robust, production worthy cache
