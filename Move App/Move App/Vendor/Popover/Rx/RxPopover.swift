//
//  RxPopover.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/15.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift

class RxPopover {
    var style = PopoverView.Style.default
    var hasSelected = false
    
    func show (toView: UIView, actions: [PopoverAction]) -> Observable<PopoverAction> {
        let _style = self.style
        let _hasSelected = self.hasSelected
        return Observable.create { observer in
            let rxActions = actions.map { action in
                return BasePopoverAction(imageUrl: action.imageUrl,
                                     placeholderImage: action.placeholderImage,
                                     title: action.title,
                                     handler: {
                                        observer.on(.next($0))
                })
            }
            let popoerView = PopoverView(hasSelected: _hasSelected)
            popoerView.style = _style
            popoerView.hideClosure = {
                observer.on(.completed)
            }
            popoerView.show(toView: toView, with: rxActions)
            
            return Disposables.create()
        }
    }
    
}
