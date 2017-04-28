//
//  HomeController.swift
//  Move App
//
//  Created by jiang.duan on 2017/4/24.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift
import CustomViews

class HomeController: UIViewController {
    
    @IBOutlet weak var noticeOutlet: UIView!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let realm = try! Realm()
        RxStore.shared.uidObservable
            .flatMapLatest { (uid) -> Observable<Bool> in
                let notices = realm.objects(NoticeEntity.self).filter("to == %@", uid)
                return Observable.collection(from: notices).map({ $0.filter("readStatus == 0").count > 0 })
            }
            .bindTo(noticeOutlet.rx.isBadgeHidden)
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
