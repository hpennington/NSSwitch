//
//  MOSwitch.swift
//  MOSwitch
//
//  Created by Hayden Pennington on 6/14/16.
//  Copyright © 2016 Hayden Pennington. All rights reserved.
//

import Cocoa


@IBDesignable
/// A UISWitch "clone" for macOS.
public class MOSwitch: NSControl {
    
    /// Reflects the current state of the `MOSwitch`.
    private (set) public var on = false
    
    /// Set the `on` property, optionally animate the change.
    ///
    /// - Parameter on: The state to set the switch.
    /// - Parameter animated: Specify whether the state change should be animated.
    public func setOn(on: Bool, animated: Bool) {
        
        let bgColor = on ? onColor : offColor
        backgroundView.layer?.backgroundColor = bgColor.CGColor

        if animated {
            animate(on)
        }
        
        self.on = on
    }
    
    /// The CAMediaTimingFunction for the switch animation.
    public var mediaTimingFunction = kCAMediaTimingFunctionEaseIn
    
    /// The duration of the switch animation.
    /// default value is 0.20.
    public var thumbAnimationDuration = 0.20
    
    /// The `NSColor` value of the `backgroundView` when the property `on` is set to true.
    @IBInspectable public var onColor: NSColor = NSColor(red: 19/255.0, green: 232/255.0, blue: 89/255.0, alpha: 1.0)
    
    /// The `NSColor` value of the `backgroundView` when the property `on` is set to false.
    @IBInspectable public var offColor: NSColor = NSColor(red: 203/255.0, green: 203/255.0, blue: 203/255.0, alpha: 1.0) {
        didSet { backgroundView.layer?.backgroundColor = offColor.CGColor }
    }
    
    /// The `NSColor` value of the `thumbView`.
    @IBInspectable public var thumbColor: NSColor = NSColor(red: 226/255.0, green: 226/255.0, blue: 226/255.0, alpha: 1.0) {
        didSet { thumbView.layer?.backgroundColor = thumbColor.CGColor }
    }
    
    /// The background `NSView` of the `MOSwitch`.
    public var backgroundView: NSView!
    
    /// An instance of `MOThumbView` for the Thumb component.
    public var thumbView: MOThumbView!
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    private var radius: CGFloat {
        return self.bounds.size.height / 2
    }
    
    private var dragVelocityGain: CGFloat = 0.3

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
        let thumbOrigin = CGPoint(x: backgroundView.bounds.origin.x,
                                 y: backgroundView.bounds.origin.y)
        
        let diameter = backgroundView.bounds.size.height
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
        sendAction(self.action, to: self.target)
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
            sendAction(self.action, to: self.target)
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
            let x = backgroundView.bounds.size.width - thumbView.frame.size.width
            let destinationOrigin = CGPoint(x: x, y: 0)
            thumbView.animator().setFrameOrigin(destinationOrigin)
        }
        else {
            let destinationOrigin = CGPoint(x: 0, y: 0)
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