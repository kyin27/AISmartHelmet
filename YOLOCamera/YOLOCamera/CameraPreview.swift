//
//  CameraPreview.swift
//  YOLOCamera
//
//  Created by Joshua Lin on 12/5/25.
//
import SwiftUI
import UIKit
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        // nothing needed
    }
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOrientationObserver()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOrientationObserver()
    }

    private func setupOrientationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    @objc private func orientationChanged() {
        guard let connection = videoPreviewLayer.connection else { return }

        let orientation = UIDevice.current.orientation
        var rotationAngle: CGFloat = 0

        switch orientation {
        case .landscapeRight:
            rotationAngle = CGFloat.pi / 2
            connection.videoRotationAngle = 270
        case .landscapeLeft:
            rotationAngle = -CGFloat.pi / 2
            connection.videoRotationAngle = 90
        case .portraitUpsideDown:
            rotationAngle = CGFloat.pi
            connection.videoRotationAngle = 180
        default:
            rotationAngle = 0
            connection.videoRotationAngle = 0
        }

        videoPreviewLayer.setAffineTransform(CGAffineTransform(rotationAngle: rotationAngle))
        videoPreviewLayer.frame = bounds
    }
}

