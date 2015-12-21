//
//  WorldManager.swift
//  circles
//
//  Created by Emilio Cobos Alvarez on 12/21/15.
//  Copyright © 2015 Emilio Cobos Alvarez. All rights reserved.
//

import Foundation
import Cocoa

class WorldManager: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    private static var initWasCalled = false;
    
    var savedWorlds: Array<WorldConfig> = [];
    
    override init() {
        super.init();
        
        // Just one world manager per program, sorry
        assert(!WorldManager.initWasCalled);
        WorldManager.initWasCalled = true;
        
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: "saveWorld:", name: "saveWorld", object: nil);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func saveWorld(notification: NSNotification) {
        self.savedWorlds.append(notification.object as! WorldConfig);
        NSNotificationCenter.defaultCenter()
            .postNotification(NSNotification(name: "worldSaved", object: nil));
    }
    
    func getSavedWorlds() -> Array<WorldConfig> {
        return Array(self.savedWorlds);
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.savedWorlds.count;
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if tableColumn == nil || row >= self.savedWorlds.count {
            return nil
        }
        
        let world = self.savedWorlds[row];
        
        switch tableColumn!.identifier {
        case "width":
            return world.width;
        case "height":
            return world.height;
        case "gravity":
            return world.gravity;
        case "ballCount":
            return world.objects.count;
        default:
            return nil;
        }
    }
    
    @IBAction func doubleClicked(sender: NSTableView) {
        let row = sender.clickedRow;
        
        if row < 0 || row >= self.savedWorlds.count {
            return
        }
        
        NSNotificationCenter.defaultCenter()
            .postNotification(NSNotification(name: "resetWorld", object: self.savedWorlds[row]));
        NSNotificationCenter.defaultCenter()
            .postNotification(NSNotification(name: "displaySimulation", object: nil));
    }
}