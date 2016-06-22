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
    public var lineColor = NSColor.blackColor()
    
    override public func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        let center = NSPoint(x: bounds.size.height/2, y: bounds.size.height/2)
        
        let path = NSBezierPath()
        path.appendBezierPathWithArcWithCenter(center, radius: bounds.size.height/2 - 0.5, startAngle: 0, endAngle: 360)
        
        lineColor.setStroke()
        path.lineWidth = lineWidth
        
        path.stroke()
    }
}
