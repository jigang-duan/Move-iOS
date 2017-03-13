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

    
    
    @IBOutlet weak var addOutlet: UIButton!
    @IBOutlet weak var tableViw: UITableView!
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var timeSelectBtn: UIButton!
    @IBOutlet weak var timeBackBtn: UIButton!
    @IBOutlet weak var timeNextBtn: UIButton!
    
    var isCalendarOpen : Bool = false
    
    var alarms: [NSDictionary]?
    var todos: [NSDictionary]?
    var btnbool : Bool = true
    
    fileprivate let formatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addFuntion()
        self.initView()

        timeSelectBtn.rx.tap.asDriver().drive(onNext: calenderIsOpen).addDisposableTo(disposeBag)
        timeBackBtn.rx.tap.asDriver().drive(onNext: lastDayClick).addDisposableTo(disposeBag)
        timeNextBtn.rx.tap.asDriver().drive(onNext: nextDayClick).addDisposableTo(disposeBag)
        
        let viewModel = RemindersViewModel(
            input: (
                deldect: Driver.empty(),
                empty: Void()
            ),
            dependency: (
                kidSettingsManager: KidSettingsManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        viewModel.fetchTodos.drive(viewModel.todosVariable).addDisposableTo(disposeBag)
        viewModel.fetchAlarms.drive(viewModel.alarmsVariable).addDisposableTo(disposeBag)
        
        let zoneDate = Date(timeIntervalSince1970: 0)
        
        
        
        
        
        viewModel.alarmsVariable
            .asDriver().drive(onNext: {
                self.alarms =  $0.map({  [ "alarms": $0.alarmAt ?? zoneDate , "dayFromWeek": $0.day]})
            } )
            .addDisposableTo(disposeBag)
        viewModel.todosVariable
            .asDriver().drive(onNext: {
                self.todos =  $0.map({   ["start": $0.start ?? zoneDate, "end": $0.end ?? zoneDate, "content": $0.content ?? "", "topic": $0.topic ?? "" ]   })
            })
            .addDisposableTo(disposeBag)
        
//        let path = (Bundle.main.path(forResource: "reminder.plist", ofType: nil)) ?? ""
//        
//        let data: NSDictionary? = NSDictionary(contentsOfFile: path)
//        
//        alarms = data?.object(forKey: "Alarms") as! [NSDictionary]?
//        todos = data?.object(forKey: "ToDo") as! [NSDictionary]?
//        
       
        tableViw.register(UINib.init(nibName: "RemindersCell", bundle: nil), forCellReuseIdentifier: R.reuseIdentifier.reminderCell.identifier)
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
        let perivday = calendar.date(bySubstractingDays: 1, from: curday)
        calendar.select(perivday)
        let time = self.calenderConversion(from: calendar.today!, to: perivday)
        self.changeBtnType(time: time, date: perivday)
    }
    
    func nextDayClick() {
        let curday = calendar.selectedDate
        let nextday = calendar.date(byAddingDays: 1, to: curday)
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
                                        title: "Alarm",
                                        isSelected: false)
        let action2 = BasePopoverAction(placeholderImage: R.image.member_ic_input(),
                                        title: "To do list",
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
        return ((self.alarms?.count)!+(self.todos?.count)!)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//         let _cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.reminderCell.identifier) as! RemindersCell
        let _cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.reminderCell.identifier, for: indexPath) as! RemindersCell
//        var _cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.reminderCell.identifier) as! RemindersCell
        
        if indexPath.row < (self.alarms?.count)! {
            _cell.titleLabel.text =  DateUtility.dateTostringHHmm(date: (self.alarms?[indexPath.row]["alarms"] as! Date))
            _cell.detailtitleLabel?.text = "School day"
            _cell.titleimage?.image = UIImage.init(named: "reminder_school")
            _cell.accviewBtn.isOn = false
        }
        else {
            _cell.titleLabel?.text = self.todos?[indexPath.row-(self.alarms?.count)!]["topic"] as? String
            
            _cell.detailtitleLabel?.text = "\(DateUtility.dateTostringyyMMdd(date: (self.todos?[indexPath.row-(self.alarms?.count)!]["start"] as! Date)))\("---")\(DateUtility.dateTostringyyMMdd(date: (self.todos?[indexPath.row-(self.alarms?.count)!]["end"] as! Date)))"
            _cell.titleimage?.image = UIImage.init(named: "reminder_homework")
            _cell.accviewBtn.isHidden = true
        }
        
        return _cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    //删除数据源数据
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if indexPath.row < (self.alarms?.count)! {
                self.alarms?.remove(at: indexPath.row)
            }
            else
            {
               self.todos?.remove(at: indexPath.row-(self.alarms?.count)!)
            }
            self.tableViw.deleteRows(at: [indexPath], with: .top)
            tableView.reloadData()
        }
    }
}
extension RemindersController {

    func showSubController(action: BasePopoverAction) {
        if action.title == "Alarm" {
            self.performSegue(withIdentifier: R.segue.remindersController.showAlarm, sender: nil)
        } else if action.title == "To do list" {
            self.performSegue(withIdentifier: R.segue.remindersController.showTodolist, sender: nil)
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

