//
//  MainMap+Controller+FeatureGudie.swift
//  Move App
//
//  Created by jiang.duan on 2017/7/11.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation

extension MainMapController {
    
    func showFeatureGudieView() {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }
        let headItem = EAFeatureItem(focus: headPortraitOutlet,
                                     focusCornerRadius: headPortraitOutlet.frame.width/2 ,
                                     focus: .zero)
        headItem?.actionTitle = R.string.localizable.id_first_entry_tips()
        headItem?.introduce = R.string.localizable.id_layout_guide_location_chosedevice()
        headItem?.action = { _ in
            let navItem = EAFeatureItem(focus: self.addressScrollLabel,
                                        focusCornerRadius: 6 ,
                                        focus: .zero)
            navItem?.actionTitle = R.string.localizable.id_first_entry_tips()
            navItem?.introduce = R.string.localizable.id_layout_guide_location_navigate()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                self.view.show(with: [navItem!], saveKeyName: "mark:main_map:nav", inVersion: version)
            }
        }
        self.view.show(with: [headItem!], saveKeyName: "mark:main_map:head", inVersion: version)
        
    }
    
    func showNavigationSheetView(locationInfo: KidSate.LocationInfo) {
        let preferredStyle: UIAlertControllerStyle = UIDevice.current.userInterfaceIdiom == .phone ? .actionSheet : .alert
        let title =  "Navigate to kid\'s location"
        let sheetView = UIAlertController(title: title, message: nil, preferredStyle: preferredStyle)
        
        sheetView.addAction(UIAlertAction(title: R.string.localizable.id_cancel(), style: .cancel, handler: nil))
        
        if let name = locationInfo.address, let location = locationInfo.location {
            sheetView.addAction(UIAlertAction(title: "Navigation", style: .default) { _ in
                MapUtility.openPlacemark(name: name, location: location)
            })
        }
        self.present(sheetView, animated: true, completion: nil)
    }
}
