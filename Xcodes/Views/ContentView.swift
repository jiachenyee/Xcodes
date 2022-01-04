//
//  ContentView.swift
//  Ambar
//
//  Created by Anagh Sharma on 12/11/19.
//

import SwiftUI
import AppKit

struct ContentView: View {
    
    @StateObject var xcodeViewModel = XcodeViewModel()
    @State var searchText = ""
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search Version Numbers", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding([.top, .horizontal])
            .padding(.bottom, 8)
            
            List {
                ForEach(getSearchResults()) { xcode in
                    Button {
                        if xcode.url.pathComponents.contains("Older Versions") {
                            
                            shell(command: "open \(xcode.url.appendingPathComponent("Contents/MacOS/Xcode").path.replacingOccurrences(of: " ", with: "\\ "))")
                        } else {
                            NSWorkspace.shared.open(xcode.url)
                        }
                    } label: {
                        VStack {
                            HStack {
                                if let appIcon = xcode.appIcon {
                                    Image(nsImage: appIcon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 45, height: 45)
                                }
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(xcode.url.lastPathComponent)
                                            .multilineTextAlignment(.leading)
                                            .font(.headline)
                                        Spacer()
                                        Image(systemName: "circle.fill")
                                            .foregroundColor(xcode.isRunning() ? .green : .red)
                                    }
                                    Text("Version: \(xcode.version)")
                                        .multilineTextAlignment(.leading)
                                        .font(.subheadline)
                                    Text(xcode.url.path)
                                        .multilineTextAlignment(.leading)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .foregroundColor(Color(NSColor.labelColor))
                                
                                Spacer()
                            }
                            Divider()
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding(0)
        .frame(width: 360.0, height: 360.0, alignment: .top)
    }
    
    func getSearchResults() -> [Xcode] {
        var searchDataSource = xcodeViewModel.xcodes
        
        let filteredSearch = searchText.filter {
            $0.isNumber || $0 == "."
        }
        
        if filteredSearch != "" {
            searchDataSource = xcodeViewModel.xcodes.filter {
                $0.version.contains(filteredSearch)
            }
        }
        
        return searchDataSource
    }
    
    func shell(command: String) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["bash", "-c", command]
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
