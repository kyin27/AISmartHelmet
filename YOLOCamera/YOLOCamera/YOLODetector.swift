//
//  YOLODetector.swift
//  YOLOCamera
//
//  Created by Joshua Lin on 12/5/25.
//
import Foundation
import Vision
import CoreML

final class YOLODetector: @unchecked Sendable {
    private let visionModel: VNCoreMLModel

    init() {
        guard let url = Bundle.main.url(forResource: "best", withExtension: "mlmodelc"),
              let mlModel = try? MLModel(contentsOf: url),
              let vnModel = try? VNCoreMLModel(for: mlModel) else {
            fatalError("Failed to load YOLOv8 Core ML model")
        }
        self.visionModel = vnModel
    }

    nonisolated func detect(pixelBuffer: CVPixelBuffer) async -> [VNRecognizedObjectObservation] {
        let request = await VNCoreMLRequest(model: visionModel)
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])

        do {
            try handler.perform([request])
            let results = request.results as? [VNRecognizedObjectObservation] ?? []
            // Return a copy to satisfy Sendable concerns
            return results.map { $0 }
        } catch {
            return []
        }
    }
}




