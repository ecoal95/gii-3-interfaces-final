//
//  MovingCircle.swift
//  notifications
//
//  Created by Emilio Cobos Alvarez on 12/4/15.
//  Copyright © 2015 Emilio Cobos Alvarez. All rights reserved.
//

import Foundation
import CoreGraphics
import Cocoa

class MovingCircle: NSObject, NSCopying {
    var radius: CGFloat;
    var mass: CGFloat;
    var position: CGPoint;
    var previousPosition: CGPoint;
    var speed: CGVector;
    var color: NSColor;
    var bounceFactor: CGFloat;
    var _path: NSBezierPath;
    
    init(radius: CGFloat, mass: CGFloat, position: CGPoint, speed: CGVector, color: NSColor, bounceFactor: CGFloat) {
        self.radius = radius;
        self.mass = mass;
        self.position = position;
        self.previousPosition = CGPoint(x: 0, y: 0);
        self.speed = speed;
        self.color = color;
        self.bounceFactor = bounceFactor;
        self._path = NSBezierPath(roundedRect: NSRect(origin: CGPoint(x: -self.radius, y: -self.radius),
                                                     size: CGSize(width: radius * 2, height: radius * 2)),
                                  xRadius: radius,
                                  yRadius: radius);
        super.init();
    }
    
    convenience init(radius: CGFloat, mass: CGFloat, position: CGPoint, speed: CGVector, bounceFactor: CGFloat) {
        self.init(radius: radius, mass: mass, position: position, speed: speed, color: MovingCircle.randomColor(), bounceFactor: bounceFactor);
    }
    
    func path() -> NSBezierPath {
        let transform = NSAffineTransform();
        transform.translateXBy(self.position.x - self.previousPosition.x, yBy: self.position.y - self.previousPosition.y);
        self._path.transformUsingAffineTransform(transform);
        self.previousPosition = self.position;
        return self._path;
    }
    
    static func randomColor() -> NSColor {
        return NSColor(CGColor: CGColorCreateGenericRGB(CGFloat(drand48()), CGFloat(drand48()), CGFloat(drand48()), 1.0))!;
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        return MovingCircle(
            radius: self.radius,
            mass: self.mass,
            position: self.position,
            speed: self.speed,
            color: self.color.copyWithZone(zone) as! NSColor,
            bounceFactor: self.bounceFactor);
    }
}