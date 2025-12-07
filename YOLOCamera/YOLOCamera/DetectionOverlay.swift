//
//  DetectionOverlay.swift
//  YOLOCamera
//
//  Created by Joshua Lin on 12/5/25.
//
import SwiftUI
import Vision

struct DetectionOverlay: View {
    let detections: [VNRecognizedObjectObservation]

    var body: some View {
        GeometryReader { geo in
            ForEach(detections, id: \.uuid) { det in
                let rect = det.boundingBox
                let box = CGRect(
                    x: rect.minX * geo.size.width,
                    y: (1 - rect.maxY) * geo.size.height,
                    width: rect.width * geo.size.width,
                    height: rect.height * geo.size.height
                )

                ZStack {
                    Rectangle()
                        .stroke(Color.red, lineWidth: 2)
                        .frame(width: box.width, height: box.height)
                        .position(x: box.midX, y: box.midY)

                    Text(det.labels.first?.identifier ?? "")
                        .foregroundColor(.yellow)
                        .position(x: box.minX, y: box.minY)
                }
            }
        }
    }
}


