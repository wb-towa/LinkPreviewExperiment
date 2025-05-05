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

        let total = points.count // ADDED for locking issue

        for _ in 0 ..< k {
            var p = points.randomElement()


            /*
             Note: Original implementation would lock up on https://html.review because its favicon
             has one color so it could end up just looping forever.

             To get a nicer, more accurate dominant color, you do not want to set this to 1 which
             is another way to solve it. FYI 6 seems like a reasonable choice for k.

             The bits I have added (See ADDED comments) appear to solve the issue without causing
             much of a perf hit.

             This is can probably be done better but it works as a demo and if you want to use it
             just make sure you test it well and think about how it can be improved. An idea would
             be iterate on `points.count` rather than `k` when the count is lower.
             */

            // ADDED for locking issue
            var seen = 0
            if seen > total {
                break
            }


            while p == nil || clusters.contains(where: {$0.center == p}) {
                p = points.randomElement()
                // ADDED for locking issue
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

