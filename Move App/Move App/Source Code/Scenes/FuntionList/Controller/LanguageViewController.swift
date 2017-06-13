//
//  LanguageViewController.swift
//  Move App
//
//  Created by xiaohui on 17/3/1.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxOptional

class LanguageViewController: UIViewController {
    
    @IBOutlet weak var languageforwatchTitleItem: UINavigationItem!
    @IBOutlet weak var tableview: UITableView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableview.contentInset = UIEdgeInsets(top: -32, left: 0, bottom: 0, right: 0)
        
        let selected = tableview.rx.itemSelected.asDriver()
            .map({ [weak self] in
                self?.tableview.cellForRow(at: $0)?.textLabel?.text })
            .filterNil()
        
        let viewModel = LanguageViewModel(
            input: (
                selectedlanguage: selected,
                empty: Void()
            ),
            dependency: (
                settingsManager: WatchSettingsManager.share,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        selected.drive(viewModel.languageVariable).addDisposableTo(disposeBag)
        viewModel.saveFinish.drive(onNext: {
           [weak self] in
            self?.back($0)
        }).addDisposableTo(disposeBag)
        
        viewModel.lauguage.drive(viewModel.languageVariable).addDisposableTo(disposeBag)
        
        let cellData = Driver.combineLatest(viewModel.lauguages, viewModel.languageVariable.asDriver()) { data, current in data.map({ ($0, current) }) }
        
        cellData.drive(tableview.rx.items(cellIdentifier: R.reuseIdentifier.cellLanguage.identifier)) { index, model, cell in
            cell.textLabel?.text = model.0
            cell.accessoryType = (model.0 != model.1) ? .none : .checkmark
            cell.selectionStyle = .none
        }.addDisposableTo(disposeBag)
        
    }
    
    func back(_ $: Bool) {
        if $ {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }

}
