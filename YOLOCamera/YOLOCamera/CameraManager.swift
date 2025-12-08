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
    private let detector = YOLODetector.shared

    override init() {
        super.init()
        start()
    }

    private func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    if granted { self.configureSession() }
                    else { print("❌ Camera access denied") }
                }
            }
        default:
            print("❌ Camera access unavailable (denied/restricted)")
        }
    }

    private func configureSession() {
        print("➡️ Begin ultrawide session configuration")
        session.beginConfiguration()
        session.sessionPreset = .high

        // Discover ultrawide camera
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInUltraWideCamera],
            mediaType: .video,
            position: .back
        )

        guard let device = discovery.devices.first else {
            print("❌ No ultrawide camera found, falling back to wide angle")
            if let fallback = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                addInput(for: fallback)
            }
            session.commitConfiguration()
            return
        }

        addInput(for: device)

        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))

        if session.canAddOutput(output) {
            session.addOutput(output)
            print("✅ Added video output")
        }

        // iOS 17+ uses videoRotationAngle instead of videoOrientation
        if let connection = output.connection(with: .video) {
            connection.videoRotationAngle = 0 // Portrait
        }

        session.commitConfiguration()
        print("➡️ Commit session configuration")

        session.startRunning()
        print("🚀 Session startRunning called")
    }

    private func addInput(for device: AVCaptureDevice) {
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
                print("✅ Added camera input:", device.localizedName)
            }
        } catch {
            print("❌ Failed to create device input:", error.localizedDescription)
        }
    }

    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        Task {
            let results = await detector.detect(pixelBuffer: pixelBuffer)
            await MainActor.run {
                self.detections = results
            }
        }
    }
}
