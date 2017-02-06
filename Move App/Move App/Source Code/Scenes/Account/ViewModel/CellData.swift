//
//  CellData.swift
//  Move App
//
//  Created by Jiang Duan on 17/1/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxDataSources

protocol CellDataType {
}

struct UserCellData: CellDataType {
    var iconUrl: String?
    var account: String
    var describe: String
}

struct DeviceCellData: CellDataType {
    var devType: String
    var name: String?
    var iconUrl: String?
}

struct AddDeviceCellData: CellDataType {
    let title: String
    
    init () {
        self.title = R.string.localizable.id_add_device()
    }
}

struct SectionOfCellData {
    var header: String
    var items: [Item]
}
extension SectionOfCellData: SectionModelType {
    typealias Item = CellDataType
    
    init(original: SectionOfCellData, items: [Item]) {
        self = original
        self.items = items
    }
}
