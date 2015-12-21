//
//  SimulationController.swift
//  notifications
//
//  Created by Emilio Cobos Alvarez on 12/15/15.
//  Copyright © 2015 Emilio Cobos Alvarez. All rights reserved.
//

import Foundation
import Cocoa

class SimulationController: NSObject, NSWindowDelegate {
    @IBOutlet var window: NSWindow!
    @IBOutlet weak var view: WorldView!
    @IBOutlet weak var mainWindow: NSWindow!
    @IBOutlet weak var showPreferencesButton: NSButton!
    @IBOutlet weak var preferencesDialog: NSWindow!

    override init() {
        super.init();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferencesChanged:", name: "preferencesChanged", object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetWorld:", name: "resetWorld", object: nil);
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func windowShouldClose(sender: AnyObject) -> Bool {
        mainWindow.setIsVisible(true);
        return true;
    }
    
    @IBAction func showPreferences(_: AnyObject?) {
        NSNotificationCenter.defaultCenter()
            .postNotification(NSNotification(name: "simulationPreferencesInit",
                                             object: Preferences(
                                               gravity: self.view.world.gravity,
                                               nextBallRadius: self.view.nextObjectRadius,
                                               nextBallMass: self.view.nextObjectMass,
                                               nextBallBounceFactor: self.view.nextObjectBounceFactor)));
        self.preferencesDialog.setIsVisible(true);
    }
    
    @IBAction func showPreferencesIfSimulating(sender: AnyObject?) {
        if self.window.visible {
            self.showPreferences(sender);
        } else {
            let alert = NSAlert();
            alert.messageText = "Not simulating";
            alert.informativeText = "Must be simulating to show the preferences dialog";
            alert.addButtonWithTitle("Ok");
            alert.runModal();
        }
    }
    
    func windowWillClose(notification: NSNotification) {
        self.preferencesDialog.setIsVisible(false);
    }
    
    @objc func preferencesChanged(notification: NSNotification) {
        let preferences = notification.object as! Preferences;
        self.view.world.gravity = preferences.gravity;
        self.view.nextObjectMass = preferences.nextBallMass;
        self.view.nextObjectRadius = preferences.nextBallRadius;
        self.view.nextObjectBounceFactor = preferences.nextBallBounceFactor;
    }
    
    var offset: CGFloat = 0;
    @objc func resetWorld(notification: NSNotification) {
        
        let config = notification.object as! WorldConfig;
        
        self.view.world.objects = Array();
        // Need to do a deep copy of the objects to allow restoring the original config
        for obj in config.objects {
            self.view.world.objects.append(obj.copy() as! MovingCircle);
        }
        
        self.view.world.gravity = config.gravity;
        
        let view_size = self.view.frame.size;
        let win_size = self.window.frame.size;
        if self.offset == 0 {
            self.offset = win_size.height - view_size.height;
        }
        
        self.view.world.width = config.width;
        self.view.world.height = config.height;
        
        self.window.setContentSize(NSSize(width: config.width, height: config.height + self.offset));
        
        self.view.setFrameSize(NSSize(width: config.width, height: config.height));
        self.view.setFrameSize(NSSize(width: config.width, height: config.height));
        self.view.setFrameOrigin(NSPoint(x: 0, y: offset));
        
        let button_size = self.showPreferencesButton.frame.size;
        self.showPreferencesButton.setFrameOrigin(NSPoint(x: config.width / 2 - button_size.width / 2, y: self.offset / 2 - button_size.height / 2));
    }
}
