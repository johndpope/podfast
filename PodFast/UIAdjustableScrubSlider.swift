//
//  UIAdjustableScrubSlider.swift
//  UISliderScrubSpeed
//
//  Created by Orestis Papadopoulos on 16/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import UIKit

protocol SmoothingFunction {
    mutating func apply(toValue: inout Float)
}

struct SimpleSmoothingFunction: SmoothingFunction {
    mutating func apply(toValue value: inout Float){
        value = cutoff * value + (1 - cutoff) * previousValue
        previousValue = value
    }
    
    private var cutoff: Float = 0.3
    private var previousValue: Float = 0.0
}

enum SmoothingFunctionType {
    case none
    case simple
}

class SmoothingFunctionFactory {
    private static var sharedSmoothingFunctionFactory = SmoothingFunctionFactory()
    class func shared() -> SmoothingFunctionFactory {
        return sharedSmoothingFunctionFactory
    }
    
    func getSmoothingFunctionType(_ smoothingFunction : SmoothingFunctionType) -> SmoothingFunction? {
        switch smoothingFunction {
        case .none:
            return nil
        case .simple:
            return SimpleSmoothingFunction()
        }
    }
}

class UIAdjustableScrubSlider: UISlider {

    var feedbackGenerator = UIImpactFeedbackGenerator()
    var scrubbingSpeed: Float = 0.4
    var scrubbingRanges: [Range<Float> : Float] = [ :
//         100.0   ..<  150.0     : 0.1,
//         50.0    ..<  100.0     : 0.25,
//         0.0     ..<  50.0      : 0.5,
//        -50.0    ..<  0.0       : 0.75,
//        -100.0   ..<  -50.0     : 1.0,
//        -150.0   ..<  -100.0    : 1.25
    ]
    
    private var snapPoints = [Float]()
    private var realValue: Float = 0.0
    private var smoothingFunction: SmoothingFunction?
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        feedbackGenerator.prepare()
        realValue = self.value
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let trackRect = self.trackRect(forBounds: self.bounds)
        let previousLocation = touch.previousLocation(in: self)
        let currentLocation = touch.location(in: self)
        
        for (range, speed) in scrubbingRanges {
            if range.contains(Float(currentLocation.y)) {
                scrubbingSpeed = speed
            }
        }
        
        var trackingOffset: Float = Float(currentLocation.x) - Float(previousLocation.x)
        smoothingFunction?.apply(toValue: &trackingOffset)

        realValue = realValue + scrubbingSpeed * (self.maximumValue - self.minimumValue) * (Float(trackingOffset)/Float(trackRect.size.width))
        realValue = (self.minimumValue ... self.maximumValue).clamp(value: realValue)

        for snapPoint in snapPoints {
            if abs(snapPoint - realValue) < 0.019 * (self.maximumValue - self.minimumValue) {
                self.value = snapPoint
                sendActions(for: .valueChanged)
                return true
            }
        }

        // update the slider value
        self.value = realValue
        sendActions(for: .valueChanged)
        return true
    }

    func setSmoothing(type t: SmoothingFunctionType){
        smoothingFunction = SmoothingFunctionFactory.shared().getSmoothingFunctionType(t)
    }

    func setSnapPoints(_ snapPoints: [Float]){
        self.snapPoints = snapPoints
    }
}

fileprivate extension ClosedRange {
    func clamp(value : Bound) -> Bound {
        return self.lowerBound > value ? self.lowerBound
            : self.upperBound < value  ? self.upperBound
            : value
    }
}
