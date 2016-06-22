//
//  MOSwitch.swift
//  MOSwitch
//
//  Created by Hayden Pennington on 6/14/16.
//  Copyright © 2016 Hayden Pennington. All rights reserved.
//

import Cocoa


@IBDesignable
public class MOSwitch: NSControl {
    
    public var on = false
    
    public func setOn(on: Bool, animated: Bool) {
        
        let bgColor = on ? onColor : offColor
        backgroundView.layer?.backgroundColor = bgColor.CGColor

        if animated {
            animate(on)
        }
        
        self.on = on
    }
    
    public let thumbPadding: CGFloat = 0.0
    
    public var mediaTimingFunction = kCAMediaTimingFunctionEaseIn
    public var thumbAnimationDuration = 0.20
    
    public var radius: CGFloat {
        return self.bounds.size.height / 2
    }
    
    @IBInspectable public var onColor: NSColor = NSColor(red: 19/255.0, green: 232/255.0, blue: 89/255.0, alpha: 1.0)
    
    @IBInspectable public var offColor: NSColor = NSColor(red: 203/255.0, green: 203/255.0, blue: 203/255.0, alpha: 1.0) {
        didSet { backgroundView.layer?.backgroundColor = offColor.CGColor }
    }
    
    @IBInspectable public var thumbColor: NSColor = NSColor(red: 226/255.0, green: 226/255.0, blue: 226/255.0, alpha: 1.0) {
        didSet { thumbView.layer?.backgroundColor = thumbColor.CGColor }
    }
    
    public var backgroundView: NSView!
    public var thumbView: MOThumbView!
    
    public var dragVelocityGain: CGFloat = 0.3
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    private func setup() {
        
        // Draw the backgroundView
        backgroundView = NSView(frame: self.bounds)
        backgroundView.wantsLayer = true

        if let layer = backgroundView.layer {
            layer.backgroundColor = offColor.CGColor
            layer.cornerRadius = radius
        }
        
        self.addSubview(backgroundView)
        
        // Draw the knobView
        let thumbOrigin = CGPoint(x: backgroundView.bounds.origin.x + thumbPadding,
                                 y: backgroundView.bounds.origin.y + thumbPadding)
        
        let diameter = backgroundView.bounds.size.height - thumbPadding * 2
        let thumbSize = CGSize(width: diameter, height: diameter)
        let thumbFrame = CGRect(origin: thumbOrigin, size: thumbSize)
        
        thumbView = MOThumbView(frame: thumbFrame)
        thumbView.wantsLayer = true
        
        if let layer = thumbView.layer {
            layer.backgroundColor = thumbColor.CGColor
            layer.cornerRadius = radius
        }
                
        let panRecognizer = NSPanGestureRecognizer(target: self, action: #selector(MOSwitch.panned(_:)))
        let clickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(MOSwitch.clicked(_:)))
        
        thumbView.addGestureRecognizer(panRecognizer)
        backgroundView.addGestureRecognizer(clickRecognizer)
        
        backgroundView.addSubview(thumbView)

    }
    
    
    // MARK: - NSGesture handlers.
    
    @objc private func clicked(click: NSClickGestureRecognizer) {
        setOn(!on, animated: true)
    }
    
    @objc private func panned(pan: NSPanGestureRecognizer) {
        switch pan.state {
        case .Began:
            break
        case .Changed:
            updatePosition(pan)
            
            let x = thumbView.frame.origin.x
            let thumbViewWidth = thumbView.bounds.size.width
            let backgroundViewWidth = backgroundView.bounds.size.width
            if x + thumbViewWidth/2 >= backgroundViewWidth/2 {
                setOn(true, animated: false)
            } else {
                setOn(false, animated: false)
            }
            break
        case .Ended:
            moveToNearestSwitchPosition()
            break
        default:
            break
        }
    }
    
    private func animate(on: Bool) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(thumbAnimationDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: mediaTimingFunction))
        
        if on {
            let x = backgroundView.bounds.size.width - thumbView.frame.size.width + thumbPadding
            let destinationOrigin = CGPoint(x: x, y: 0)
            thumbView.animator().setFrameOrigin(destinationOrigin)
        }
        else {
            let destinationOrigin = CGPoint(x: thumbPadding, y: thumbPadding)
            thumbView.animator().setFrameOrigin(destinationOrigin)
        }
        
        CATransaction.commit()
    }
    
    private func updatePosition(pan: NSPanGestureRecognizer) {
        
        let thumbWidth = thumbView.bounds.size.width
        
        let leadingSpace = thumbView.frame.origin.x
        let trailingSpace = backgroundView.bounds.size.width - (leadingSpace + thumbWidth)
        
        let xTranslation = pan.translationInView(backgroundView).x
        
        if xTranslation >= 0 {
            
            let delta = trailingSpace >= xTranslation ? xTranslation : trailingSpace
            thumbView.frame.origin.x += delta * dragVelocityGain
            
        }
        else {
            
            if leadingSpace >= -xTranslation {
                thumbView.frame.origin.x += xTranslation * dragVelocityGain
            }
            else {
                thumbView.frame.origin.x += -leadingSpace * dragVelocityGain
            }
            
        }
    }
    
    private func moveToNearestSwitchPosition() {
            setOn(on, animated: true)
    }
    
}