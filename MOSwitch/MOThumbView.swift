//
//  ThumbView.swift
//  Switch
//
//  Created by Hayden Pennington on 6/17/16.
//  Copyright © 2016 Hayden Pennington. All rights reserved.
//

import Cocoa

/// The 'thumb' component of an `MOSwitch`.
public class MOThumbView: NSView {
    
    /// Specifies the width of the detail line drawn along the edge of the `MOThumbView`.
    public var lineWidth: CGFloat = 0.125
    
    // Specifies the color of the detail line drawn along the edge of the `MOThumbView`.
    public var lineColor = NSColor.black
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let center = NSPoint(x: bounds.size.height/2, y: bounds.size.height/2)
        let path = NSBezierPath()
        let rad = bounds.size.height/2 - 0.5
        let startAngle: CGFloat = 0
        let endAngle: CGFloat = 360
        path.appendArc(withCenter: center, radius: rad, startAngle: startAngle, endAngle: endAngle)
        
        lineColor.setStroke()
        path.lineWidth = lineWidth
        
        path.stroke()
    }
}
