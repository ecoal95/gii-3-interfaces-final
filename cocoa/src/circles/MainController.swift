//
//  MainController.swift
//  notifications
//
//  Created by Emilio Cobos Alvarez on 12/4/15.
//  Copyright © 2015 Emilio Cobos Alvarez. All rights reserved.
//

import Foundation
import Cocoa

class MainController: NSObject, NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate {
    let MIN_WIDTH: CGFloat = 500.0;
    let MIN_HEIGHT: CGFloat = 500.0;
    
    @IBOutlet weak var worldHeight: NSTextField!;
    @IBOutlet weak var worldWidth: NSTextField!;
    @IBOutlet weak var gravity: NSSlider!;
    
    @IBOutlet weak var nextBallMass: NSSlider!;
    @IBOutlet weak var nextBallBounceFactor: NSSlider!;
    @IBOutlet weak var nextBallRadius: NSSlider!;
    @IBOutlet weak var nextBallPositionX: NSTextField!;
    @IBOutlet weak var nextBallPositionY: NSTextField!;
    @IBOutlet weak var nextBallSpeedX: NSTextField!;
    @IBOutlet weak var nextBallSpeedY: NSTextField!;
    
    @IBOutlet weak var startSimulation: NSButton!
    @IBOutlet weak var simulationWindow: NSWindow!;
    @IBOutlet weak var table: NSTableView!;
    @IBOutlet weak var savedWorldsTable: NSTableView!;
    @IBOutlet var window: NSWindow!;
    
    override init() {
        super.init();
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: "worldSaved:", name: "worldSaved", object: nil);
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: "displaySimulation:", name: "displaySimulation", object: nil);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    var objects: Array<MovingCircle> = [];
    
    @IBAction func addNewBall(_: AnyObject) {
        objects.append(MovingCircle(
            radius: CGFloat(nextBallRadius.doubleValue),
            mass: CGFloat(nextBallMass.doubleValue),
            position: CGPoint(x: CGFloat(nextBallPositionX.doubleValue), y: CGFloat(nextBallPositionY.doubleValue)),
            speed: CGVector(dx: CGFloat(nextBallSpeedX.doubleValue), dy: CGFloat(nextBallSpeedY.doubleValue)),
            bounceFactor: CGFloat(nextBallBounceFactor.doubleValue)));
        self.table.reloadData();
    }
    
    @IBAction func startSimulation(_: AnyObject?) {
        let width = max(MIN_WIDTH, CGFloat(worldWidth.doubleValue));
        let height = max(MIN_HEIGHT, CGFloat(worldHeight.doubleValue));
        let gravity = CGFloat(self.gravity.doubleValue);
        
        let config = WorldConfig(width: width, height: height, gravity: gravity, objects: self.objects);
        NSNotificationCenter.defaultCenter()
            .postNotification(NSNotification(name: "saveWorld", object: config));
        NSNotificationCenter.defaultCenter()
            .postNotification(NSNotification(name: "resetWorld", object: config));
        self.displaySimulation();
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return objects.count;
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if tableColumn == nil || row >= self.objects.count {
            return nil
        }
        
        let obj = self.objects[row];
        
        switch tableColumn!.identifier {
        case "mass":
            return obj.mass;
        case "radius":
            return obj.radius;
        case "position":
            return String(obj.position);
        case "bounceFactor":
            return obj.bounceFactor;
        case "speed":
            return String(CGPoint(x: obj.speed.dx, y: obj.speed.dy));
        default:
            return nil;
        }
    }
    
    @objc func worldSaved(notification: NSNotification) {
        self.savedWorldsTable.reloadData();
    }
    
    func displaySimulation() {
        if !self.simulationWindow.visible {
            self.simulationWindow.setIsVisible(true);
            self.window.setIsVisible(false);
            self.objects.removeAll();
            self.table.reloadData();
        }
    }
    
    @objc func displaySimulation(notification: NSNotification) {
        self.displaySimulation();
    }
}