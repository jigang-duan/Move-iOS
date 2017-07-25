//
//  MainMap+Controller.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift
import MessageUI
import CustomViews

class MainMapController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet var noGeolocationView: UIView!
    @IBOutlet weak var openPreferencesBtn: UIButton!
    
    @IBOutlet weak var callOutlet: UIButton!
    @IBOutlet weak var messageOutlet: UIButton!
    @IBOutlet weak var guideOutlet: UIButton!
    
    @IBOutlet weak var nameOutle: UILabel!
    @IBOutlet weak var addressScrollLabel: ScrollLabelView!
    
    @IBOutlet weak var timeOutlet: UILabel!
    @IBOutlet weak var headPortraitOutlet: UIButton!
    
    @IBOutlet weak var statesOutlet: UIImageView!
    @IBOutlet weak var voltameterOutlet: UILabel!
    @IBOutlet weak var voltameterImageOutlet: UIImageView!

    @IBOutlet weak var remindLocationOutlet: UIButton!
    
    @IBOutlet weak var remindActivityOutlet: ActivityImageView!
    
    @IBOutlet weak var noticeOutlet: UIBarButtonItem!
    
    @IBOutlet weak var trackingModeOutlet: UIView!
    @IBOutlet weak var trackingTitleOutlet: UILabel!
    @IBOutlet weak var trackingModeHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var offTrackingModeOutlet: UIButton!
    
    @IBOutlet weak var offlineModeOutlet: UIView!
    @IBOutlet weak var offlineTitleOutlet: UILabel!
    @IBOutlet weak var offlineModeHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var tapAddressOutlet: UITapGestureRecognizer!
    @IBOutlet weak var floatMenuTopConstraint: NSLayoutConstraint!
    
    let enterSubject = PublishSubject<Void>()
    
    var isAtThisPage = Variable(false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initBaseAbility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.isAtThisPage.value = true
        enterSubject.onNext(())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showFeatureGudieView()
        self.addressScrollLabel.scrollLabelIfNeed()
        
        propelToTargetController()
        
        offlineModeHeightConstraint.constant = offlineTitleOutlet.bounds.height + 14.0
        trackingModeHeightConstraint.constant = trackingTitleOutlet.bounds.height + 14.0
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isAtThisPage.value = false
    }
    
    
    override func initUIs() {
        timeOutlet.adjustsFontSizeToFitWidth = true
        
        self.addressScrollLabel.addObaserverNotification()
        addressScrollLabel.textFont = UIFont.systemFont(ofSize: 15.0)
        addressScrollLabel.textColor = R.color.appColor.secondayText()
        
        self.navigationItem.title = R.string.localizable.id_top_menu_location()
        self.navigationController?.tabBarItem.title = R.string.localizable.id_button_menu_home()
        callOutlet.setTitle(R.string.localizable.id_location_call(), for: .normal)
        messageOutlet.setTitle(R.string.localizable.id_location_message(), for: .normal)
        
        trackingTitleOutlet.text = NSLocalizedString("Daily tracking mode will consume more power, tap to close.", comment: "")
        
        noGeolocationView.frame = view.bounds
        view.addSubview(noGeolocationView)
    }
    
        
    override func initActions() {
        let wireframe = DefaultWireframe.sharedInstance
        
        mapView.rx.willStartLoadingMap.asDriver()
            .drive(onNext: { Logger.debug("地图开始加载!") })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didFinishLoadingMap.asDriver()
            .drive(onNext: { Logger.debug("地图结束加载!") })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didAddAnnotationViews.asDriver()
            .drive(onNext: { Logger.debug("地图Annotion个数: \($0.count)")})
            .addDisposableTo(disposeBag)
        
        openPreferencesBtn.rx.tap.bindNext { _ in wireframe.openSettings() }.addDisposableTo(disposeBag)
        
        messageOutlet.rx.tap.asObservable().bindTo(rx.segueChat).addDisposableTo(disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

