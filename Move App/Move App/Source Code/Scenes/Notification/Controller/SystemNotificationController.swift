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


class SystemNotificationController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let dataSource = RxTableViewRealmDataSource<GroupEntity>(cellIdentifier: R.reuseIdentifier.cellNotificationClassify.identifier,
                                                                 cellType: UITableViewCell.self,
                                                                 cellConfig: cellConfig)
        let realm = try! Realm()
        if let uid = Me.shared.user.id {
            let objects = realm.objects(SynckeyEntity.self).filter("uid == %@", uid).first!.groups
            let groups = Observable.changeset(from: objects )
                .share()
        
            groups
                .bindTo(tableView.rx.realmChanges(dataSource))
                .addDisposableTo(bag)
            
            tableView.rx.itemSelected
                .asDriver()
                .drive(onNext: { [weak self] ip in
                    self?.performSegue(withIdentifier: R.segue.systemNotificationController.showNotification.identifier, sender: objects[ip.row])
                })
                .addDisposableTo(bag)
            
        }
        
    }
    
    
    private func cellConfig(cell: UITableViewCell, ip: IndexPath, group: GroupEntity) {
        
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
                                        completionHandler: nil)
            cell.imageView?.cornerRadius = 22.0
            
            cell.textLabel?.text = kids.nickname
            cell.detailTextLabel?.text = String(format: group.notices.last?.content ?? "", kids.nickname ?? "")
        }
        
        (cell.accessoryView as? UILabel)?.text = "\(group.notices.count)"
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
        if let rSegue = R.segue.systemNotificationController.showNotification(segue: segue) {
            if let group = sender as? GroupEntity {
                rSegue.destination.group = group
            }
        }
        
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
