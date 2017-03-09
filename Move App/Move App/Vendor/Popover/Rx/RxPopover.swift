//
//  RxPopover.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/15.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift

extension UIView {
    func popover(style: PopoverViewStyle = .default, hasSelected: Bool = false, actions: [PopoverAction]) {
        let popoerView = PopoverView(hasSelected: hasSelected)
        popoerView.style = style
        popoerView.show(toView: self, with: actions)
    }
}

class RxPopover {
    
    static let shared = RxPopover()
    
    var style = PopoverViewStyle.default
    var hasSelected = false
    
    func promptFor<Action : BasePopoverAction>(toView: UIView, actions: [Action]) -> Observable<BasePopoverAction> {
        let _style = self.style
        let _hasSelected = self.hasSelected
        
        return Observable.create { observer in
            
            var popoverActions: [BasePopoverAction] = []
                for action in actions {
                    let item = BasePopoverAction(
                        imageUrl: action.imageUrl,
                        placeholderImage: action.placeholderImage,
                        title: action.title,
                        isSelected: action.isSelected,
                        handler: {
                            observer.on(.next($0 as! BasePopoverAction))
                    })
                    item.canAvatar = action.canAvatar
                    item.data = action.data
                    popoverActions.append(item)
                }
                
            let popoerView = PopoverView(hasSelected: _hasSelected)
            popoerView.style = _style
            popoerView.hideClosure = {
                observer.on(.completed)
            }
            popoerView.show(toView: toView, with: popoverActions)
            
            return Disposables.create {
                popoerView.cancel()
            }
        }
    }
    
}
