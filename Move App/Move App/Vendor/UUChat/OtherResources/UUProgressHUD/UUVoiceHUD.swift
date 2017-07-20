//
//  UUVoiceHUD.swift
//  Move App
//
//  Created by jiang.duan on 2017/7/5.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

@objc
protocol UUVoiceHUDDelegate {
    @objc optional func fetchVoice(voiceHUD: UUVoiceHUD) -> Int
}

class UUVoiceHUD: UIView {

    static let shared = UUVoiceHUD()
    
    private init() {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var _overlayWindow: UIWindow?
    var overlayWindow: UIWindow {
        if _overlayWindow == nil {
            _overlayWindow = UIWindow(frame: UIScreen.main.bounds)
            _overlayWindow?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            _overlayWindow?.isUserInteractionEnabled = false
            _overlayWindow?.makeKeyAndVisible()
        }
        return _overlayWindow!
    }
    
    weak var delegate: UUVoiceHUDDelegate?
    
    private var _contentView: UIView?
    private var _centerLabel: UILabel?
    private var _tubeImageView: UIImageView?
    private var _volumeImageView: UIImageView?
    private var _wringImageView: UIImageView?
    private var _subTitleLabel: UILabel?
    
    private var myTimer: Timer?
    
    
    static func show() {
        UUVoiceHUD.shared.show()
    }
    
    static func change(state: State) {
        UUVoiceHUD.shared.set(state: state)
    }
    
    static func dismiss(state: State) {
        UUVoiceHUD.shared.dismiss(state: state)
    }
    
    
    func show() {
        DispatchQueue.main.async {
            if self.superview == nil {
                self.overlayWindow.addSubview(self)
            }
            
            if self._contentView == nil {
                self._contentView = UIView(frame: CGRect(x: 0, y: 0, width: HUD_Center_W, height: HUD_Center_H))
                self._contentView?.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                self._contentView?.layer.cornerRadius = 6.0
                self._contentView?.layer.masksToBounds = true
                self._contentView?.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2 - 46)
            }
            
            if self._centerLabel == nil {
                self._centerLabel = UILabel(frame: CGRect(x: 0, y: HUD_Spse, width: 150, height: 40))
                self._centerLabel?.center.x = HUD_Center_X
                self._centerLabel?.textColor = UIColor.white
                self._centerLabel?.font = UIFont.systemFont(ofSize: 30.0)
                self._centerLabel?.text = "30"
                self._centerLabel?.textAlignment = .center
                self._centerLabel?.isHidden = true
            }
            if self._subTitleLabel == nil {
                self._subTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: HUD_Center_W, height: 20))
                self._subTitleLabel?.backgroundColor = UIColor.clear
                self._subTitleLabel?.center = CGPoint(x: HUD_Center_X, y: HUD_SubTitle_Y)
                self._subTitleLabel?.textAlignment = .center
                self._subTitleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
                self._subTitleLabel?.textColor = UIColor.white
                self._subTitleLabel?.text = R.string.localizable.id_slide_cancel()
            }
            if self._tubeImageView == nil {
                self._tubeImageView = UIImageView(image: R.image.voice())
                self._tubeImageView?.frame.origin = CGPoint(x: 0, y: HUD_Spse)
                self._tubeImageView?.center.x = HUD_Center_X-13.0
            }
            if self._volumeImageView == nil {
                self._volumeImageView = UIImageView(image: R.image.voice_level1())
                self._volumeImageView?.frame.origin = CGPoint(x: 0, y: HUD_Spse)
                self._volumeImageView?.center.x = HUD_Center_X+13.0
            }
            if self._wringImageView == nil {
                self._wringImageView = UIImageView(image: R.image.voice_slideup())
                self._wringImageView?.frame.origin.y = HUD_Spse
                self._wringImageView?.center.x = HUD_Center_X
                self._wringImageView?.isHidden = true
            }
            
            self._contentView?.addSubview(self._centerLabel!)
            self._contentView?.addSubview(self._subTitleLabel!)
            self._contentView?.addSubview(self._tubeImageView!)
            self._contentView?.addSubview(self._volumeImageView!)
            self._contentView?.addSubview(self._wringImageView!)
            self.addSubview(self._contentView!)
            
