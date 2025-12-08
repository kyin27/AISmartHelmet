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
        GeometryReader { geo in
            ZStack {
                CameraPreview(session: camera.session)
                    .ignoresSafeArea()

                DetectionOverlay(detections: camera.detections, frameSize: geo.size)
            }
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
