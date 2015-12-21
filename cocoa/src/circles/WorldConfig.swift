//
//  WorldConfig.swift
//  notifications
//
//  Created by Emilio Cobos Alvarez on 12/17/15.
//  Copyright © 2015 Emilio Cobos Alvarez. All rights reserved.
//

import Foundation

class WorldConfig: NSObject {
    var objects: Array<MovingCircle>
    var width: CGFloat
    var height: CGFloat
    var gravity: CGFloat
    
    init(width: CGFloat, height: CGFloat, gravity: CGFloat, objects: Array<MovingCircle>) {
        self.objects = objects;
        self.width = width;
        self.height = height;
        self.gravity = gravity;
    }
}