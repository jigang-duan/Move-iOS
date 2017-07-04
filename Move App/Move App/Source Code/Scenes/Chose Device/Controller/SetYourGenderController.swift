//
//  SetYourGenderController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/16.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class SetYourGenderController: UIViewController {

    
    @IBOutlet weak var setGenderLab: UILabel!
    @IBOutlet weak var saveBun: UIButton!
    
    var genderBlock: ((Gender) -> Void)?
    var selectedGender: Gender?
    
    
    private func initializeI18N() {
        setGenderLab.text = R.string.localizable.id_set_your_gender()
        saveBun.setTitle(R.string.localizable.id_save(), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeI18N()
        
        if selectedGender == .female {
            girlBtn.isSelected = true
        }else{
            boyBtn.isSelected = true
        }
    }
    
    @IBOutlet weak var girlBtn: UIButton!
    @IBOutlet weak var boyBtn: UIButton!
    
    
    @IBAction func BackAction(_ sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func girAction(_ sender: UIButton) {
        sender.isSelected = true
        boyBtn.isSelected = false
    }
    
    @IBAction func boyAction(_ sender: UIButton) {
        sender.isSelected = true
        girlBtn.isSelected = false
    }
    

 
    @IBAction func saveAction(_ sender: UIButton) {
        if self.genderBlock != nil {
            if self.girlBtn.isSelected {
                self.genderBlock!(.female)
            }else{
                self.genderBlock!(.male)
            }
            self.BackAction(nil)
        }
    }
    
}
