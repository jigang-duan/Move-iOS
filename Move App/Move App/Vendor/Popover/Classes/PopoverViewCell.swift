//
//  PopoverViewCell.swift
//  test
//
//  Created by Jiang Duan on 17/2/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
//import AFImageHelper
import CustomViews

class PopoverViewCell: UITableViewCell {
    
    static let HorizontalMargin: CGFloat = 15   ///< 水平边距
    static let VerticalMargin: CGFloat = 3.0    ///< 垂直边距
    static let TitleLeftEdge: CGFloat = 8.0     ///< 标题左边边距
    
    lazy var button: UIButton = {
        $0.isUserInteractionEnabled = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.titleLabel?.font = PopoverViewCell.titleFont
        $0.backgroundColor = self.contentView.backgroundColor
        $0.contentHorizontalAlignment = .left
        $0.setTitleColor(UIColor.black, for: .normal)
        return $0
    } (UIButton(type: .custom))
    
    lazy var bottomLine: UIView = {
        $0.backgroundColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    lazy var radioView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIImageView(image: UIImage(named: "home_pop_dot")))
    
    var hasSelected = false {
        didSet {
            self.initialize(hasSelected: hasSelected)
        }
    }
    
    var style: PopoverViewStyle = .default {
        didSet {
            bottomLine.backgroundColor = PopoverViewCell.bottomLineColor(style: style)
            button.setTitleColor(style == .default ? UIColor.black : UIColor.white, for: .normal)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = self.backgroundColor
        self.selectionStyle = .none
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    /*! @brief 标题字体 */
    class var titleFont: UIFont {
        return UIFont.systemFont(ofSize: 15.0)
    }
    
    /*! @brief 底部线条颜色 */
    class func bottomLineColor(style: PopoverViewStyle) -> UIColor {
        return style == .default ? UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0) : UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
    }
    
    func setAction(_ action: PopoverAction) {
        self.button.setTitle(action.title, for: .normal)
        self.button.titleEdgeInsets = (action.placeholderImage != nil) ? UIEdgeInsetsMake(0, PopoverViewCell.TitleLeftEdge, 0, -PopoverViewCell.TitleLeftEdge) : UIEdgeInsets.zero
        
        guard let placeholder = action.placeholderImage else {
            return
        }
        
        let showImage = (action.canAvatar ? self.conver(title: action.title!, size: placeholder.size) : placeholder) ?? placeholder
        guard let url = action.imageUrl else {
            self.button.setImage(self.convert(image: showImage, size: placeholder.size), for: .normal)
            return
        }
        
        let image = UIImage.image(fromURL: url,
                                  placeholder: showImage) { [weak self] in
            if let image = $0 {
                self?.button.setImage(self?.convert(image: image, size: placeholder.size), for: .normal)
            }
        }
        self.button.setImage(self.convert(image: image, size: placeholder.size), for: .normal)
    }
    
    private func convert(image: UIImage?, size: CGSize) -> UIImage? {
        return image?.scale(toSize: size)?.roundCornersToCircle()
    }
    
    private func conver(title: String, size: CGSize) -> UIImage? {
        return CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height),
                          fullName: title).imageRepresentation()
    }
    
    func showBottomLine(_ show: Bool) {
        self.bottomLine.isHidden = !show
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            self.backgroundColor = (style == .default) ? UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0) : UIColor(red: 0.23, green: 0.23, blue: 0.23, alpha: 1.0)
        } else {
            UIView.animate(withDuration: 0.3) {
                self.backgroundColor = UIColor.clear
            }
        }
    }
    
    private func initialize() {

        self.contentView.addSubview(button)
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-margin-[_button]-margin-|",
            metrics: ["margin": PopoverViewCell.HorizontalMargin],
            views: ["_button": button]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-margin-[_button]-margin-|",
            metrics: ["margin": PopoverViewCell.VerticalMargin],
            views: ["_button": button]))

        self.contentView.addSubview(bottomLine)
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[bottomLine]|",
            metrics: nil,
            views: ["bottomLine": bottomLine]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[bottomLine(lineHeight)]|",
            metrics: ["lineHeight": 1 / (UIScreen.main.scale)],
            views: ["bottomLine": bottomLine]))
    }
    
    private func initialize(hasSelected: Bool) {
        self.contentView.removeConstraints(self.contentView.constraints)
        for view in self.contentView.subviews {
            view.removeFromSuperview()
        }
        
        if !hasSelected {
            self.initialize()
            return
        }
        
        self.contentView.addSubview(radioView)
        self.contentView.addSubview(button)
        self.contentView.addConstraint(NSLayoutConstraint(item: radioView,
                                                          attribute: .centerY,
                                                          relatedBy: .equal,
                                                          toItem: self.contentView,
                                                          attribute: .centerY,
                                                          multiplier: 1,
                                                          constant: 0))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-margin-[radion(6)]-margin-[_button]-margin-|",
            metrics: ["margin": PopoverViewCell.HorizontalMargin * 0.5],
            views: ["_button": button, "radion": radioView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-margin-[_button]-margin-|",
            metrics: ["margin": PopoverViewCell.VerticalMargin],
            views: ["_button": button]))
        
        self.contentView.addSubview(bottomLine)
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[bottomLine]|",
            metrics: nil,
            views: ["bottomLine": bottomLine]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[bottomLine(lineHeight)]|",
            metrics: ["lineHeight": 1 / (UIScreen.main.scale)],
            views: ["bottomLine": bottomLine]))
    }
}

fileprivate extension UIImage {
    
    func scale(toSize: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContext(toSize)
        
        self.draw(in: CGRect.init(x: 0, y: 0, width: toSize.width, height: toSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

