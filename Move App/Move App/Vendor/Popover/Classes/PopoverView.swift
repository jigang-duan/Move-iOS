//
//  PopoverView.swift
//  test
//
//  Created by Jiang Duan on 17/2/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

fileprivate let kPopoverViewMargin: CGFloat      = 8.0      ///< 边距
fileprivate let kPopoverViewCellHeight: CGFloat  = 40.0     ///< cell指定高度
fileprivate let kPopoverViewArrowHeight: CGFloat = 13.0     ///< 箭头高度


enum PopoverViewStyle {
    case `default`
    case dark
}

class PopoverView: UIView {

//    enum Style {
//        case `default`
//        case dark
//    }
    
    var hasSelected = false
    
    // MARK: - UI
    
    var hideAfterTouchOutside = true {   ///< 是否开启点击外部隐藏弹窗, 默认为YES.
        didSet {
            shadeView.isUserInteractionEnabled = hideAfterTouchOutside
        }
    }
    
    var showShade = false {              ///< 是否显示阴影, 如果为YES则弹窗背景为半透明的阴影层, 否则为透明, 默认为NO.
        didSet {
            shadeView.backgroundColor = showShade ? UIColor(white: 0.0, alpha: 0.18) : UIColor.clear
            if let border = borderLayer {
                border.strokeColor = showShade ? UIColor.clear.cgColor: tableView.separatorColor?.cgColor
            }
        }
    }
    
