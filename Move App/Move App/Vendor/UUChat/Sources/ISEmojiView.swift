//
//  ISEmojiView.swift
//  Pods
//
//  Created by isaced on 2016/11/8.
//
//

import UIKit
import SwiftGifOrigin

/// emoji view action callback delegate
protocol ISEmojiViewDelegate: class {
    
    /// did press a emoji button
    ///
    /// - Parameters:
    ///   - emojiView: the emoji view
    ///   - emoji: a emoji
    func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: EmojiType)
    
    
    /// will delete last character in you input view
    ///
    /// - Parameter emojiView: the emoji view
    func emojiViewDidPressDeleteButton(emojiView: ISEmojiView)
}

fileprivate let EmojiSize = CGSize(width: 48, height: 48)
fileprivate let EmojiFontSize = CGFloat(30.0)
fileprivate let collectionInset = UIEdgeInsets(top: 10, left: 26, bottom: 38, right: 26)
fileprivate let collectionMinimumLineSpacing = CGFloat(10)
fileprivate let collectionMinimumInteritemSpacing = CGFloat(0)
//fileprivate let ISMainBackgroundColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1)
fileprivate let ISMainBackgroundColor = UIColor.white

/// A emoji keyboard view
class ISEmojiView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {

    /// the delegate for callback
    weak var delegate: ISEmojiViewDelegate?
    
    /// long press to pop preview effect like iOS10 system emoji keyboard, Default is true
    var isShowPopPreview = true
    
    private var defaultFrame: CGRect {
        return CGRect(x: 0, y: 53, width: UIScreen.main.bounds.width, height: 150)
    }
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = EmojiSize
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = collectionMinimumLineSpacing
        layout.minimumInteritemSpacing = collectionMinimumInteritemSpacing
        layout.sectionInset = collectionInset
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collection.backgroundColor = ISMainBackgroundColor
        collection.register(ISEmojiCell.self, forCellWithReuseIdentifier: "cellEmoji")
        return collection
    }()
    var pageControl: UIPageControl = {
        let pageContr = UIPageControl()
        pageContr.hidesForSinglePage = true
        pageContr.currentPage = 0
        pageContr.backgroundColor = .clear
        return pageContr
    }()
    var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        //let deleteButtonImage = UIImage(named: "icon_delete", in: ISEmojiView.thisBundle(), compatibleWith: nil)
        let deleteButtonImage = UIImage(named: "icon_delete")
        button.setImage(deleteButtonImage, for: .normal)
        button.tintColor = .lightGray
        button.isHidden = true
        return button
    }()
    
    var emojis: [[EmojiType]]!
    
    fileprivate let emojiPopView = ISEmojiPopView()
    
    init(emojis: [[EmojiType]]) {
        self.init()
        
        self.emojis = emojis
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
     override func layoutSubviews() {
        updateControlLayout()
    }

    private func setupUI() {
        frame = defaultFrame
        
        // Default emojis
        if emojis == nil {
            self.emojis = ISEmojiView.defaultEmojis()
        }
        
        // ScrollView
        collectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150) //self.bounds
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        collectionView.reloadData()
        
        // PageControl
        pageControl.addTarget(self, action: #selector(pageControlTouched), for: .touchUpInside)
        pageControl.pageIndicatorTintColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 0.0, green: 0.572549045085907, blue: 0.921568632125854, alpha: 1.0)
        pageControl.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        addSubview(pageControl)
        
        // DeleteButton
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        addSubview(deleteButton)
        
        // Long press to pop preview
        let emojiLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(emojiLongPressHandle))
        self.addGestureRecognizer(emojiLongPressGestureRecognizer)
        addSubview(emojiPopView)
    }
    
    private func updateControlLayout() {
        frame = defaultFrame
        
        // update page control
        let pageCount = collectionView.numberOfSections
        let pageControlSizes = pageControl.size(forNumberOfPages: pageCount)
        pageControl.frame = CGRect(x: frame.midX - pageControlSizes.width / 2.0,
                                        y: frame.height-pageControlSizes.height,
                                        width: pageControlSizes.width,
                                        height: pageControlSizes.height)
        pageControl.numberOfPages = pageCount
        
        // update delete button
        deleteButton.frame = CGRect(x: frame.width - 48, y: frame.height - 40, width: 40, height: 40)
    }
    
    //MARK: LongPress
    @objc private func emojiLongPressHandle(sender: UILongPressGestureRecognizer){
        guard isShowPopPreview else { return }
        
        let location = sender.location(in: collectionView)
        if longPressLocationInEdge(location) {
            if let indexPath = collectionView.indexPathForItem(at: location), let attr = collectionView.layoutAttributesForItem(at: indexPath) {
                let emoji = emojis[indexPath.section][indexPath.row]
                if sender.state == .ended {
                    emojiPopView.dismiss()
                    self.delegate?.emojiViewDidSelectEmoji(emojiView: self, emoji: emoji)
                }else{
                    let cellRect = attr.frame
                    let cellFrameInSuperView = collectionView.convert(cellRect, to: self)
                    emojiPopView.setEmoji(emoji)
                    let emojiPopLocaltion = CGPoint(x: cellFrameInSuperView.origin.x - ((topPartSize.width - bottomPartSize.width) / 2.0) + 5,
                                                    y: cellFrameInSuperView.origin.y - topPartSize.height - 10)
                    emojiPopView.move(location: emojiPopLocaltion, animation: sender.state != .began)
                }
            }else{
                emojiPopView.dismiss()
            }
        }else{
            emojiPopView.dismiss()
        }
    }
    
    private func longPressLocationInEdge(_ location: CGPoint) -> Bool {
        let edgeRect = UIEdgeInsetsInsetRect(collectionView.bounds, collectionInset)
        return edgeRect.contains(location)
    }
    
    //MARK: <UICollectionView>
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return emojis.count
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis[section].count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellEmoji", for: indexPath) as! ISEmojiCell
        cell.setEmoji(emojis[indexPath.section][indexPath.row])
        return cell
    }
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emoji = emojis[indexPath.section][indexPath.row]
        self.delegate?.emojiViewDidSelectEmoji(emojiView: self, emoji: emoji)
    }
    
    //MARK: <UIScrollView>
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let firstVisibleCell = collectionView.visibleCells.first {
            if let indexpath = collectionView.indexPath(for: firstVisibleCell){
                pageControl.currentPage = indexpath.section
            }
        }
    }
    
    @objc private func deleteButtonPressed(sender: UIButton) {
        self.delegate?.emojiViewDidPressDeleteButton(emojiView: self)
    }
    
    @objc private func pageControlTouched(sender: UIPageControl) {
        var bounds = collectionView.bounds
        bounds.origin.x = bounds.width * CGFloat(sender.currentPage)
        collectionView.scrollRectToVisible(bounds, animated: true)
    }
    
    static private func defaultEmojis() -> [[EmojiType]] {
        return EmojiType.getEmojis()
    }
}

