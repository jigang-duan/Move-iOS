//
//  Ble+Apn.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/29.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation


/*
 蓝牙数据结构  |-----最大20长度-----|
 |开始符|总包|第几包|数据长度|---数据---|CRC16|结束符|
*/


class ApnBleTool {
    
    
    static let transSymbol: UInt8 = 0xDD//转译符
    static let beginSymbol: UInt8 = 0xFF//开始符
    static let endSymbol: UInt8 = 0x55//结束符
    
    //校验公式为0x1021
    private static let CRC16Table: [UInt16] = [
        /* CRC16 余式表 */
        0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7, 0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c,
        0xd1ad, 0xe1ce, 0xf1ef, 0x1231, 0x0210, 0x3273, 0x2252, 0x52b5, 0x4294, 0x72f7, 0x62d6, 0x9339, 0x8318,
        0xb37b, 0xa35a, 0xd3bd, 0xc39c, 0xf3ff, 0xe3de, 0x2462, 0x3443, 0x0420, 0x1401, 0x64e6, 0x74c7, 0x44a4,
        0x5485, 0xa56a, 0xb54b, 0x8528, 0x9509, 0xe5ee, 0xf5cf, 0xc5ac, 0xd58d, 0x3653, 0x2672, 0x1611, 0x0630,
        0x76d7, 0x66f6, 0x5695, 0x46b4, 0xb75b, 0xa77a, 0x9719, 0x8738, 0xf7df, 0xe7fe, 0xd79d, 0xc7bc, 0x48c4,
        0x58e5, 0x6886, 0x78a7, 0x0840, 0x1861, 0x2802, 0x3823, 0xc9cc, 0xd9ed, 0xe98e, 0xf9af, 0x8948, 0x9969,
        0xa90a, 0xb92b, 0x5af5, 0x4ad4, 0x7ab7, 0x6a96, 0x1a71, 0x0a50, 0x3a33, 0x2a12, 0xdbfd, 0xcbdc, 0xfbbf,
        0xeb9e, 0x9b79, 0x8b58, 0xbb3b, 0xab1a, 0x6ca6, 0x7c87, 0x4ce4, 0x5cc5, 0x2c22, 0x3c03, 0x0c60, 0x1c41,
        0xedae, 0xfd8f, 0xcdec, 0xddcd, 0xad2a, 0xbd0b, 0x8d68, 0x9d49, 0x7e97, 0x6eb6, 0x5ed5, 0x4ef4, 0x3e13,
        0x2e32, 0x1e51, 0x0e70, 0xff9f, 0xefbe, 0xdfdd, 0xcffc, 0xbf1b, 0xaf3a, 0x9f59, 0x8f78, 0x9188, 0x81a9,
        0xb1ca, 0xa1eb, 0xd10c, 0xc12d, 0xf14e, 0xe16f, 0x1080, 0x00a1, 0x30c2, 0x20e3, 0x5004, 0x4025, 0x7046,
        0x6067, 0x83b9, 0x9398, 0xa3fb, 0xb3da, 0xc33d, 0xd31c, 0xe37f, 0xf35e, 0x02b1, 0x1290, 0x22f3, 0x32d2,
        0x4235, 0x5214, 0x6277, 0x7256, 0xb5ea, 0xa5cb, 0x95a8, 0x8589, 0xf56e, 0xe54f, 0xd52c, 0xc50d, 0x34e2,
        0x24c3, 0x14a0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405, 0xa7db, 0xb7fa, 0x8799, 0x97b8, 0xe75f, 0xf77e,
        0xc71d, 0xd73c, 0x26d3, 0x36f2, 0x0691, 0x16b0, 0x6657, 0x7676, 0x4615, 0x5634, 0xd94c, 0xc96d, 0xf90e,
        0xe92f, 0x99c8, 0x89e9, 0xb98a, 0xa9ab, 0x5844, 0x4865, 0x7806, 0x6827, 0x18c0, 0x08e1, 0x3882, 0x28a3,
        0xcb7d, 0xdb5c, 0xeb3f, 0xfb1e, 0x8bf9, 0x9bd8, 0xabbb, 0xbb9a, 0x4a75, 0x5a54, 0x6a37, 0x7a16, 0x0af1,
        0x1ad0, 0x2ab3, 0x3a92, 0xfd2e, 0xed0f, 0xdd6c, 0xcd4d, 0xbdaa, 0xad8b, 0x9de8, 0x8dc9, 0x7c26, 0x6c07,
        0x5c64, 0x4c45, 0x3ca2, 0x2c83, 0x1ce0, 0x0cc1, 0xef1f, 0xff3e, 0xcf5d, 0xdf7c, 0xaf9b, 0xbfba, 0x8fd9,
        0x9ff8, 0x6e17, 0x7e36, 0x4e55, 0x5e74, 0x2e93, 0x3eb2, 0x0ed1, 0x1ef0 ]
    
    
    class func CRC16(data: Data) -> Data {
        var crc: UInt16 = 0xA1EC  //初始值
        for byte in data {
            crc = (crc << 8) ^ CRC16Table[Int(((crc >> 8) ^ UInt16(byte)) & 0xff)]
        }
        
