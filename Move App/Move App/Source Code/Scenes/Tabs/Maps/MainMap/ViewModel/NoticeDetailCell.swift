//
//  NoticeDetailCell.swift
//  Move App
//
//  Created by lx on 17/2/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class NoticeDetailCell: UITableViewCell {
    @IBOutlet weak var avatarImg: UIImageView!

    @IBOutlet weak var timezoneL: UILabel!
    @IBOutlet weak var contextTextView: UITextView!
    var _textstr: String?
    var textstr: String? {
        set{
            _textstr = newValue
            var size = CGRect()
            let size2 = CGSize(width: self.contextTextView.frame.size.width, height: 0)
            let attibute = [NSFontAttributeName:self.contextTextView.font]
            size = (_textstr?.boundingRect(with: size2, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attibute , context: nil))!;
            if size.height > self.contextTextView.frame.size.height {
                var rect = self.contextTextView.frame
                rect.size.height = size.height
                self.contextTextView.frame = rect
            }
            self.contextTextView.text = _textstr
        }
        get{
            return _textstr
        }
    }
            override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}
