//
//  Theme.swift
//  Pet Finder
//
//  Created by Essan Parto on 5/16/15.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit
//import AFImageHelper
import CustomViews
import Rswift


enum Theme: Int {
  case `default`, dark, graphical

  var mainColor: UIColor {
    switch self {
    case .default:
        return R.color.appColor.primary()
    case .dark:
        return UIColor(r: 242, g: 101, b: 34)
    case .graphical:
        return UIColor(r: 10, g: 10, b: 10)
    }
  }

  var barStyle: UIBarStyle {
    switch self {
    case .default, .graphical:
      return .default
    case .dark:
      return .black
    }
  }
    
    var darkPrimaryColor: UIColor {
        return R.color.appColor.darkPrimary()
    }

  var navigationBackgroundImage: UIImage? {
    return self == .graphical ? R.image.navBackground() : UIImage(gradientColors: [darkPrimaryColor.withAlphaComponent(0.4), darkPrimaryColor],
                                                                  size: CGSize(width: 320, height: 44),
                                                                  locations: [0.0, 1.0])
  }

  var tabBarBackgroundImage: UIImage? {
    return self == .graphical ? R.image.tabBarBackground() : nil
  }

  var backgroundColor: UIColor {
    switch self {
    case .default, .graphical:
      return UIColor(white: 0.9, alpha: 1.0)
    case .dark:
      return UIColor(white: 0.8, alpha: 1.0)
    }
  }

  var secondaryColor: UIColor {
    switch self {
    case .default:
        return R.color.appColor.accent()
    case .dark:
        return UIColor(r: 34, g: 128, b: 66)
    case .graphical:
        return UIColor(r: 140, g: 50, b: 48)
    }
  }
}

let SelectedThemeKey = "SelectedTheme"

struct ThemeManager {

    static func currentTheme() -> Theme {
    
        let storedTheme = UserDefaults.standard.integer(forKey: SelectedThemeKey)
        if let theme = Theme(rawValue: storedTheme) {
            return theme
        } else {
            return .default
        }
    }

    static func applyTheme(theme: Theme) {
        UserDefaults.standard.set(theme.rawValue, forKey: SelectedThemeKey)
        UserDefaults.standard.synchronize()

        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.mainColor
        
        //UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barStyle = theme.barStyle
        UINavigationBar.appearance().tintColor = R.color.appColor.icons()
        UINavigationBar.appearance().setBackgroundImage(theme.navigationBackgroundImage, for: .default)
        UINavigationBar.appearance().backIndicatorImage = R.image.backArrow1()
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = R.image.backArrowMaskFixed()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: R.color.appColor.icons()]
        UINavigationBar.appearance().isTranslucent = false
        
        UIBarButtonItem.appearance().tintColor = R.color.appColor.icons()

        UITabBar.appearance().barStyle = theme.barStyle
        UITabBar.appearance().backgroundImage = theme.tabBarBackgroundImage

        let tabIndicator = R.image.tabBarSelectionIndicator()?.withRenderingMode(.alwaysTemplate)
        let tabResizableIndicator = tabIndicator?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 2.0, bottom: 0, right: 2.0))
        UITabBar.appearance().selectionIndicatorImage = tabResizableIndicator

        let controlBackground = R.image.controlBackground()?
            .withRenderingMode(.alwaysTemplate)
            .resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
        let controlSelectedBackground = R.image.controlSelectedBackground()?
            .withRenderingMode(.alwaysTemplate)
            .resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))

        UISegmentedControl.appearance().setBackgroundImage(controlBackground, for: .normal, barMetrics: .default)
        UISegmentedControl.appearance().setBackgroundImage(controlSelectedBackground, for: .selected, barMetrics: .default)

        UIStepper.appearance().setBackgroundImage(controlBackground, for: .normal)
        UIStepper.appearance().setBackgroundImage(controlBackground, for: .disabled)
        UIStepper.appearance().setBackgroundImage(controlBackground, for: .highlighted)
        UIStepper.appearance().setDecrementImage(R.image.fewerPaws(), for: .normal)
        UIStepper.appearance().setIncrementImage(R.image.morePaws(), for: .normal)

//        UISlider.appearance().setThumbImage(R.image.sliderThumb(), for: .normal)
//        UISlider.appearance().setMaximumTrackImage(R.image.maximumTrack()?
//            .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0.0, bottom: 0, right: 6.0)), for: .normal)
//        UISlider.appearance().setMinimumTrackImage(R.image.minimumTrack()?
//            .withRenderingMode(.alwaysTemplate)
//            .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 6.0, bottom: 0, right: 0)), for: .normal)

        UISwitch.appearance().onTintColor = theme.mainColor.withAlphaComponent(0.7)
        UISwitch.appearance().thumbTintColor = theme.mainColor
        
        UITableView.appearance().backgroundColor = UIColor.groupTableViewBackground
  }
}
