//
//  MainMap+Controller+Rx.swift
//  Move App
//
//  Created by jiang.duan on 2017/7/12.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: MainMapController {
    
    // Segue
    var segueAllKids: UIBindingObserver<Base, Void> {
        return UIBindingObserver(UIElement: self.base) { controller, info in
            controller.showAllKidsLocationController()
        }
    }
    
    var segueChat: UIBindingObserver<Base, Void> {
        return UIBindingObserver(UIElement: self.base) { controller, info in
            controller.showChat()
        }
    }
    
    // Sheet
    var navigationSheet: UIBindingObserver<Base, AlertServer.NavigateLocation> {
        return UIBindingObserver(UIElement: self.base) { controller, info in
            controller.showNavigationSheetView(locationInfo: info)
        }
    }
}