        var resData = Data()
        resData.append(UInt8(crc >> 8))
        resData.append(UInt8(truncatingBitPattern: crc >> 0))
        
        return resData
    }

    
    //    数据转译
    class func dataTrans(with data: Data) -> Data {
        
        var tempData = Data()
        
        for byte in data {
            if byte == transSymbol || byte == beginSymbol || byte == endSymbol {
                tempData.append(byte)
            }
            tempData.append(byte)
        }
        
        return tempData
    }
    
    
    //    数据解析
    class func dataUntrans(with data: Data) -> Data {
        
        var tempData = Data()
        
        var isTransSymbol = false
        
        for byte in data {
            if isTransSymbol == true {
                isTransSymbol = false
                tempData.append(byte)
            }else{
                if byte == transSymbol {
                    isTransSymbol = true
                }else{
                    tempData.append(byte)
                }
            }
        }
        
        return tempData
    }
    
    
    //    数据打包
    class func package(data: Data) -> Data {
        var resultData = Data()
        //        总包数
        let totalBag = data.count/13 + (data.count%13 == 0 ? 0:1)
        
        for i in 0..<totalBag {
            resultData.append(beginSymbol)//开始符
            resultData.append(UInt8(totalBag))//总包
            resultData.append(UInt8(i + 1))//第几包
            var tempData: Data?
            if i == totalBag - 1 {
                tempData = data.subdata(in: Range(uncheckedBounds: (lower: i*13, upper: data.count)))
                resultData.append(UInt8(data.count - i*13))//长度
            }else{
                tempData = data.subdata(in: Range(uncheckedBounds: (lower: i*13, upper: i*13 + 13)))
                resultData.append(UInt8(13))//长度
            }
            tempData?.append(self.CRC16(data: tempData!))//数据CRC处理
            resultData.append(tempData!)//数据
            resultData.append(endSymbol)//结束符
        }
        return resultData
    }
    
    
    //    数据解包
    class func unPackage(data: Data) -> (data: Data,isDone: Bool,isError: Bool) {
        var resultData = Data()
        var isDone = false
        var isError = false
        
        if data.count > 7 {
            if data[0] == beginSymbol {
                let totalBag = data[1]//总包数
                let bagIndex = data[2]//第几包
                if totalBag == bagIndex {
                    print("数据接收完毕")
                    isDone = true
                }
                let length = data[3]//长度
                
                let tempData = data.subdata(in: Range(uncheckedBounds: (lower: 3, upper: Int(length) + 3)))
                let resData = self.dataUntrans(with: tempData)
                
                let crc = data.subdata(in: Range(uncheckedBounds: (lower: 3 + Int(length), upper: 2 + 3 + Int(length))))//crc
                if crc == self.CRC16(data: resData) {
                    print("数据校验成功")
                    resultData = resData
                    isError = false
                }else{
                    print("数据校验错误")
                    isError = true
                }
            }
        }
        
        return (data: resultData, isDone: isDone, isError: isError)
    }

    
    
    
}
