//
//  KMeansCluster.swift
//  LinkPreviewExperiment
//
//  Created by William B on 04/05/2025.
//

import Foundation
import SwiftUI


final class KMeansCluster {
    func calculate(points : [Point], into k : Int) -> [Cluster] {
        var clusters = [Cluster]()

        let total = points.count // Note: added for the lock issue - help to know when we have looked at every pixel already

        var seen = 0

        for _ in 0 ..< k {
            // Note: for locking issue
            // we've looped through all the colors so the contains
            // method will likely always return true and never exit`
            // no need to even finish to `k`.
            if seen > total {
                break
            }

            var p = points.randomElement()


            /*
             Note: Original implementation will lock up on https://thehtml.review/ because it has one color
             so the while loop will get stucck on `clusters.contains(where: {$0.center == p})` returning
             true forever.

             A way out of this is to set `k` to 1 but that ruins most of the other colors, we're really only
             catering for an edge case. Out of the hundreds of URLs I've tested, only one hangs and most
             complete their loop in fewer than 10 iterations.

             It's really only the URL above where it gets to 10,000 (the max number of pixels given that the image is resized).

             */
            while p == nil || clusters.contains(where: {$0.center == p}) {
                p = points.randomElement()
                // Note: for locking issue
                // we have gone through all the colors so contains will likely
                // return true forever.
                seen += 1
                if seen > total {
                    break
                }
            }

            clusters.append(Cluster(center: p!))
        }

        for i in 0 ..< 10 {

            clusters.forEach {
                $0.points.removeAll()
            }

            for p in points {
                let closest = findClosest(for: p, from: clusters)
                closest.points.append(p)
            }

            var converged = true

            clusters.forEach {
                let oldCenter = $0.center
                $0.updateCenter()
                if oldCenter.distanceSquared(to: $0.center) > 0.001 {
                    converged = false
                }
            }

            if converged {
                logger.debug("Converged. Took \(i) iterations")
                break;
            }
        }
        return clusters
    }

    private func findClosest(for p : Point, from clusters: [Cluster]) -> Cluster {
        return clusters.min(by: {$0.center.distanceSquared(to: p) < $1.center.distanceSquared(to: p)})!
    }
}

extension KMeansCluster {
    class Cluster {
        var points = [Point]()
        var center : Point

        init(center : Point) {
            self.center = center
        }

        func calculateCurrentCenter() -> Point {
            if points.isEmpty {
                return Point.zero
            }
            return points.reduce(Point.zero, +) / points.count
        }

        func updateCenter() {
            if points.isEmpty {
                return
            }
            let currentCenter = calculateCurrentCenter()
            center = points.min(by: {$0.distanceSquared(to: currentCenter) < $1.distanceSquared(to: currentCenter)})!
        }
    }
}
extension KMeansCluster {
    struct Point : Equatable {
        let x : CGFloat
        let y : CGFloat
        let z : CGFloat
        let alpha: CGFloat

        init(_ x: CGFloat, _ y : CGFloat, _ z : CGFloat) {
            self.x = x
            self.y = y
            self.z = z
            self.alpha = 1
        }

        init(from color : UIColor) {
            var r : CGFloat = 0
            var g : CGFloat = 0
            var b : CGFloat = 0
            var a : CGFloat = 0
            if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
                x = r
                y = g
                z = b
                alpha = a
            } else {
                x = 0
                y = 0
                z = 0
                alpha = 1
            }
        }

        static let zero = Point(0, 0, 0)

        static func == (lhs: Point, rhs: Point) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
        }

        static func +(lhs : Point, rhs : Point) -> Point {
            return Point(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
        }

        static func /(lhs : Point, rhs : CGFloat) -> Point {
            return Point(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
        }

        static func /(lhs : Point, rhs : Int) -> Point {
            return lhs / CGFloat(rhs)
        }

        func distanceSquared(to p : Point) -> CGFloat {
            return (self.x - p.x) * (self.x - p.x)
                + (self.y - p.y) * (self.y - p.y)
                + (self.z - p.z) * (self.z - p.z)
        }

        func toUIColor() -> UIColor {
            return UIColor(red: x, green: y, blue: z, alpha: alpha)
        }
    }
}

