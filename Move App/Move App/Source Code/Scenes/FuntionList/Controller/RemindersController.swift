//
//  RemindersController.swift
//  Move App
//
//  Created by jiang.duan on 2017/2/27.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CustomViews
import FSCalendar

class RemindersController: UIViewController {
    //internationalization
    @IBOutlet weak var reminderTitleItem: UINavigationItem!
    
    
    
    @IBOutlet weak var addOutlet: UIButton!
    @IBOutlet weak var tableViw: UITableView!
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var timeSelectBtn: UIButton!
    @IBOutlet weak var timeBackBtn: UIButton!
    @IBOutlet weak var timeNextBtn: UIButton!
    @IBOutlet weak var queshengView: UIView!
    
    var isCalendarOpen : Bool = false
    
    var alarms: [NSDictionary]?
    var oldalarms: [NSDictionary]?
    var todos: [NSDictionary]?
    var oldtodos: [NSDictionary]?
    var btnbool: Bool = true

    
    fileprivate let formatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var disposeBag = DisposeBag()
    var viewModel: RemindersViewModel! = nil
    
    var deleteTap = Variable(0)
    var updateTap = Variable(0)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTap.value += 1
    }
    func internationalization() {
        reminderTitleItem.title = R.string.localizable.reminder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.internationalization()
        self.addFuntion()
        self.initView()
        self.loadData()
        timeSelectBtn.rx.tap.asDriver().drive(onNext: calenderIsOpen).addDisposableTo(disposeBag)
        timeBackBtn.rx.tap.asDriver().drive(onNext: lastDayClick).addDisposableTo(disposeBag)
        timeNextBtn.rx.tap.asDriver().drive(onNext: nextDayClick).addDisposableTo(disposeBag)
        tableViw.register(R.nib.remindersCell(), forCellReuseIdentifier: R.reuseIdentifier.reminderCell.identifier)

        
    }
    func loadData() {
        viewModel = RemindersViewModel(
            input: (
                update: updateTap.asDriver().filter({ $0 > 0 }).map({ _ in Void() }) ,
                delect: deleteTap.asDriver().filter({ $0 > 0 }).debug().map({ _ in Void() }) ,
                empty: Void()
            ),
            dependency: (
                kidSettingsManager: KidSettingsManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.fetchReminder
            .drive(viewModel.reminderVariable).addDisposableTo(disposeBag)
        
        let zoneDate = Date(timeIntervalSince1970: 0)
        
        viewModel.reminderVariable.asDriver()
            .map({ $0.alarms  })
            .drive(onNext: {
                
                self.alarms =  $0.map({  [ "alarms": $0.alarmAt ?? zoneDate , "dayFromWeek": $0.day ,"active": $0.active ?? true]})
                self.tableViw.reloadData()
            } )
            .addDisposableTo(disposeBag)

        
        viewModel.reminderVariable.asDriver()
            .map({  $0.todo })
            .drive(onNext: {
                self.todos =  $0.map({   ["start": $0.start ?? zoneDate, "end": $0.end ?? zoneDate, "content": $0.content ?? "", "topic": $0.topic ?? "" ,"repeat": $0.repeatCount ?? 0 ]   })
                self.tableViw.reloadData()
            })
            .addDisposableTo(disposeBag)
        
    }
    
    func initView() {
        self.tableViw.delegate = self
        self.tableViw.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0)
        calendar.select(calendar.today)
        
        timeSelectBtn.setTitle("Today", for: .normal)
    }
    
    func calenderIsOpen() {
        
        if isCalendarOpen == false {
            calendar.isHidden = false
            isCalendarOpen = true
        }else{
            calendar.isHidden = true
            isCalendarOpen = false
        }
    }
    
    func lastDayClick() {
        let curday = calendar.selectedDate
        let perivday = calendar.date(bySubstractingDays: 1, from: curday!)
        calendar.select(perivday)
        let time = self.calenderConversion(from: calendar.today!, to: perivday)
        self.changeBtnType(time: time, date: perivday)
    }
    
    func nextDayClick() {
        let curday = calendar.selectedDate
        let nextday = calendar.date(byAddingDays: 1, to: curday!)
        calendar.select(nextday)
        let time = self.calenderConversion(from: calendar.today!, to: nextday)
        self.changeBtnType(time: time, date: nextday)
    }
    
    func changeBtnType(time : Int , date : Date){
        if time == 1 {
            timeSelectBtn.setTitle("Tomorrow", for: .normal)
        }else if time == -1 {
            timeSelectBtn.setTitle("Yesterday", for: .normal)
        }else if time == 0{
            timeSelectBtn.setTitle("Today", for: .normal)
        }else{
            let string = self.formatter.string(from: date)
            timeSelectBtn.setTitle(string, for: .normal)
        }
    }

    func calenderConversion(from : Date , to : Date) -> Int {
        let gregorian = Calendar(identifier: Calendar.Identifier.chinese)
        let result = gregorian.dateComponents([Calendar.Component.day], from: from, to: to)
        return result.day!
    }
    
    func addFuntion() {
        // Do any additional setup after loading the view.
        let popover = RxPopover.shared
        popover.style = .dark
        let action1 = BasePopoverAction(placeholderImage: R.image.member_ic_qr(),
                                        title: R.string.localizable.alarm(),
                                        isSelected: false)
        
        let action2 = BasePopoverAction(placeholderImage: R.image.member_ic_input(),
                                        title: R.string.localizable.todolist(),
                                        isSelected: false)
        addOutlet.rx.tap.asObservable()
            .flatMapLatest {
                popover.promptFor(toView: self.addOutlet, actions: [action1, action2])
            }
            .bindNext(showSubController)
            .addDisposableTo(disposeBag)
    }

}
extension RemindersController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.alarms?.count ?? 0) + (self.todos?.count ?? 0)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        let _cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.reminderCell.identifier, for: indexPath) as! RemindersCell

        if indexPath.row < (self.alarms?.count)! {
            _cell.model = self.alarms?[indexPath.row]
//            _cell.titleLabel.text =  DateUtility.dateTostringHHmm(date: (self.alarms?[indexPath.row]["alarms"] as! Date))
//            _cell.detailtitleLabel?.text = timeToType(weeks: self.alarms?[indexPath.row]["dayFromWeek"] as! [Bool])
//            _cell.titleimage?.image = UIImage.init(named: "reminder_school")
//            _cell.accviewBtn.isHidden = false
//            _cell.accviewBtn.isOn = self.alarms?[indexPath.row]["active"] as! Bool
        }
        else {
            _cell.titleLabel?.text = self.todos?[indexPath.row-(self.alarms?.count)!]["topic"] as? String
            _cell.detailtitleLabel?.text = "\(DateUtility.dateTostringyyMMdd(date: (self.todos?[indexPath.row-(self.alarms?.count)!]["start"] as! Date)))\("--")\(DateUtility.dateTostringMMdd(date: (self.todos?[indexPath.row-(self.alarms?.count)!]["end"] as! Date)))"
            _cell.titleimage?.image = UIImage.init(named: "reminder_homework")
            _cell.accviewBtn.isHidden = true
        }
        
        return _cell
    }
    //编辑
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < (self.alarms?.count ?? 0) {
            //
            self.oldalarms = self.alarms
            viewModel.reminderVariable.value.alarms.remove(at: indexPath.row)
            if let vc = R.storyboard.account.addAlarm() {
                vc.alarms = self.oldalarms?[indexPath.row]
                self.navigationController?.show(vc, sender: nil)
            }
        
        }
        else
        {
            self.oldtodos = self.todos
            viewModel.reminderVariable.value.todo.remove(at: indexPath.row - (self.alarms?.count ?? 0))
            if let vc = R.storyboard.account.addTodo() {
                vc.todo = self.oldtodos?[indexPath.row - (self.alarms?.count ?? 0)]
                vc.todos = (self.todos ?? nil)!
                self.navigationController?.show(vc, sender: nil)
            }
        }
        
        deleteTap.value += 1
    
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    //删除数据源数据
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if indexPath.row < (self.alarms?.count ?? 0) {

                    let alertController = UIAlertController(title: "This is a repeating alram.", message: "", preferredStyle: .actionSheet)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    let deletThis = UIAlertAction(title: "Delete This alarm only", style: .destructive, handler: { (UIAlertAction) in
                        self.viewModel.reminderVariable.value.alarms.remove(at: indexPath.row)
                        self.deleteTap.value += 1
                    })
                    let deletall = UIAlertAction(title: "Delete All Future alarms", style: .destructive, handler: { (UIAlertAction) in
                        var index = self.viewModel.reminderVariable.value.alarms.count
                        while index > 0{
                            self.viewModel.reminderVariable.value.alarms.remove(at: 0)
                            index = index - 1
                            self.deleteTap.value += 1
                        }
                    })
                    alertController.addAction(cancelAction)
                    alertController.addAction(deletThis)
                    alertController.addAction(deletall)
                    self.present(alertController, animated: true, completion: nil)
            }
            else
            {
                if self.todos?[indexPath.row-(self.alarms?.count)!]["repeat"] as? Int != 0{
                    let alertController = UIAlertController(title: "This is a repeating to do list", message: "", preferredStyle: .actionSheet)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    let deletThis = UIAlertAction(title: "Delete This To do List only", style: .destructive, handler: { (UIAlertAction) in
                        self.viewModel.reminderVariable.value.todo.remove(at: indexPath.row - (self.alarms?.count ?? 0))
                        self.deleteTap.value += 1
                    })
                    let deletall = UIAlertAction(title: "Delete All Future To do list", style: .destructive, handler: { (UIAlertAction) in
                        var index = self.viewModel.reminderVariable.value.todo.count
                        while index > 0{
                        self.viewModel.reminderVariable.value.todo.remove(at: 0)
                            index = index - 1
                            self.deleteTap.value += 1
                        }
                    })
                    alertController.addAction(cancelAction)
                    alertController.addAction(deletThis)
                    alertController.addAction(deletall)
                    self.present(alertController, animated: true, completion: nil)
                }else
                {
                    viewModel.reminderVariable.value.todo.remove(at: indexPath.row - (self.alarms?.count ?? 0))
                    deleteTap.value += 1
                }
                
            }
           
            
            
            
        }
    }
}
extension RemindersController {

    func showSubController(action: BasePopoverAction) {
        if action.title == R.string.localizable.alarm() {
            if (self.alarms?.count)! <= 9{
                self.performSegue(withIdentifier: R.segue.remindersController.showAlarm, sender: nil)
            }
            else
            {
                let alertController = UIAlertController(title: R.string.localizable.warming(), message: "You have add 10 alarm,please delete some to add new.", preferredStyle: .alert)
                let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okActiojn)
                self.present(alertController, animated: true)
            }
            
        } else if action.title == R.string.localizable.todolist() {
            
            if (self.todos?.count)! <= 9{
                
                if let vc = R.storyboard.account.addTodo() {
                    vc.todos = (self.todos ?? nil)!
                    self.navigationController?.show(vc, sender: nil)
                }
            }
            else
            {
                let alertController = UIAlertController(title: R.string.localizable.warming(), message: "You have add 10 to do list,please delete some to add new.", preferredStyle: .alert)
                let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okActiojn)
                self.present(alertController, animated: true)
            }

            
        }
    }
}
extension RemindersController: FSCalendarDelegate,FSCalendarDelegateAppearance {
   
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        let time = self.calenderConversion(from: calendar.today!, to: date)
        self .changeBtnType(time: time , date : date)
    }
    
}

