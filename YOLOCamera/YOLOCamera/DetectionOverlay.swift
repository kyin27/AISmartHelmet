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
    let orientation: UIDeviceOrientation

    var body: some View {
        ZStack {
            ForEach(Array(detections.enumerated()), id: \.offset) { _, observation in
                let rect = convert(observation.boundingBox, in: frameSize, orientation: orientation)

                Rectangle()
                    .stroke(Color.red, lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)

                Text(observation.labels.first?.identifier ?? "")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.black.opacity(0.7))
                    .position(x: rect.midX, y: rect.minY - 10)
            }
        }
    }

    private func convert(_ boundingBox: CGRect,
                         in frameSize: CGSize,
                         orientation: UIDeviceOrientation) -> CGRect {
        let w = boundingBox.width * frameSize.width
        let h = boundingBox.height * frameSize.height

        switch orientation {
        case .landscapeRight:
            // Swap axes: Vision's Y becomes X, X becomes Y
            let x = (1 - boundingBox.maxY) * frameSize.width
            let y = boundingBox.minX * frameSize.height
            return CGRect(x: x, y: y, width: w, height: h)

        case .landscapeLeft:
            let x = boundingBox.maxY * frameSize.width
            let y = (1 - boundingBox.minX - boundingBox.width) * frameSize.height
            return CGRect(x: x, y: y, width: w, height: h)

        default: // portrait
            let x = boundingBox.minX * frameSize.width
            let y = (1 - boundingBox.maxY) * frameSize.height
            return CGRect(x: x, y: y, width: w, height: h)
        }
    }

}