            if self.myTimer != nil {
                self.myTimer?.invalidate()
            }
            self.myTimer = nil
            self.myTimer = Timer.scheduledTimer(timeInterval: SecondD,
                                                target: self,
                                                selector: #selector(self.startAnimation),
                                                userInfo: nil,
                                                repeats: true)
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState],
                           animations: { 
                                self.alpha = 1.0
                        },
                           completion: nil)
            self.setNeedsDisplay()
        }
    }
    
    @objc private func startAnimation() {
        if let second = _centerLabel?.text?.toDouble() {
            _centerLabel?.text = String(format: "%.1f", second-SecondD)
            if second <= 5.0 {
                _centerLabel?.isHidden = _wringImageView?.isHidden != true
                _tubeImageView?.isHidden = true
                _volumeImageView?.isHidden = true
            } else if let volume = delegate?.fetchVoice?(voiceHUD: self) {
                _volumeImageView?.image = UIImage(named: "voice_level\(volume)")
            }
        }
    }
    
    enum State {
        case succeed
        case tooShort
        case cancel
        case release
        case `default`
    }
    
    func set(state: State) {
        self._subTitleLabel?.text = state.description
        if let wringImage = state.wringImage {
            self._tubeImageView?.isHidden = true
            self._volumeImageView?.isHidden = true
            self._wringImageView?.isHidden = false
            self._wringImageView?.image = wringImage
        } else {
            self._tubeImageView?.isHidden = false
            self._volumeImageView?.isHidden = false
            self._wringImageView?.isHidden = true
        }
    }
    
    func dismiss(state: State) {
        DispatchQueue.main.async {
            
            self.myTimer?.invalidate()
            self.myTimer = nil
            
            self.set(state: state)
            self._centerLabel?.text = nil
            self.overlayWindow.isUserInteractionEnabled = true
            
            UIView.animate(withDuration: state.timeLonger,
                           delay: 0,
                           options: [.curveEaseIn, .allowUserInteraction],
                           animations: { 
                            self.alpha = 0
            },
                           completion: { _ in
                            if self.alpha == 0 {
                                self.delegate = nil
                                
                                self._centerLabel?.removeFromSuperview()
                                self._centerLabel = nil
                                self._tubeImageView?.removeFromSuperview()
                                self._tubeImageView = nil
                                self._volumeImageView?.removeFromSuperview()
                                self._volumeImageView = nil
                                self._wringImageView?.removeFromSuperview()
                                self._wringImageView = nil
                                self._subTitleLabel?.removeFromSuperview()
                                self._subTitleLabel = nil
                                
                                self._contentView?.removeFromSuperview()
                                self._contentView = nil
                                
                                if self._overlayWindow != nil {
                                    let windows = NSMutableArray(array: UIApplication.shared.windows)
                                    windows.remove(self._overlayWindow!)
                                    self._overlayWindow = nil
                                    
                                    windows.enumerateObjects(options: .reverse, using: { (window, idx, stop) in
                                        if let window = window as? UIWindow, window.windowLevel == UIWindowLevelNormal {
                                            window.makeKeyAndVisible()
                                            stop.pointee = ObjCBool(true)
                                        }
                                    })
                                }
                            }
            })
            
        }
    }
}


extension UUVoiceHUD.State: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .tooShort:
            return R.string.localizable.id_too_short()
        case .cancel:
            return R.string.localizable.id_cancel()
        case .release:
            return R.string.localizable.id_release_cancel_send()
        case .default:
            return R.string.localizable.id_slide_cancel()
        case .succeed:
            return "Success"
        }
    }
    
    var timeLonger: TimeInterval {
        switch self {
        case .tooShort:
            return 1.0
        default:
            return 0.6
        }
    }
    
    var wringImage: UIImage? {
        switch self {
        case .tooShort:
            return R.image.voice_short()
        case .release:
            return R.image.voice_slideup()
        case .cancel:
            return R.image.voice_slideup()
        default:
            return nil
        }
    }
}


fileprivate let HUD_Center_W: CGFloat = 180.0
fileprivate let HUD_Center_H: CGFloat = 92.0
fileprivate let HUD_Spse: CGFloat = 20.0
fileprivate let HUD_SubTitle_Y: CGFloat = HUD_Center_H - HUD_Spse
fileprivate let HUD_Center_X: CGFloat = HUD_Center_W/2
fileprivate let HUD_Center_Y: CGFloat = HUD_Center_H/2
fileprivate let SecondD: TimeInterval = 0.1

