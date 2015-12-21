//
//  World.swift
//  notifications
//
//  Created by Emilio Cobos Alvarez on 12/4/15.
//  Copyright © 2015 Emilio Cobos Alvarez. All rights reserved.
//

import Foundation

class World {
    var width: CGFloat;
    var height: CGFloat;
    var objects: Array<MovingCircle>;
    var gravity: CGFloat;
    private var precalculatedDeltaFCache: Array<CGVector>?;
    
    init(width: CGFloat, height: CGFloat, gravity: CGFloat, objects: Array<MovingCircle>) {
        self.width = width;
        self.height = height;
        self.gravity = gravity;
        self.objects = objects;
    }
    
    convenience init(width: CGFloat, height: CGFloat, gravity: CGFloat) {
       self.init(width: width, height: height, gravity: gravity, objects: Array())
    }
    
    func tick(var ms: CGFloat) {
        ms /= 1000; // Just seconds
        let len = self.objects.count;
        var accelerationCache = Array<CGVector>(count: len, repeatedValue: CGVectorMake(0.0, 0.0));
        
        self.precalculatedDeltaFCache = Array<CGVector>(count: len, repeatedValue: CGVectorMake(0.0, 0.0));
        
        for i in 0..<len {
            let obj = self.objects[i];
            let force = self.force(obj, myIndex: i, len: len);
            let acceleration = CGVectorMake(force.dx / obj.mass, force.dy / obj.mass);
            
            obj.position.x += ms * (obj.speed.dx + ms * acceleration.dx * 0.5);
            obj.position.y += ms * (obj.speed.dy + ms * acceleration.dy * 0.5);
            
            accelerationCache[i] = acceleration;
            self.calculateSpeedAndPositionFromCollisions(obj, myIndex: i, len: len);
        }
        
        self.precalculatedDeltaFCache = Array<CGVector>(count: len, repeatedValue: CGVectorMake(0.0, 0.0));
        
        for i in 0..<len {
            let obj = self.objects[i];
            let force = self.force(obj, myIndex: i, len: len);
            let newAcceleration = CGVectorMake(force.dx / obj.mass, force.dy / obj.mass);
            
            obj.speed.dx += ms * (accelerationCache[i].dx + newAcceleration.dx);
            obj.speed.dy += ms * (accelerationCache[i].dy + newAcceleration.dy);
        }
    }
    
    func tick(ms: CGFloat, gravity: CGFloat) {
        self.gravity = gravity;
        self.tick(ms);
    }
    
    func force(obj: MovingCircle, myIndex: Int, len: Int) -> CGVector {
        var f = precalculatedDeltaFCache![myIndex];
        f.dy += gravity * obj.mass;
        
        for i in (myIndex + 1)..<len {
            let other = self.objects[i];
            
            let centerToCenter = CGVector(dx: other.position.x - obj.position.x, dy: other.position.y - obj.position.y);
            
            let centerToCenterLenSquared = centerToCenter.dx * centerToCenter.dx + centerToCenter.dy * centerToCenter.dy;
            
            // If they collide
            if centerToCenterLenSquared <= pow(obj.radius + other.radius, 2) {
                f.dx += other.speed.dx * other.mass;
                f.dy += other.speed.dy * other.mass;
                
                f.dx -= obj.speed.dx * obj.mass;
                f.dy -= obj.speed.dy * obj.mass;
                
                precalculatedDeltaFCache![i].dx += obj.speed.dx * obj.mass;
                precalculatedDeltaFCache![i].dy += obj.speed.dy * obj.mass;
                
                precalculatedDeltaFCache![i].dx -= other.speed.dx * other.mass;
                precalculatedDeltaFCache![i].dy -= other.speed.dy * other.mass;
            }
        }
        
        // if object touches boundary
        if obj.position.y - obj.radius < 0 {
            if self.gravity < 0 {
                f.dy -= obj.mass * self.gravity;
            }
            f.dy -= obj.speed.dy * obj.mass;
        } else if obj.position.y + obj.radius > self.height {
            if self.gravity > 0 {
                f.dy -= obj.mass * self.gravity;
            }
            f.dy -= obj.speed.dy * obj.mass;
        }
        
        if obj.position.x - obj.radius < 0 {
            f.dx -= obj.mass * obj.speed.dx;
        } else if obj.position.x + obj.radius > self.width {
            f.dx -= obj.mass * obj.speed.dx;
        }
        return f;
    }
    
    func calculateSpeedAndPositionFromCollisions(obj: MovingCircle, myIndex: Int, len: Int) {
        for i in (myIndex + 1)..<len {
            let other = self.objects[i];
            
            var centerToCenter = CGVector(dx: other.position.x - obj.position.x, dy: other.position.y - obj.position.y);
            
            let centerToCenterLenSquared = centerToCenter.dx * centerToCenter.dx + centerToCenter.dy * centerToCenter.dy;
            
            if centerToCenterLenSquared <= pow(obj.radius + other.radius, 2) {
                let centerToCenterModulus = sqrt(centerToCenterLenSquared);
                
                // Move the objects to the middle of the crash
                // NOTE: This can be heavily optimised, and I expect the compiler to do so
                let a = CGVector(dx: centerToCenter.dx * obj.radius / centerToCenterModulus,
                                 dy: centerToCenter.dy * obj.radius / centerToCenterModulus);
                let b = CGVector(dx: centerToCenter.dx * (centerToCenterModulus - other.radius) / centerToCenterModulus,
                                 dy: centerToCenter.dy * (centerToCenterModulus - other.radius) / centerToCenterModulus);
                let middleX = (a.dx - b.dx) / 2;
                let middleY = (a.dy - b.dy) / 2;
                
                obj.position.x -= middleX;
                obj.position.y -= middleY;
                
                other.position.x += middleX;
                other.position.y += middleY;
                
                // Normalize the vector
                centerToCenter.dx /= centerToCenterModulus;
                centerToCenter.dy /= centerToCenterModulus;
                
                let p = 2 * (obj.speed.dx * centerToCenter.dx + obj.speed.dy * centerToCenter.dy - other.speed.dx * centerToCenter.dx - other.speed.dy * centerToCenter.dy) / (obj.mass + other.mass);
                
                obj.speed.dx = (obj.speed.dx - p * other.mass * centerToCenter.dx) * obj.bounceFactor;
                obj.speed.dy = (obj.speed.dy - p * other.mass * centerToCenter.dy) * obj.bounceFactor;
                
                other.speed.dx = (other.speed.dx + p * obj.mass * centerToCenter.dx) * other.bounceFactor;
                other.speed.dy = (other.speed.dy + p * obj.mass * centerToCenter.dy) * other.bounceFactor;
            }
        }
        // if object touches boundary
        if obj.position.y - obj.radius < 0 {
            obj.speed.dy = abs(obj.speed.dy * obj.bounceFactor);
            obj.position.y = obj.radius;
        } else if obj.position.y + obj.radius > self.height {
            obj.speed.dy = -abs(obj.speed.dy * obj.bounceFactor);
            obj.position.y = self.height - obj.radius;
        }
        
        if obj.position.x - obj.radius < 0 {
            obj.speed.dx = -obj.speed.dx * obj.bounceFactor;
            obj.position.x = obj.radius;
        } else if obj.position.x + obj.radius > self.width {
            obj.speed.dx = -obj.speed.dx * obj.bounceFactor;
            obj.position.x = self.width - obj.radius;
        }
    }
}