//
//  SystemNotificationController.swift
//  Move App
//
//  Created by jiang.duan on 2017/3/15.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift
import RxRealm
import RxDataSources
import RxRealmDataSources
import Kingfisher
import CustomViews
//import AFImageHelper
import DZNEmptyDataSet


class SystemNotificationController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.emptyDataSetSource = self
        
        let realm = try! Realm()
        if let uid = Me.shared.user.id {
            let objects = realm.objects(SynckeyEntity.self).filter("uid == %@", uid).first!.groups
            
            Observable.collection(from: objects)
                .map({ (list) -> [GroupEntity] in
                    list.filter{ $0.notices.count > 0 }.sorted(by: { ($0.notices.last?.createDate)! > ($1.notices.last?.createDate)! })
                })
                .bindTo(tableView.rx.items(cellIdentifier: R.reuseIdentifier.cellNotificationClassify.identifier)) { [weak self] (row, element, cell) in
                    self?.cellConfig(cell: cell, row: row, group: element)
                }
                .addDisposableTo(bag)
            
            tableView.rx.modelSelected(GroupEntity.self)
                .bindNext { [weak self] in
                    self?.performSegue(withIdentifier: R.segue.systemNotificationController.showNotification.identifier, sender: $0)
                }
                .addDisposableTo(bag)
            
        }
        
    }
    
    
    private func cellConfig(cell: UITableViewCell, row: Int, group: GroupEntity) {
        
        if
            let kidsId = group.notices.first?.from,
            let kids = group.members.filter({ $0.id == kidsId }).first {
            
            var headURL: URL? = nil
            if let imageStr = kids.headPortrait {
                headURL = URL(string: FSManager.imageUrl(with: imageStr))
            }
            
            var placeholder = R.image.relationship_ic_other()!
            if let name = kids.nickname {
                placeholder = CDFInitialsAvatar(rect: CGRect(origin: CGPoint.zero, size: placeholder.size) , fullName: name).imageRepresentation() ?? placeholder
                placeholder = convert(image: placeholder, size: placeholder.size)
            }
            cell.imageView?.kf.setImage(with: headURL,
                                        placeholder: placeholder,
                                        options: [.transition(.fade(1))],
                                        progressBlock: nil,
                                        completionHandler: { [weak self] (image, _, _, _) in
                                            guard let image = image else {
                                                return
                                            }
                                            cell.imageView?.image = self?.convert(image: image, size: placeholder.size)
            })
            
            cell.textLabel?.text = kids.nickname
            cell.detailTextLabel?.text = group.notices.last?.content
        }
        
        if let numberLable = cell.accessoryView as? UILabel {
            let number = group.notices.filter({ $0.readStatus == 0 }).filter{ $0.imType.atNotiicationPage }.count
            numberLable.text = number > 99 ? "99+" : "\(number)"
            if let n = numberLable.text?.characters.count, n > 1 {
                numberLable.sizeToFit()
            }
            numberLable.isHidden = number < 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func convert(image: UIImage, size: CGSize) -> UIImage {
        return image.scale(toSize: size)?.roundCornersToCircle() ?? image
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let rsegue = R.segue.systemNotificationController.showNotification(segue: segue) {
            if let group = sender as? GroupEntity {
                rsegue.destination.group = group
            }
        }
    }
    
}

extension SystemNotificationController: DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return R.image.system_notification_empty()!
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No notification here"
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 18.0),
                          NSForegroundColorAttributeName: UIColor.lightGray]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return R.color.appColor.background()
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
