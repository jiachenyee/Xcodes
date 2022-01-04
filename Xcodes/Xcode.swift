//
//  Xcode.swift
//  Ambar
//
//  Created by Jia Chen Yee on 20/12/21.
//  Copyright © 2021 Golden Chopper. All rights reserved.
//

import Foundation
import AppKit

struct Xcode: Identifiable {
    var version: String
    var url: URL
    
    var appIcon: NSImage?
    
    var id: String
    
    func isRunning() -> Bool {
        return NSWorkspace.shared.runningApplications.contains {
            $0.bundleURL == url
        }
    }
}
