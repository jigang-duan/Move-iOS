//
//  FamilyMembersController.swift
//  Move App
//
//  Created by jiang.duan on 2017/5/2.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CustomViews

private let reuseIdentifier = "cellFamilyMember"

class FamilyMembersController: UICollectionViewController {
    
    struct DataSource {
        let name: String?
        let headImage: URL?
        let identity: Relation?
    }
    
    var members: [DataSource] = []
    
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = R.string.localizable.id_family_chat()
        
        // Do any additional setup after loading the view.
        let family = RxStore.shared.deviceIdObservable
            .flatMapLatest { (id) in DeviceManager.shared.getContacts(deviceId: id).catchErrorJustReturn([]) }
            .map(transform)
        let kids = RxStore.shared.currentDevice.map(transform)
        
        Observable.combineLatest(kids, family) { [$0] + $1 }
            .bindNext { [weak self] in
                self?.members = $0
                self?.collectionView?.reloadData()
            }
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return members.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        guard let cell = _cell as? FamilyMemberCell else { return _cell }
        let member = members[indexPath.row]
        
        cell.textLabel.text = member.name
        
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: cell.imageView.frame.width, height: cell.imageView.frame.height),
                                         fullName: member.name ?? "").imageRepresentation()!
        cell.imageView.kf.setImage(with: member.headImage, placeholder: member.identity?.image ?? placeImg)
    
        return cell
    }

}

fileprivate func transform(kids: DeviceInfo) -> FamilyMembersController.DataSource {
    return FamilyMembersController.DataSource(name: kids.user?.nickname, headImage: URL(string: kids.user?.profile?.fsImageUrl ?? ""), identity: nil)
}

fileprivate func transform(contact: ImContact) -> FamilyMembersController.DataSource {
    return FamilyMembersController.DataSource(name: contact.identity?.description,
                                              headImage: URL(string: contact.profile?.fsImageUrl ?? ""),
                                              identity: contact.identity)
}

fileprivate func transform(contacts: [ImContact]) -> [FamilyMembersController.DataSource] {
     return contacts.map(transform)
}
