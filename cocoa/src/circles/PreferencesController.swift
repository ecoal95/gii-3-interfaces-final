//
//  PreferencesController.swift
//  notifications
//
//  Created by Emilio Cobos Alvarez on 12/15/15.
//  Copyright © 2015 Emilio Cobos Alvarez. All rights reserved.
//

import Foundation
import Cocoa

class Preferences {
    var gravity: CGFloat = 10.0;
    var nextBallRadius: CGFloat = 20.0;
    var nextBallMass: CGFloat = 10.0;
    var nextBallBounceFactor: CGFloat = 1.0;
    
    init(gravity: CGFloat, nextBallRadius: CGFloat, nextBallMass: CGFloat, nextBallBounceFactor: CGFloat) {
        self.gravity = gravity;
        self.nextBallRadius = nextBallRadius;
        self.nextBallMass = nextBallMass;
        self.nextBallBounceFactor = nextBallBounceFactor;
    }
    
    convenience init() {
        self.init(gravity: 10.0, nextBallRadius: 20.0, nextBallMass: 10.0, nextBallBounceFactor: 1.0);
    }
}

class PreferencesController: NSObject, NSWindowDelegate {
    var preferences: Preferences;
    
    @IBOutlet weak var gravitySlider: NSSlider!;
    @IBOutlet weak var nextBallMassSlider: NSSlider!;
    @IBOutlet weak var nextBallRadiusSlider: NSSlider!;
    @IBOutlet weak var nextBallBounceFactorSlider: NSSlider!;
    @IBOutlet weak var savedGamesTable: NSTableView!;
    @IBOutlet var window: NSWindow!;
    
    
    override init() {
        self.preferences = Preferences();
        super.init()
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: "simulationPreferencesInit:", name: "simulationPreferencesInit", object: nil);
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: "worldSaved:", name: "worldSaved", object: nil);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    @IBAction func updatePreferences(_: AnyObject?) {
        self.preferences.gravity = CGFloat(gravitySlider.doubleValue);
        self.preferences.nextBallMass = CGFloat(nextBallMassSlider.doubleValue);
        self.preferences.nextBallRadius = CGFloat(nextBallRadiusSlider.doubleValue);
        self.preferences.nextBallBounceFactor = CGFloat(nextBallBounceFactorSlider.doubleValue);
        NSNotificationCenter.defaultCenter()
            .postNotification(NSNotification(
                name: "preferencesChanged",
                object: self.preferences));
    }
    
    // What the actual f**k??
    // This method was called just `initPreferences`, and for some reason,
    // when a method with that name is called, it forces a `release` of the object.
    //
    // This has caused a lot of memory errors... -.-
    func simulationPreferencesInit(notification: NSNotification) {
        self.preferences = notification.object as! Preferences;
        self.gravitySlider.doubleValue = Double(preferences.gravity);
        self.nextBallMassSlider.doubleValue = Double(preferences.nextBallMass);
        self.nextBallRadiusSlider.doubleValue = Double(preferences.nextBallRadius);
    }
    
    @objc func worldSaved(_: NSNotification) {
        self.savedGamesTable.reloadData();
    }
}