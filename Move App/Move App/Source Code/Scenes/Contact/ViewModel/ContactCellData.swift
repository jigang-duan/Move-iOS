//
//  ContactCellData.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/7.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxDataSources

protocol ContactCellType {
}

struct FamilyMemberCellData: ContactCellType {
    var headUrl: String?
    var isHeartOn: Bool
    var relation: String
    var state: [FamilyMemberCellState]
}

enum FamilyMemberCellState {
    case me
    case master
    case baby
    case other
}
