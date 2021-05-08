//
//  ViewController.swift
//  MaskDetector
//
//  Created by Akhil C K on 5/6/20.
//  Copyright © 2020 ck. All rights reserved.
//

/*import UIKit
import AVFoundation
import Vision
struct Prediction {
    let labelIndex: Int
    let confidence: Float
    let boundingBox: CGRect
}
@available(iOS 11.1, *)
class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
     
     @IBOutlet weak var cameraView: UIView!
     @IBOutlet weak var status: UILabel!
     
     private let captureSession = AVCaptureSession()
     private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
     private let videoDataOutput = AVCaptureVideoDataOutput()
     private var drawings: [CAShapeLayer] = []
     var request:VNCoreMLRequest?
     let semaphore = DispatchSemaphore(value: 1)
     var nmsThreshold:Float = 0.5
     override func viewDidLoad() {
          super.viewDidLoad()
          imageDet()
//          imageDetection()
          self.addCameraInput()
          self.showCameraFeed()
          self.getCameraFrames()
          self.captureSession.startRunning()
     }
     
     
     func imageDet(){
          let mlmodel = maskdetectionclassifiermodel()
          let userDefined: [String: String] = mlmodel.model.modelDescription.metadata[MLModelMetadataKey.creatorDefinedKey]! as! [String : String]
//          let labels = userDefined["classes"]!.components(separatedBy: ",")
          nmsThreshold = 0.5// Float(userDefined["non_maximum_suppression_threshold"]!) ??

          do{
          let model = try VNCoreMLModel(for: mlmodel.model)

               if #available(iOS 13.0, *) {
                    model.featureProvider = ThresholdProvider()
               } else {
                    // Fallback on earlier versions
               }

          request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
              self?.processClassifications(for: request, error: error)
          })
               request!.imageCropAndScaleOption = .scaleFill
          
          }catch{
               fatalError("Failed to load Vision ML model: \(error)")

          }
          
//          let image = UIImage(named: "1")
//          createClassificationsRequest(for: image!)
     }
     
     func createClassificationsRequest(for image: UIImage) {
              print("Classifying...")
              let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!
              guard let ciImage = CIImage(image: image)
                   else {
                        fatalError("Unable to create \(CIImage.self) from \(image).")
              }
              DispatchQueue.global(qos: .userInitiated).async {
                   let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
                   do {
                        try handler.perform([self.request!])
                   }catch {
                        print("Failed to perform \n\(error.localizedDescription)")
                   }
              }
         }
     
     
     func processClassifications(for request: VNRequest, error: Error?) {
               DispatchQueue.main.async {
                    guard let result = request.results
                         else {
                              print("Unable to classify image.\n\(error!.localizedDescription)")
                              return
                    }
                    print("your results are \(type(of: result))")

                    if let results = request.results as? [VNClassificationObservation] {
                        print("your results are of type VNClassificationObservation")
                    }

                    if let results = request.results as? [VNPixelBufferObservation] {
                        print("your results are of type VNPixelBufferObservation")
                    }

                    if let results = request.results as? [VNCoreMLFeatureValueObservation] {
                        print("your results are of type VNCoreMLFeatureValueObservation")
                    }
                    
                    let classifications = result as! [VNClassificationObservation]
                   /* let results = result as! [VNClassificationObservation]
                    let obs : VNCoreMLFeatureValueObservation = (results.first)!

                    let m: MLMultiArray = obs.featureValue.multiArrayValue!
                    var mArrays = [MLMultiArray]()

                    let IMG_SIZE = 250
                    for i in 0..<10 {
                        let start = i*(IMG_SIZE*IMG_SIZE)
                        guard let tmp : MLMultiArray = try? MLMultiArray(shape:[768,768], dataType:MLMultiArrayDataType.double) else {
                            fatalError("Unexpected runtime error. MLMultiArray")
                        }
                        for n in 0..<(IMG_SIZE*IMG_SIZE) {
                            tmp[n] = m[start+n]
                        }
                        mArrays.append(tmp)
                    }*/
