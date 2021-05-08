//
//  QRScannerViewController.swift
//  MaskDetector
//
//  Created by Akhil C K on 6/25/20.
//  Copyright © 2020 ck. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerViewController: UIViewController, QRScannerViewDelegate, XMLParserDelegate {
     
     var resultString = ""
     
     var didScan = false{
          didSet{
                    name.isHidden = !didScan
                    qid.isHidden = !didScan
                    date.isHidden = !didScan
                    nameLabel.isHidden = !didScan
                    qidLabel.isHidden = !didScan
                    dateLabel.isHidden = !didScan
          }
     }
     
     var parsedData:[String:String] = [:]

     @IBOutlet weak var nameLabel: UILabel!
     @IBOutlet weak var qidLabel: UILabel!
     @IBOutlet weak var dateLabel: UILabel!
     
     
     @IBOutlet weak var scannerView: QRScannerView!
     @IBOutlet weak var name: UILabel!
     @IBOutlet weak var qid: UILabel!
     @IBOutlet weak var status: UILabel!
     @IBOutlet weak var date: UILabel!
     
     override func viewDidLoad() {
          super.viewDidLoad()
          scannerView.delegate = self
          didScan = false
     }
     
     func qrScanningDidFail() {
          print("---FAIL---")
     }
     
     func qrScanningSucceededWithCode(_ str: String?) {
          print("---SUCCESS XML--- \n \(str) \n")//+ (str ?? "")
          parseData(xml: str ?? "")
     }
     
     func qrScanningDidStop() {
          print("---STOP---")
     }
     
     func parseData(xml:String){
          let data: Data? = xml.data(using: .utf8)
          let parser: XMLParser? = XMLParser(data: data ?? Data())
          parser?.delegate = self
          let result: Bool? = parser?.parse()
          parser?.shouldResolveExternalEntities = true
     }
     
     var currentEle = "id"
     func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
          resultString += elementName + ":"
          currentEle = elementName
     }
     
     func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
     }
     
     func parser(_ parser: XMLParser, foundCharacters string: String) {
          resultString += (string ?? "") + ","
          parsedData[currentEle] = (string ?? "")
     }
     
     func parserDidEndDocument(_ parser: XMLParser) {
          resultString = resultString.trimmingCharacters(in: .whitespacesAndNewlines)
          
          print(parsedData)
          print("DICT \n")
          
          let color = parsedData["v2"] ?? ""
          let name = parsedData["v3"]  ?? ""
          let date = parsedData["v5"] ?? ""
          let id = parsedData["id"] ?? ""
          
          print("DATE:: \(date)")
          print("NAME:: \(name)")
          print("ID:: \(id)")

          self.name.text = name
          self.qid.text = id
          self.date.text = date


          if color == "#11855C" && isDateValid(inputDate: date){
               self.status.text = "SUCCESS"
               self.status.textColor = UIColor.green
               //self.dismiss(animated: true, completion: nil)
          }else{
               self.status.text = "FAILED"
               self.status.textColor = UIColor.red
          }
          
          didScan = true

     }
     
     func isDateValid(inputDate: String) -> Bool {

          let olDateFormatter = DateFormatter()
          olDateFormatter.dateFormat = "MM/dd/yyyy h:mm:ss a"
          let oldDate = olDateFormatter.date(from: inputDate) ?? Date()
          
          let today = Date().dateInTimeZone(timeZoneIdentifier: "UTC", dateFormat: "MM/dd/yyyy h:mm:ss a");
          let todayDate = olDateFormatter.date(from: today)

          let diff = Int((todayDate?.timeIntervalSince(oldDate))!)

          return diff < ( 60 * 60 )// 60 minute
     }
     
}
extension Date {
     
     func dateInTimeZone(timeZoneIdentifier: String, dateFormat: String) -> String  {
          let dtf = DateFormatter()
          dtf.timeZone = TimeZone(identifier: timeZoneIdentifier)
          dtf.dateFormat = dateFormat
          
          return dtf.string(from: self)
     }
}


extension CIImage {
     func toUIImage() -> UIImage? {
          let context: CIContext = CIContext.init(options: nil)
          
          if let cgImage: CGImage = context.createCGImage(self, from: self.extent) {
               return UIImage(cgImage: cgImage)
          } else {
               return nil
          }
     }
}

extension String {
     func match(_ regex: String) -> [[String]] {
          let nsString = self as NSString
          return (try? NSRegularExpression(pattern: regex, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, count)).map { match in
               (0..<match.numberOfRanges).map { match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)) }
               } ?? []
     }
}

