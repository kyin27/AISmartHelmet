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

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            if let screen = view.window?.windowScene?.screen {
                view.frame = screen.bounds
            }
        }
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

