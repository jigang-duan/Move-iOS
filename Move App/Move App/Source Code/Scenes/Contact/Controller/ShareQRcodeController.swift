//
//  ShareQRcodeController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/2.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import ObjectMapper


class ShareQRcodeController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let info = self.makeQRinfo()
        let img = self.createQRForString(qrString: info)
    }
    
    
    struct QRcodeInfo : Mappable{
        var _embeded: Embeded?
        var _links: Links?
        
        init() {
        }
        
        init?(map: Map) {
        }
        
        mutating func mapping(map: Map) {
            _embeded <- map["_embeded"]
            _links <- map["_links"]
        }
    }
    
    struct Embeded {
        var imei: String?
        var expired_at: Date?
        var phone: String?
        var identity: String?
    }
    
    struct Links {
        var join: Join?
    }
    
    struct Join {
        var href: String?
    }
    
    
    func makeQRinfo() -> String{
        let info = QRcodeInfo()
        
        
        
        return info.toJSONString()!
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
    
    
    
    
    
}


