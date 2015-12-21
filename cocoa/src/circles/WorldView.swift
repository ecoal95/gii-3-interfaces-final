//
//  WorldView.swift
//  notifications
//
//  Created by Emilio Cobos Alvarez on 12/10/15.
//  Copyright © 2015 Emilio Cobos Alvarez. All rights reserved.
//

import Foundation
import Cocoa

class WorldView: NSView {
    var world: World;
    var nextObjectRadius: CGFloat;
    var nextObjectMass: CGFloat;
    var nextObjectBounceFactor: CGFloat;

    // This makes gravity et al. more intuitive
    override var flipped: Bool {
        get {
            return true
        }
    }

    required init?(coder: NSCoder) {
        self.nextObjectRadius = 30;
        self.nextObjectMass = 10;
        self.nextObjectBounceFactor = 1.0;
        self.world = World(width: 0, height: 0, gravity: 100.0);

        super.init(coder: coder);
        // self.wantsLayer = true;
        // self.layer = self.makeBackingLayer();
        // self.layer!.delegate = self;
        // self.layer!.backgroundColor = CGColorCreateGenericRGB(1.0, 0, 0, 0.5);
        self.world.width = self.frame.width;
        self.world.height = self.frame.height;
        let timer = NSTimer(timeInterval: 1 / 60, target: self, selector: "tick", userInfo: nil, repeats: true);
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes);
    }

    override func drawRect(dirtyRect: NSRect) {
        for object in self.world.objects {
            NSColor.blackColor().setStroke();
            object.color.setFill();

            let path = object.path();
            path.lineWidth = 3.0;
            path.stroke();
            path.fill();
        }
        super.drawRect(dirtyRect);
    }

    override func mouseDown(event: NSEvent) {
        let x = event.locationInWindow.x - self.frame.origin.x;
        var y = event.locationInWindow.y - self.frame.origin.y;

        // We might need to un-flip the coordinates
        if self.flipped {
            y = self.frame.height - y;
        }


        world.objects.append(MovingCircle(
            radius: self.nextObjectRadius,
            mass: self.nextObjectMass,
            position: CGPoint(x: x, y: y),
            speed: CGVector(dx: 0, dy: 0),
            bounceFactor: self.nextObjectBounceFactor));
        // Make sure the view is refreshed
        self.needsDisplay = true;
    }

    func tick() {
        self.world.tick(1000.0 / 60);
        self.needsDisplay = true;
    }
}
