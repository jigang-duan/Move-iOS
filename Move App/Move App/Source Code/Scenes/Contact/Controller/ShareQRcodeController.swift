//
//  ShareQRcodeController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/2.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit


class ShareQRcodeController: UIViewController {
    
    @IBOutlet weak var headImgV: UIImageView!
    @IBOutlet weak var kidName: UILabel!
    @IBOutlet weak var QRimgV: UIImageView!
    @IBOutlet weak var countDownTime: UILabel!
    
    @IBOutlet weak var screenShotView: UIView!
    
    var relation: String?
    var memberName: String?
    var memberPhone: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        let info = self.makeQRinfo()
        QRimgV.image = self.createQRForString(qrString: info)
    }

    
    
    func makeQRinfo() -> String{
        let device = DeviceManager.shared.currentDevice!
        
        let downTime = Date(timeIntervalSinceNow: 3600)
        
        headImgV.imageFromURL(device.user?.profile ?? "", placeholder: R.image.relationship_ic_other()!)
        kidName.text = device.user?.nickname
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        countDownTime.text = format.string(from: downTime)
        
        let embededDic = ["imei": device.deviceId ?? "", "expired_at": countDownTime.text ?? "", "phone":self.memberPhone ?? "", "identity":self.relation ?? ""]
        
        let linksDic = ["join":["href": "/v1.0/device/" + device.deviceId! + "join"]]
        
        let dic = ["_embeded": embededDic, "_links":linksDic] as [String : Any]
        
        return self.jsonToString(dic)!
    }
    
    
    func jsonToString(_ JSONObject: Dictionary<String, Any>) -> String? {
        if JSONSerialization.isValidJSONObject(JSONObject) {
            var JSONData: Data?
            do {
                JSONData = try JSONSerialization.data(withJSONObject: JSONObject, options: JSONSerialization.WritingOptions.prettyPrinted)
            } catch let error {
                print(error)
            }
            
            if let json = JSONData {
                if let str = String(data: json, encoding: String.Encoding.utf8) {
                    return str
                }
            }
        }
        
        return ""
    }
    
    func createQRForString(qrString: String, qrImageName: String = "") -> UIImage?{
        let stringData = qrString.data(using: String.Encoding.utf8, allowLossyConversion: false)
        // 创建一个二维码的滤镜
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
        let qrCIImage = qrFilter?.outputImage
        // 创建一个颜色滤镜,黑白色
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setDefaults()
        colorFilter?.setValue(qrCIImage, forKey: "inputImage")
        colorFilter?.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
        colorFilter?.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
        // 返回二维码image
        let codeImage = UIImage(ciImage: (colorFilter?.outputImage?.applying(CGAffineTransform(scaleX: 5, y: 5)))!)
        // 通常,二维码都是定制的,中间都会放想要表达意思的图片
        if let iconImage = UIImage(named: qrImageName) {
            let rect = CGRect(x:0, y:0, width:codeImage.size.width, height:codeImage.size.height)
            UIGraphicsBeginImageContext(rect.size)
            
            codeImage.draw(in: rect)
            let avatarSize = CGSize(width:rect.size.width * 0.25, height:rect.size.height * 0.25)
            let x = (rect.width - avatarSize.width) * 0.5
            let y = (rect.height - avatarSize.height) * 0.5
            iconImage.draw(in: CGRect(x: x, y: y, width: avatarSize.width, height: avatarSize.height))
            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            return resultImage
        }
        return codeImage
    }
    
    
    func screenShot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(screenShotView.bounds.size, false, 0.0)
        
        screenShotView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    @IBAction func shareQRImage(_ sender: Any) {
        let activity = UIActivity()
        
        let vc = UIActivityViewController(activityItems: ["分享标题", self.screenShot()], applicationActivities: [activity])
        vc.excludedActivityTypes = [UIActivityType.assignToContact, UIActivityType.mail, UIActivityType.message,UIActivityType.postToWeibo, UIActivityType.postToFacebook];
        self.present(vc, animated: true, completion: {
        
        })
    }
    
}


