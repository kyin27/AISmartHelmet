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
    let frameSize: CGSize

    var body: some View {
        ZStack {
            ForEach(detections.indices, id: \.self) { i in
                let observation = detections[i]
                let rect = convert(observation.boundingBox)

                Rectangle()
                    .stroke(Color.red, lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)

                Text(observation.labels.first?.identifier ?? "")
                    .font(.caption)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.7))
                    .position(x: rect.midX, y: rect.minY - 10)
            }
        }
    }

    private func convert(_ boundingBox: CGRect) -> CGRect {
        // Vision boundingBox is normalized (0–1), origin at bottom-left
        let w = boundingBox.width * frameSize.width
        let h = boundingBox.height * frameSize.height
        let x = boundingBox.minX * frameSize.width
        let y = (1 - boundingBox.maxY) * frameSize.height
        return CGRect(x: x, y: y, width: w, height: h)
    }
}