//                    mArrays[0].image
//                    imgView.image = mArrays[0].image(offset: 0, scale: 255)!
//
//                    let coordinates = results[0].featureValue.multiArrayValue!
//                    let confidence = results[0].confidence
//
//                    let confidenceThreshold = 0.25
//                    var unorderedPredictions = [Prediction]()
//                    let numBoundingBoxes = confidence.shape[0].intValue
//                    let numClasses = confidence.shape[1].intValue
//                    let confidencePointer = UnsafeMutablePointer<Double>(OpaquePointer(confidence.dataPointer))
//                    let coordinatesPointer = UnsafeMutablePointer<Double>(OpaquePointer(coordinates.dataPointer))
//                    for b in 0..<numBoundingBoxes {
//                        var maxConfidence = 0.0
//                        var maxIndex = 0
//                        for c in 0..<numClasses {
//                            let conf = confidencePointer[b * numClasses + c]
//                            if conf > maxConfidence {
//                                maxConfidence = conf
//                                maxIndex = c
//                            }
//                        }
//                        if maxConfidence > confidenceThreshold {
//                            let x = coordinatesPointer[b * 4]
//                            let y = coordinatesPointer[b * 4 + 1]
//                            let w = coordinatesPointer[b * 4 + 2]
//                            let h = coordinatesPointer[b * 4 + 3]
//
//                            let rect = CGRect(x: CGFloat(x - w/2), y: CGFloat(y - h/2),
//                                              width: CGFloat(w), height: CGFloat(h))
//
//                            let prediction = Prediction(labelIndex: maxIndex,
//                                                        confidence: Float(maxConfidence),
//                                                        boundingBox: rect)
//                            unorderedPredictions.append(prediction)
//                        }
//                    }
//
//     //               # Array to store final predictions (after post-processing)
//                    var predictions: [Prediction] = []
//                    let orderedPredictions = unorderedPredictions.sorted { $0.confidence > $1.confidence }
//                    var keep = [Bool](repeating: true, count: orderedPredictions.count)
//                    for i in 0..<orderedPredictions.count {
//                        if keep[i] {
//                            predictions.append(orderedPredictions[i])
//                            let bbox1 = orderedPredictions[i].boundingBox
//                            for j in (i+1)..<orderedPredictions.count {
//                                if keep[j] {
//                                    let bbox2 = orderedPredictions[j].boundingBox
//                                   if self.IoU(bbox1, bbox2) > self.nmsThreshold {
//                                        keep[j] = false
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    print(predictions.count)
//                    print(predictions)
                    
                    if classifications.isEmpty {
                         print("Nothing recognized.")
                    } else {
                         let topClassifications = classifications.prefix(2)
                         let descriptions = topClassifications.map { classification -> String in
                              print(classification.identifier)
                              if classification.confidence > 0.7{
                                   
                                   self.status.text =  classification.identifier == "without_mask" ? "Without Mask" : "With Mask"
                              }
                              return String(format: "(%.2f) %@", classification.confidence, classification.identifier)
                         }
                         print(descriptions.joined(separator: " |"))
//                         self.status.text = descriptions.joined(separator: " |")
                    }
               }
          }
          
     public func IoU(_ a: CGRect, _ b: CGRect) -> Float {
             let intersection = a.intersection(b)
             let union = a.union(b)
             return Float((intersection.width * intersection.height) / (union.width * union.height))
         }
     


         /*func imageDetection(){
               request = {
               do {
                  let mlmodel = try VNCoreMLModel(for: mymodel().model)
                    
                    let userDefined: [String: String] = mlmodel.model.modelDescription.metadata[MLModelMetadataKey.creatorDefinedKey]! as! [String : String]
                    let labels = userDefined["classes"]!.components(separatedBy: ",")
                  let request = VNCoreMLRequest(model: mlmodel, completionHandler: {   [weak self] request, error in
                    print("model.description: \(model.description)")
                    print(error)
                    
                        self?.processClassifications(for: request, error: error)
               })
                  request.imageCropAndScaleOption = .centerCrop
                  return request
               } catch {
                  fatalError("Failed to load Vision ML model: \(error)")
               }}()
               let image = UIImage(named: "1")
               createClassificationsRequest(for: image!)
          }
          
          func createClassificationsRequest(for image: UIImage) {
               print("Classifying...")
               let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!
               guard let ciImage = CIImage(image: image)
                    else {
                         fatalError("Unable to create \(CIImage.self) from \(image).")
               }
               DispatchQueue.global(qos: .userInitiated).async {
                    let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
                    do {
                         try handler.perform([self.request!])
                    }catch {
                         print("Failed to perform \n\(error.localizedDescription)")
                    }
               }
          }*/
          
          
          
         
          
          
          private func initModel(){
               guard let modelURL = Bundle.main.url(forResource: "mymodel", withExtension: "mlmodel") else { return}
               let visionModel = try! VNCoreMLModel(for: MLModel(contentsOf: modelURL))
               
               request = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                   DispatchQueue.main.async(execute: {
                       // perform all the UI updates on the main queue
                       if let results = request.results {
                         print("results")
                         print(results)
     //                    self.handleFaceDetectionResults(results as! [VNFaceObservation])
                       }
                    
                    if let results = request.results as? [VNClassificationObservation] {
                        print("\(results.first!.identifier) : \(results.first!.confidence)")
                        if results.first!.confidence > 0.9 {
     //                       self.showProductInfo(results.first!.identifier)
                        }
                    }
                    
                   })
               })

          }
          
          private func addCameraInput() {
              guard let device = AVCaptureDevice.DiscoverySession(
                  deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
                  mediaType: .video,
                  position: .front).devices.first else {
                     fatalError("No back camera device found, please make sure to run SimpleLaneDetection in an iOS device and not a simulator")
              }
              let cameraInput = try! AVCaptureDeviceInput(device: device)
              self.captureSession.addInput(cameraInput)
          }

          private func showCameraFeed() {
              self.previewLayer.videoGravity = .resizeAspectFill
               self.previewLayer.frame = self.cameraView.layer.bounds
               self.cameraView.layer.addSublayer(self.previewLayer)

          }
          
     override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          self.previewLayer.frame = self.cameraView.layer.bounds
          self.cameraView.layer.addSublayer(self.previewLayer)
          self.view.layoutIfNeeded()

          }
          
          private func getCameraFrames() {
              self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
              self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
              self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
              self.captureSession.addOutput(self.videoDataOutput)
              guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
                  connection.isVideoOrientationSupported else { return }
              connection.videoOrientation = .portrait
          }
          
          
          func captureOutput(_ output: AVCaptureOutput,
                             didOutput sampleBuffer: CMSampleBuffer,
                             from connection: AVCaptureConnection) {
              guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                  debugPrint("unable to get image from sample buffer")
                  return
              }
     //          initModel()
              self.detectFace(in: frame)
          }
          
          
          private func detectFace(in image: CVPixelBuffer) {
               self.initModel()
//               guard let request = request else { fatalError() }
//               // vision framework configures the input size of image following our model's input configuration automatically
//               self.semaphore.wait()
//               let handler = VNImageRequestHandler(cvPixelBuffer: image)
//               try? handler.perform([request])
               
               let iV = UIImage.init(pixelBuffer: image)!

               createClassificationsRequest(for: iV)
               
               /*
              let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
                  DispatchQueue.main.async {
                      if let results = request.results as? [VNFaceObservation] {
                          self.handleFaceDetectionResults(results)
                      } else {
                          self.clearDrawings()
                      }
                  }
              })
              let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
              try? imageRequestHandler.perform([faceDetectionRequest])*/
          }
          
          
          private func handleFaceDetectionResults(_ observedFaces: [VNFaceObservation]) {
              self.clearDrawings()
              let facesBoundingBoxes: [CAShapeLayer] = observedFaces.map({ (observedFace: VNFaceObservation) -> CAShapeLayer in
                  let faceBoundingBoxOnScreen = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
                  let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
                  let faceBoundingBoxShape = CAShapeLayer()
                  faceBoundingBoxShape.path = faceBoundingBoxPath
                  faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
                  faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
                  return faceBoundingBoxShape
              })
              facesBoundingBoxes.forEach({ faceBoundingBox in self.view.layer.addSublayer(faceBoundingBox) })
              self.drawings = facesBoundingBoxes
          }
          private func clearDrawings() {
              self.drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
          }
          
          

     
}

@available(iOS 11.0, *)
class ThresholdProvider: MLFeatureProvider {

    open var values = [
        "iouThreshold": MLFeatureValue(double: 0.3),
        "confidenceThreshold": MLFeatureValue(double: 0.2)
    ]

    var featureNames: Set<String> {
        return Set(values.keys)
    }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        return values[featureName]
    }
}


import VideoToolbox

extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        guard let cgImag = cgImage else {
            return nil
        }

        self.init(cgImage: cgImag)
    }
}
 
 */
