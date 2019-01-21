//
//  ViewController.swift
//  ImageRecognizer
//
//  Created by Dan Korkelia on 21/01/2019.
//  Copyright © 2019 Dan Korkelia. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelView.alpha = 0.5
        labelView.layer.cornerRadius = 4.5
        
        let captureSession = AVCaptureSession()
        /// Presets
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        
        /// Get Access to Camera Frame Layer
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
//         print("Camera was able to capture a frame", Date())
        
        ///Analyse what camera is showing
        
        guard let cvPixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        
        let request = VNCoreMLRequest(model: model) { (finishedRequest, Error) in
            
            print("There is an \(String(describing: Error))")
            
            guard let result = finishedRequest.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = result.first else { return }
            
            DispatchQueue.main.async {
                self.identifierLabel.text = firstObservation.identifier
                self.confidenceLabel.text = "\(firstObservation.confidence)"
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: cvPixelBuffer, options: [:]).perform([request])
    }


    

}

