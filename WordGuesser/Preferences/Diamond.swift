//
//  Diamond.swift
//  WordGuesser
//
//  Created by dimss on 15.02.2026.
//

import SwiftUI

struct Diamond: Shape {
    /// The rotated symmetrical quadrilateral.
    func path(in rect: CGRect) -> Path {
        /// The path to build the quadrilateral.
        var path = Path()
        let top = CGPoint(x: rect.midX, y: rect.minY)
        let right = CGPoint(x: rect.maxX, y: rect.midY)
        let bottom = CGPoint(x: rect.midX, y: rect.maxY)
        let left = CGPoint(x: rect.minX, y: rect.midY)

        path.move(to: top)
        path.addLine(to: right)
        path.addLine(to: bottom)
        path.addLine(to: left)
        path.closeSubpath()

        return path
    }
}

#Preview {
    Diamond()
}
