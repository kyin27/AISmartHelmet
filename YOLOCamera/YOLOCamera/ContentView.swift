//
//  ContentView.swift
//  YOLOCamera
//
//  Created by Joshua Lin on 12/5/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var camera = CameraManager()

    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .edgesIgnoringSafeArea(.all)
            DetectionOverlay(detections: camera.detections)
        }
    }
}

@main
struct YOLOCameraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#Preview {
    ContentView()
}
