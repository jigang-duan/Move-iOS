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
    
    var members: [ImContact] = []
    
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = R.string.localizable.id_family_chat()
        
        // Do any additional setup after loading the view.
        RxStore.shared.deviceIdObservable
            .flatMapLatest { (id) in DeviceManager.shared.getContacts(deviceId: id).catchErrorJustReturn([]) }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        if let cell = cell as? FamilyMemberCell {
            let member = members[indexPath.row]
            cell.textLabel.text = member.identity?.description
            
            let placeImg = CDFInitialsAvatar(
                rect: CGRect(x: 0, y: 0, width: cell.imageView.frame.width, height: cell.imageView.frame.height),
                fullName: member.identity?.description ?? "")
                .imageRepresentation()!
            
            let imgUrl = URL(string: member.profile?.fsImageUrl ?? "")
            cell.imageView.kf.setImage(with: imgUrl, placeholder: member.identity?.image ?? placeImg)
        }
    
        return cell
    }

}
