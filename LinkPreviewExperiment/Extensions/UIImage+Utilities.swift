//
//  UIImage+Utilities.swift
//  LinkPreviewExperiment
//
//  Created by William B on 04/05/2025.
//

import SwiftUI

extension UIImage {

    func resized(to size : CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        //disable HDR:
        format.preferredRange = .standard

        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        let result = renderer.image { (context) in
            self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        }
        return result
    }

    /**
     Converts a UIImage to an array of UIColor. Currently, only used for dominant color valculations  via the `KMeansClusterer` algorithm.
     */
    func getPixels() -> [UIColor] {
        guard let cgImage = self.cgImage else {
            return []
        }

        assert(cgImage.bitsPerPixel == 32, "only supports 32-bit images")
        assert(cgImage.bitsPerComponent == 8,  "only supports 8-bits per channel")

        guard let imageData = cgImage.dataProvider?.data as Data? else {
            return []
        }

        let size = cgImage.width * cgImage.height
        let buffer = UnsafeMutableBufferPointer<UInt32>.allocate(capacity: size)
        _ = imageData.copyBytes(to: buffer)

        var result = [UIColor]()
        result.reserveCapacity(size)


        let whiteforAlpha = UIColor(red: 1, green: 1, blue: 1, alpha: 1)

        for pixel in buffer {
            var r : UInt32 = 0
            var g : UInt32 = 0
            var b : UInt32 = 0
            var a : UInt32 = 1
            if cgImage.byteOrderInfo == .orderDefault || cgImage.byteOrderInfo == .order32Big {
                r = pixel & 255
                g = (pixel >> 8) & 255
                b = (pixel >> 16) & 255
                a = (pixel >> 24) & 255
            } else if cgImage.byteOrderInfo == .order32Little {
                a = (pixel >> 24) & 255
                r = (pixel >> 16) & 255
                g = (pixel >> 8) & 255
                b = pixel & 255
            }

            /*
             Note: You often see alpha ignored in implementations looking for dominant / common colors.
             The implementation I've based my work off of would translate transparency as black
             because the alpha is dropped. I would prefer to have it as white.

             Presumably the reason most folks do not care about alpha is it doesn't matter for most
             images. However, I am more likely to be processing images with transparency so I need
             to convert that.

             This works and there is not meaningful performance problem but if you base your work off
             this, keep in mind this is an area to keep an eye on.
             */
            switch a {
            case 0:
                result.append(whiteforAlpha)
            default:
                let color = UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
                result.append(color)
            }
        }
        return result
    }

}
