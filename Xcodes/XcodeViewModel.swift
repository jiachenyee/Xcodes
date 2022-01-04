//
//  XcodeViewModel.swift
//  Ambar
//
//  Created by Jia Chen Yee on 20/12/21.
//

import Foundation
import SwiftUI

class XcodeViewModel: ObservableObject {
    @Published var xcodes: [Xcode] = []
    
    let applicationsDirectory = URL(fileURLWithPath: "/Applications/")
    
    init() {
        xcodes = getApps(in: applicationsDirectory).sorted {
            $0.version > $1.version
        }
    }
    
    func getApps(in directoryURL: URL) -> [Xcode] {
        let files = (try? FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [], options: [])) ?? []
        
        var apps: [Xcode] = []
        
        for file in files {
            if file.pathExtension == "app" {
                let plistFile = file.appendingPathComponent("Contents/Info.plist")
                
                let decoder = PropertyListDecoder()
                if let decodedXcode = try? decoder.decode(XcodeMetadata.self, from: try! Data(contentsOf: plistFile)) {
                    
                    if decodedXcode.CFBundleIdentifier == "com.apple.dt.Xcode" {
                        let appIcon = NSImage(contentsOf: file.appendingPathComponent("Contents/Resources/Xcode.icns")) ?? NSImage(contentsOf: file.appendingPathComponent("Contents/Resources/XcodeBeta.icns"))
                        
                        apps.append(Xcode(version: decodedXcode.CFBundleShortVersionString, url: file, appIcon: appIcon, id: decodedXcode.DTXcodeBuild))
                    }
                }
                
            } else if file.hasDirectoryPath {
                apps.append(contentsOf: getApps(in: file))
            }
        }
        
        return apps
    }
}

struct XcodeMetadata: Codable {
    var CFBundleIdentifier: String
    var CFBundleShortVersionString: String
    
    var DTXcodeBuild: String
}
