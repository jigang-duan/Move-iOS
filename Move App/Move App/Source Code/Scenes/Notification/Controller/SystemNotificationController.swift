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


class SystemNotificationController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let dataSource = RxTableViewRealmDataSource<GruopEntity>(cellIdentifier: R.reuseIdentifier.cellNotificationClassify.identifier,
                                                                 cellType: UITableViewCell.self,
                                                                 cellConfig: cellConfig)
        let realm = try! Realm()
        
//        let groups = Observable<GruopEntity>.changeset(from: realm.objects(GruopEntity.self).filter({ $0.uid == Me.shared.user.id }))
//            .share()
    }
    
    
    private func cellConfig(cell: UITableViewCell, ip: IndexPath, group: GruopEntity) {
        let headURL = URL(string: group.headPortrait ?? "")
        var placeholder = R.image.relationship_ic_other()!
        if let name = group.name {
            placeholder = CDFInitialsAvatar(rect: CGRect(origin: CGPoint.zero, size: placeholder.size) , fullName: name).imageRepresentation() ?? placeholder
        }
        cell.imageView?.kf.setImage(with: headURL,
                                    placeholder: placeholder,
                                    options: [.transition(.fade(1))],
                                    progressBlock: nil,
                                    completionHandler: nil)
        cell.textLabel?.text = group.name
        cell.detailTextLabel?.text = group.notices.last?.content
        if let badge = cell.accessoryView as? UILabel {
            badge.text = "\(group.notices.count)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
