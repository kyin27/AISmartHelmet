//
//  CameraManager.swift
//  YOLOCamera
//
//  Created by Joshua Lin on 12/5/25.
//

import Combine

/*
class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let detector = YOLODetector()
    let session = AVCaptureSession()
    @Published var detections: [VNRecognizedObjectObservation] = []

    override init() {
        super.init()
        configureSession()
    }

    func configureSession() {
        session.sessionPreset = .hd1280x720

        guard let device = AVCaptureDevice.default(.builtInUltraWideCamera,
                                                   for: .video,
                                                   position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("Failed to access ultrawide camera")
            return
        }

        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
        session.addOutput(output)

        session.startRunning()
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        detector.detect(pixelBuffer: pixelBuffer) { results in
            DispatchQueue.main.async {
                self.detections = results
            }
        }
    }

    var cameraSession: AVCaptureSession {
        return session
    }
}*/

import Foundation
import AVFoundation
import Vision

@MainActor
final class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var detections: [VNRecognizedObjectObservation] = []
    let session = AVCaptureSession()
    private let detector = YOLODetector()

    override init() {
        super.init()
        configureSession()
    }

    private func configureSession() {
        // Session mutations must occur on the main actor
        self.session.beginConfiguration()
        self.session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              self.session.canAddInput(input) else {
            print("Failed to set up camera input")
            return
        }

        self.session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if self.session.canAddOutput(output) {
            self.session.addOutput(output)
        }

        self.session.commitConfiguration()
        self.session.startRunning()
    }

    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Run detection off the main actor
        Task {
            let results = await detector.detect(pixelBuffer: pixelBuffer)
            // Hop back to main to publish results
            await MainActor.run {
                self.detections = results
            }
        }
    }
}