    var style = PopoverViewStyle.default {          ///< 弹出窗风格, 默认为 PopoverViewStyleDefault(白色).
        didSet {
            tableView.separatorColor = PopoverViewCell.bottomLineColor(style: style)
            self.backgroundColor = style == .default ? UIColor.white : UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1.0)
        }
    }
    
    private weak var keyWindow: UIWindow!       ///< 当前窗口
    private var tableView: UITableView!
    fileprivate var shadeView: UIView!              ///< 遮罩层
    private weak var borderLayer: CAShapeLayer? ///< 边框Layer
    
    // MARK: - Data
    fileprivate var actions: [PopoverAction]!
    private var windowWidth: CGFloat = 0        ///< 窗口宽度
    private var windowHeight: CGFloat = 0        ///< 窗口高度
    private var isUpward = true             ///< 箭头指向, YES为向上, 反之为向下, 默认为YES.
    
    
    init(hasSelected: Bool) {
        self.init()
        self.hasSelected = hasSelected
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.frame = CGRect(x: 0,
                                      y: self.isUpward ? kPopoverViewArrowHeight : 0,
                                      width: self.bounds.width,
                                      height: self.bounds.height - kPopoverViewArrowHeight)
    }
    
    /*! @brief 指向指定的View来显示弹窗 */
    func show(toView pointView: UIView, with actions: [PopoverAction]) {
        // 判断 pointView 是偏上还是偏下
        let pointViewRect: CGRect = pointView.superview!.convert(pointView.frame, to: keyWindow)
        let pointViewUpLength = pointViewRect.midY
        let pointViewDownLength = windowHeight - pointViewRect.maxY
        // 弹窗箭头指向的点
        var toPoint = CGPoint(x: pointViewRect.midX, y: 0)
        if (pointViewUpLength > pointViewDownLength) { // 弹窗在 pointView 顶部
            toPoint.y = pointViewUpLength - 5
        } else { // 弹窗在 pointView 底部
            toPoint.y = pointViewRect.maxY + 5
        }
        
        // 箭头指向方向
        self.isUpward = pointViewUpLength <= pointViewDownLength
        self.actions = actions
        
        self.show(to: toPoint)
    }
    
    /*! @brief 指向指定的点来显示弹窗 */
    func show(toPoint point: CGPoint, with actions: [PopoverAction]) {
        self.actions = actions
        // 计算箭头指向方向
        isUpward = point.y <= windowHeight - point.y
        self.show(to: point)
    }
    
    /*! @brief 显示弹窗指向某个点,  */
    func show(to point: CGPoint) {
        assert(actions.count > 0, "actions must not be nil or empty !")
        
        var toPoint: CGPoint = point
        
        // 截取弹窗时相关数据
        let arrowWidth: CGFloat = 28.0
        let cornerRadius: CGFloat = 6.0
        let arrowCornerRadius: CGFloat = 2.5
        let arrowBottomCornerRadius: CGFloat = 4.0
        
        // 如果箭头指向的点过于偏左或者过于偏右则需要重新调整箭头 x 轴的坐标
        let minHorizontalEdge = kPopoverViewMargin + cornerRadius + arrowWidth/2 + 2
        if toPoint.x < minHorizontalEdge {
            toPoint.x = minHorizontalEdge
        }
        if windowWidth - toPoint.x < minHorizontalEdge {
            toPoint.x = windowWidth - minHorizontalEdge
        }
        
        // 遮罩层
        shadeView.alpha = 0.0
        keyWindow.addSubview(shadeView)
        
        // 刷新数据以获取具体的ContentSize
        tableView.reloadData()
        // 根据刷新后的ContentSize和箭头指向方向来设置当前视图的frame
        let currentW = self.calculateMaxWidth()
        var currentH = tableView.contentSize.height + kPopoverViewArrowHeight
        
        // 限制最高高度, 免得选项太多时超出屏幕
        let maxHeight = isUpward ? (windowWidth - toPoint.y - kPopoverViewMargin) : (toPoint.y - UIApplication.shared.statusBarFrame.height)
        if currentH > maxHeight { // 如果弹窗高度大于最大高度的话则限制弹窗高度等于最大高度并允许tableView滑动.
            currentH = maxHeight
            tableView.isScrollEnabled = true
            if !isUpward { // 箭头指向下则移动到最后一行
                let indexPath = IndexPath.init(row: actions.count - 1, section: 0)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
        
        var currentX = toPoint.x - currentW/2
        var currentY = toPoint.y
        // x: 窗口靠左
        if (toPoint.x <= currentW/2 + kPopoverViewMargin) {
            currentX = kPopoverViewMargin
        }
        // x: 窗口靠右
        if (windowWidth - toPoint.x <= currentW/2 + kPopoverViewMargin) {
            currentX = windowWidth - kPopoverViewMargin - currentW
        }
        // y: 箭头向下
        if (!isUpward) {
            currentY = toPoint.y - currentH;
        }
        
        self.frame = CGRect(x: currentX, y: currentY, width: currentW, height: currentH)
        
        // 截取箭头
        let arrowPoint = CGPoint(x: toPoint.x - self.frame.minX, y: isUpward ? 0 : currentH) // 箭头顶点在当前视图的坐标
        let maskTop = isUpward ? kPopoverViewArrowHeight : 0        // 顶部Y值
        let maskBottom = isUpward ? currentH : currentH - kPopoverViewArrowHeight //底部Y值
        let maskPath = UIBezierPath()
        // 左上圆角
        maskPath.move(to: CGPoint(x: 0, y: cornerRadius + maskTop))
        maskPath.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius + maskTop),
                        radius: cornerRadius,
                        startAngle: DegreesToRadians(180),
                        endAngle: DegreesToRadians(270),
                        clockwise: true)
        // 箭头向上时的箭头位置
        if isUpward {
            maskPath.addLine(to: CGPoint(x: arrowPoint.x - arrowWidth/2,
                                         y: kPopoverViewArrowHeight))
            maskPath.addQuadCurve(to: CGPoint(x: arrowPoint.x - arrowCornerRadius,
                                              y: arrowCornerRadius),
                                  controlPoint: CGPoint(x: arrowPoint.x - arrowWidth/2 + arrowBottomCornerRadius,
                                                        y: kPopoverViewArrowHeight))
            maskPath.addQuadCurve(to: CGPoint(x: arrowPoint.x + arrowCornerRadius,
                                              y: arrowCornerRadius),
                                  controlPoint: arrowPoint)
            maskPath.addQuadCurve(to: CGPoint(x: arrowPoint.x + arrowWidth/2,
                                              y: kPopoverViewArrowHeight),
                                  controlPoint: CGPoint(x: arrowPoint.x + arrowWidth/2 - arrowBottomCornerRadius,
                                                        y: kPopoverViewArrowHeight))
        }
        // 右上圆角
        maskPath.addLine(to: CGPoint(x: currentW - cornerRadius, y: maskTop))
        maskPath.addArc(withCenter: CGPoint(x: currentW - cornerRadius, y: maskTop + cornerRadius),
                        radius: cornerRadius,
                        startAngle: DegreesToRadians(270),
                        endAngle: DegreesToRadians(0),
                        clockwise: true)
        // 右下圆角
        maskPath.addLine(to: CGPoint(x: currentW, y: maskBottom - cornerRadius))
        maskPath.addArc(withCenter: CGPoint(x: currentW - cornerRadius, y: maskBottom - cornerRadius),
                        radius: cornerRadius,
                        startAngle: DegreesToRadians(0),
                        endAngle: DegreesToRadians(90),
                        clockwise: true)
        // 箭头向下时的箭头位置
        if !isUpward {
            maskPath.addLine(to: CGPoint(x: arrowPoint.x + arrowWidth/2,
                                         y: currentH - kPopoverViewArrowHeight))
            maskPath.addQuadCurve(to: CGPoint(x: arrowPoint.x + arrowCornerRadius,
                                              y: currentH - arrowCornerRadius),
                                  controlPoint: CGPoint(x: arrowPoint.x + arrowWidth/2 - arrowBottomCornerRadius,
                                                        y: kPopoverViewArrowHeight))
            maskPath.addQuadCurve(to: CGPoint(x: arrowPoint.x - arrowCornerRadius,
                                              y: currentH - arrowCornerRadius),
                                  controlPoint: arrowPoint)
            maskPath.addQuadCurve(to: CGPoint(x: arrowPoint.x - arrowWidth/2,
                                              y: currentH - kPopoverViewArrowHeight),
                                  controlPoint: CGPoint(x: arrowPoint.x - arrowWidth/2 + arrowBottomCornerRadius,
                                                        y: currentH - kPopoverViewArrowHeight))
        }
        // 左下圆角
        maskPath.addLine(to: CGPoint(x: cornerRadius, y: maskBottom))
        maskPath.addArc(withCenter: CGPoint(x: cornerRadius, y: maskBottom - cornerRadius),
                        radius: cornerRadius,
                        startAngle: DegreesToRadians(90),
                        endAngle: DegreesToRadians(180),
                        clockwise: true)
        maskPath.close()
        // 截取圆角和箭头
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
        // 边框 (只有在不显示半透明阴影层时才设置边框线条)
        if !showShade {
            let borderLayer = CAShapeLayer()
            borderLayer.frame = self.bounds
            borderLayer.path = maskPath.cgPath
            borderLayer.lineWidth = 1
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = tableView.separatorColor?.cgColor
            self.layer.addSublayer(borderLayer)
        }
        keyWindow.addSubview(self)
        
        // 弹出动画
        let oldFrame = self.frame
        self.layer.anchorPoint = CGPoint(x: arrowPoint.x/currentW, y: isUpward ? 0.0 : 1.0)
        self.frame = oldFrame
        self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 0.25) {
            self.transform = CGAffineTransform.identity
            self.shadeView.alpha = 1.0
        }
    }
    
    // MARK: - Private
    private func initialize () {
        
        // current view
        backgroundColor = UIColor.white
        
        // keyWindow
        keyWindow = UIApplication.shared.keyWindow
        windowWidth = keyWindow.bounds.width
        windowHeight = keyWindow.bounds.height
        
        // shadeView
        shadeView = UIView(frame: keyWindow.bounds)
        shadeView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(hide)))
        showShade = false
        
        // tableView
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.separatorColor = PopoverViewCell.bottomLineColor(style: style)
        self.addSubview(tableView)
    }
    
    /*! @brief 计算最大宽度 */
    private func calculateMaxWidth() -> CGFloat {
        var maxWidth: CGFloat = 0
        var titleLeftEdge: CGFloat = 0
        var imageWidth: CGFloat = 0
        let imageMaxHeight = kPopoverViewCellHeight - PopoverViewCell.VerticalMargin * 2
        
        var imageSize = CGSize.zero
        let titleFont = PopoverViewCell.titleFont
        
        for action in actions {
            imageWidth = 0
            titleLeftEdge = 0
            
            if let image = action.placeholderImage { // 存在图片则根据图片size和图片最大高度来重新计算图片宽度
                titleLeftEdge = PopoverViewCell.TitleLeftEdge // 有图片时标题才有左边的边距
                imageSize = image.size
                if imageSize.height > imageMaxHeight {
                    imageWidth = imageMaxHeight * imageSize.width / imageSize.height
                } else {
                    imageWidth = imageSize.width
                }
            }
            
            let titleWidth = action.title?.size(attributes: [NSFontAttributeName : titleFont]).width ?? 20.0
            let contentWidth = PopoverViewCell.HorizontalMargin * 2 + imageWidth + titleLeftEdge + titleWidth
            if contentWidth > maxWidth {
                maxWidth = ceil(contentWidth)
            }
        }
        
        // 如果最大宽度大于(窗口宽度 - kPopoverViewMargin*2)则限制最大宽度等于(窗口宽度 - kPopoverViewMargin*2)
        if maxWidth > keyWindow.bounds.width - kPopoverViewMargin * 2 {
            maxWidth = keyWindow.bounds.width - kPopoverViewMargin * 2
        }
        
        return maxWidth
    }
    
    // convert degrees to radians
    private func DegreesToRadians(_ angle: CGFloat) -> CGFloat {
        return angle * CGFloat.pi / 180
    }
    
    /*! @brief 点击外部隐藏弹窗 */
    func hide () {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            self.shadeView.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }, completion: { (finished) in
            self.hideClosure?()
            self.shadeView.removeFromSuperview()
            self.removeFromSuperview()
        })
    }
    
    func cancel() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            self.shadeView.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }, completion: { _ in
            self.shadeView.removeFromSuperview()
            self.removeFromSuperview()
        })
    }
    
    var hideClosure: (()->Void)?
    
    deinit {
    }
}

extension PopoverView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.actions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kPopoverViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let PopoverCellIdentifier = "PopoverCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: PopoverCellIdentifier) as? PopoverViewCell
        if cell == nil {
            cell = PopoverViewCell(style: .default, reuseIdentifier: PopoverCellIdentifier)
        }
        cell?.hasSelected = self.hasSelected
        
        if self.hasSelected {
            cell?.radioView.isHidden = !self.actions[indexPath.row].isSelected
        }
        
        cell?.setAction(self.actions[indexPath.row])
        cell?.showBottomLine(indexPath.row < self.actions.count-1)
        cell?.style = style
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            self.shadeView.alpha = 0
        }, completion: { (finished) in
            let action = self.actions[indexPath.row]
            action.handler?(action)
            self.actions = nil
            self.hideClosure?()
            self.shadeView.removeFromSuperview()
            self.removeFromSuperview()
        })
    }
}