/// the emoji cell in the grid
fileprivate class ISEmojiCell: UICollectionViewCell {
    
    var emojiImage: UIImageView = {
        let $ = UIImageView()
        return $
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI() {
        emojiImage.frame = bounds
        self.addSubview(emojiImage)
    }
    
    func setEmoji(_ emoji: EmojiType) {
        self.emojiImage.loadStatic(emoji: emoji)
    }
}

fileprivate let topPartSize = CGSize(width: EmojiSize.width * 1.3, height: EmojiSize.height * 1.6)
fileprivate let bottomPartSize = CGSize(width: EmojiSize.width * 0.8, height: EmojiSize.height + 10)

fileprivate class ISEmojiPopView: UIView {
    
    var emojiImage: UIImageView = {
        let $ = UIImageView()
        return $
    }()
    
    let EmojiPopViewSize = CGSize(width: topPartSize.width, height: topPartSize.height + bottomPartSize.height)
    let popBackgroundColor = UIColor.white
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: EmojiPopViewSize.width, height: EmojiPopViewSize.height))
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupUI() {
        // path
        let path = CGMutablePath()
        path.addRoundedRect(in: CGRect(x: 0, y: 0, width: topPartSize.width, height: topPartSize.height),
                            cornerWidth: 10,
                            cornerHeight: 10)
        path.addRoundedRect(in: CGRect(x: topPartSize.width / 2.0 - bottomPartSize.width / 2.0,
                                       y: topPartSize.height - 10,
                                       width: bottomPartSize.width,
                                       height: bottomPartSize.height + 10),
                            cornerWidth: 5,
                            cornerHeight: 5)
        
        // border
        let borderLayer = CAShapeLayer()
        borderLayer.path = path
        borderLayer.strokeColor = UIColor(white: 0.8, alpha: 1).cgColor //UIColor.red.cgColor
        borderLayer.lineWidth = 1
        self.layer.addSublayer(borderLayer)
        
        // mask
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        
        // content layer
        let contentLayer = CALayer()
        contentLayer.frame = bounds
        contentLayer.backgroundColor = popBackgroundColor.cgColor
        contentLayer.mask = maskLayer
        
        layer.addSublayer(contentLayer)
        
        // add label
        emojiImage.frame = CGRect(x: 0, y: 0, width: bounds.width, height: topPartSize.height)
        self.addSubview(emojiImage)
        
        isUserInteractionEnabled = false
        isHidden = true
    }
    
    func move(location: CGPoint, animation: Bool = true) {
        UIView.animate(withDuration: animation ? 0.08 : 0, animations: {
            self.alpha = 1
            self.frame = CGRect(x: location.x, y: location.y, width: self.frame.width, height: self.frame.height)
        }, completion: { complate in
            self.isHidden = false
        })
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.08, animations: {
            self.alpha = 0
        }, completion: { complate in
            self.isHidden = true
        })
    }
    
    func setEmoji(_ emoji: EmojiType) {
        self.emojiImage.load(emoji: emoji)
    }
}

extension UIImageView {
    
    func load(emoji: EmojiType) {
        if let url = emoji.url {
            if emoji.isDynamic {
                self.loadAnimation(imageURL: url, duration: emoji.duration)
            } else {
                self.image = (try? Data(contentsOf: url)).flatMap{ UIImage(data: $0) }
            }
        }
    }
    
    func loadStatic(emoji: EmojiType) {
        if let url = emoji.url {
            if emoji.isDynamic {
                self.loadAnimation(imageURL: url, duration: 0)
            } else {
                self.image = (try? Data(contentsOf: url)).flatMap{ UIImage(data: $0) }
            }
        }
    }
    
    func loadAnimation(imageURL: URL, duration: TimeInterval) {
        if let data = try? Data(contentsOf: imageURL) {
            self.image = UIImage.gif(data: data)
        }
        
//        let manager = FileManager.default
//        self.stopAnimating()
//        if
//            let contentsOfURL = try? manager.contentsOfDirectory(at: imageURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants),
//            let first = contentsOfURL.first {
//            self.image = (try? Data(contentsOf: first)).flatMap{ UIImage(data: $0) }
//            
//            guard duration != 0 else { return }
//            self.animationImages = contentsOfURL.flatMap{ try? Data(contentsOf: $0) }.flatMap{ UIImage(data: $0) }
//            self.animationDuration = duration
//            self.animationRepeatCount = 0
//            self.backgroundColor = UIColor.clear
//            self.startAnimating()
//        }
    }
    
}
