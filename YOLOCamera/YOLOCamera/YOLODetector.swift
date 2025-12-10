//
//  YOLODetector.swift
//  YOLOCamera
//
//  Created by Joshua Lin on 12/5/25.
//
import Foundation
import Vision
import CoreML

@MainActor
final class YOLODetector {
    static let shared = YOLODetector()

    private let model: VNCoreMLModel

    private init() {
        guard let coreMLModel = try? carDetectionModel(configuration: MLModelConfiguration()).model,
              let visionModel = try? VNCoreMLModel(for: coreMLModel) else {
            fatalError("Failed to load YOLOv8 Core ML model")
        }

        self.model = visionModel
    }

    func detect(pixelBuffer: CVPixelBuffer) async -> [VNRecognizedObjectObservation] {
        await withCheckedContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, _ in
                let results = request.results as? [VNRecognizedObjectObservation] ?? []
                continuation.resume(returning: results)
            }

            // Preserve aspect ratio when resizing to model input
            request.imageCropAndScaleOption = .scaleFit

            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
            do {
                try handler.perform([request])
            } catch {
                print("Vision request failed:", error.localizedDescription)
                continuation.resume(returning: [])
            }
        }
    }
}







