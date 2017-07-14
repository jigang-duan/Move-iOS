//
//  AddressbookUtility.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/15.
//  Copyright © 2017年 TCL Com. All rights reserved.
//


import UIKit
import AddressBookUI
import ContactsUI



class AddressbookUtility: NSObject, ABPeoplePickerNavigationControllerDelegate, CNContactPickerDelegate {
    
    private var target: UIViewController?
    private var phoneCallback: (([String]) -> Void)?
    
    
    
    func phoneCallback(with target: UIViewController, callback: @escaping (([String]) -> Void)) {
        self.target = target
        self.phoneCallback = callback
        
        if addressBookPermissions() {
            if #available(iOS 9.0, *) {
                let picker = CNContactPickerViewController()
                picker.delegate = self
                self.target?.present(picker, animated: true, completion: nil)
            }else{
                let pickController = ABPeoplePickerNavigationController()
                pickController.peoplePickerDelegate = self
                self.target?.present(pickController, animated: true, completion: nil)
            }
        }else{
            let vc = UIAlertController(title: nil, message: R.string.infoPlist.nSContactsUsageDescription(), preferredStyle: UIAlertControllerStyle.alert)
            let action1 = UIAlertAction(title: R.string.localizable.id_action_settings(), style: .default) { action in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }
            let action2 = UIAlertAction(title: R.string.localizable.id_ok(), style: .default)
            vc.addAction(action1)
            vc.addAction(action2)
            self.target?.present(vc, animated: true)
        }
    }
    
    
    private func addressBookPermissions() -> Bool {
        if #available(iOS 9.0, *) {
            let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
            if status == .denied || status == .restricted {
                return false
            }
        } else {
            let status = ABAddressBookGetAuthorizationStatus()
            if status == .denied || status == .restricted {
                return false
            }
        }
        return true
    }
    
    
    internal func peoplePickerNavigationController(_ peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
        
        let phones = ABRecordCopyValue(person, kABPersonPhoneProperty) as ABMultiValue
        var phs: [String] = []
        if ABMultiValueGetCount(phones) > 0 {
            for i in 0...ABMultiValueGetCount(phones) {
                let phoneNO = ABMultiValueCopyLabelAtIndex(phones, i).takeRetainedValue() as String
                phs.append(phoneNO)
            }
        }
        if self.phoneCallback != nil {
            self.phoneCallback!(phs)
        }
        self.target?.dismiss(animated: true, completion: nil)
        
    }
    
    @available(iOS 9.0, *)
    internal func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        let phones = contact.phoneNumbers
        var phs: [String] = []
        if phones.count > 0 {
            for ph in phones {
                let p = ph.value.stringValue
                phs.append(p)
            }
        }
        if self.phoneCallback != nil {
            self.phoneCallback!(phs)
        }
        self.target?.dismiss(animated: true, completion: nil)
    }
    
}
