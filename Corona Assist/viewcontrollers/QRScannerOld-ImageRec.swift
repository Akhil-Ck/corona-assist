//
//  QRScannerViewController.swift
//  MaskDetector
//
//  Created by Akhil C K on 6/25/20.
//  Copyright © 2020 ck. All rights reserved.
//

import UIKit
//import SwiftOCR
import TesseractOCR
import AVFoundation

class QRScannerViewController1: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
     
     @IBOutlet weak var imgV: UIImageView!
     let tesseract = G8Tesseract(language: "eng")!
     
     private(set) lazy var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
     
     private lazy var captureSession: AVCaptureSession = {
          let session = AVCaptureSession()
          session.sessionPreset = AVCaptureSession.Preset.photo
          
          guard
               let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
               let input = try? AVCaptureDeviceInput(device: backCamera)
               else {
                    return session
          }
          
          session.addInput(input)
          return session
     }()
     
     
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          /*let image = UIImage(named: "img_qr")
           qrDetect(image: image!)*/
          
          tesseract.engineMode = .tesseractCubeCombined
          tesseract.pageSegmentationMode = .singleBlock
          //          handleWithTesseract(image: imgV.image!)
          
          addCam()
     }
     private func showCameraFeed() {
          self.previewLayer.videoGravity = .resizeAspectFill
          self.previewLayer.frame = self.imgV.layer.bounds
          self.imgV.layer.addSublayer(self.previewLayer)
          
     }
     func addCam(){
          previewLayer.videoGravity = .resizeAspectFill
          view.layer.addSublayer(previewLayer)
          
          // register to receive buffers from the camera
          let videoOutput = AVCaptureVideoDataOutput()
          videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
          self.captureSession.addOutput(videoOutput)
          
          // begin the session
          self.captureSession.startRunning()
          showCameraFeed()
     }
     
     private func qrDetect(image: UIImage) {
          tesseract.image = image.g8_blackAndWhite()
          tesseract.recognize()
          var text = tesseract.recognizedText ?? ""
          text = text.filter("0123456789/:".contains)
          print("text:1:"+text)
          let date = text.match("([0-9]+)/([0-9]+)/([0-9][0-9])")
          
          let formatter = DateFormatter()
          formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
          let myString = formatter.string(from: Date())
          let yourDate = formatter.date(from: myString)
          formatter.dateFormat = "yyyy/MM/dd"
          let systemDate = formatter.string(from: yourDate!)
          
          var textA1 = date.count > 0 ? date[0] : [""]
          text = textA1.count > 0 ? textA1[0] : ""
          
          print("\n\n\n"+"rec.text ::"+text)
          print("systemDate ::"+systemDate+"\n\n\n")
          
          if(systemDate == text){
               print("++++++++ Date Matches ++++++++")
          }
          
          /*    let result = text.filter("0123456789/:".contains)
           var textA = text.match("([0-9]+)/([0-9]+)/([0-9]+) ([0-9]+):([0-9]+)")
           print("result::"+result)
           print("text::"+text)*/
          
          //delegate?.ocrService(self, didDetect: text)
     }
     
     func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//          handle(buffer: sampleBuffer)
     }
     
     func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
          handle(buffer: sampleBuffer)
     }
     
     func handle(buffer: CMSampleBuffer) {
          //          if let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil) {
          //               let image = UIImage(data: imageData) //  Here you have UIImage
          //               qrDetect(image: image!)
          //
          //          }
          guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else {
               debugPrint("unable to get image from sample buffer")
               return
          }
          
          let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
          guard let image = ciImage.toUIImage() else {
               return
          }
          
          qrDetect(image: image)
     }
     
}
