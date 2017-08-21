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

    @IBOutlet weak var titleSegment: UISegmentedControl!
    
    @IBOutlet weak var addOutlet: UIButton!
    @IBOutlet weak var tableViw: UITableView!
    
    @IBOutlet weak var timeBtnhelpBtn: UIButton!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var timeSelectBtn: UIButton!
    @IBOutlet weak var timeBackBtn: UIButton!
    @IBOutlet weak var timeNextBtn: UIButton!
    
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var tableviewtopConstraint: NSLayoutConstraint!
    var isCalendarOpen : Bool = false
    
    var alarms: [KidSetting.Reminder.Alarm] = []
    var allTodos: [KidSetting.Reminder.ToDo] = []
    var filterTodos: [KidSetting.Reminder.ToDo] = []
    
    var disposeBag = DisposeBag()
    var viewModel: RemindersViewModel! = nil
    
    var deleteTap = Variable(0)
    var updateTap = Variable(0)
    
    
    var selectedAlarm: KidSetting.Reminder.Alarm?
    var selectedTodo: KidSetting.Reminder.ToDo?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTap.value += 1
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.placeholderType = .none
        calendar.appearance.caseOptions = .weekdayUsesSingleUpperCase
        
        initView()
        
        viewModel = RemindersViewModel(
            input: (
                update: updateTap.asDriver().filter({ $0 > 0 }).map({_ in
                    Void()
                }) ,
                delete: deleteTap.asDriver ().filter({ $0 > 0 }).map({_ in
                    Void()
                }) ,
                empty: Void()
            ),
            dependency: (
                kidSettingsManager: KidSettingsManager.shared,
                validation: DefaultValidation.shared,
                wireframe: DefaultWireframe.sharedInstance
            )
        )
        
        viewModel.fetchReminder
            .drive(viewModel.reminderVariable)
            .addDisposableTo(disposeBag)
        
        viewModel.reminderVariable.asDriver()
            .drive(onNext: {[weak self] in
                self?.alarms =  $0.alarms
                self?.allTodos =  $0.todo
                
                let date  = DateUtility.stringToDateyyMMddd(dateString: self?.timeSelectBtn.titleLabel?.text ?? "")
                let time = self?.calenderConversion(from: (self?.calendar.today)!, to: date)
                self?.changeBtnType(time: time! , date : date)
                
                self?.tableViw.reloadData()
            } )
            .addDisposableTo(disposeBag)
        
        timeBtnhelpBtn.rx.tap.asDriver().drive(onNext: {[weak self] in
            self?.calenderIsOpen()
        }).addDisposableTo(disposeBag)
        
        timeSelectBtn.rx.tap.asDriver().drive(onNext: {[weak self] in
            self?.calenderIsOpen()
        }).addDisposableTo(disposeBag)
        
        timeBackBtn.rx.tap.asDriver().drive(onNext: {[weak self] in
            self?.lastDayClick()
        }).addDisposableTo(disposeBag)
        
        timeNextBtn.rx.tap.asDriver().drive(onNext: {[weak self] in
            self?.nextDayClick()
        }).addDisposableTo(disposeBag)
        
        tableViw.register(R.nib.remindersCell(), forCellReuseIdentifier: R.reuseIdentifier.reminderCell.identifier)
        
        titleSegment.setTitle(R.string.localizable.id_title_Alarm(), forSegmentAt: 0)
        titleSegment.setTitle(R.string.localizable.id_todolist(), forSegmentAt: 1)
        
        titleSegment.selectedSegmentIndex = 0
        
        changeShow()
        
        timeSelectBtn.setTitle(DateUtility.dateTostringyyMMddd(date: calendar.today), for: .normal)
        titleSegment.addTarget(self, action: #selector(RemindersController.changeShow), for: .valueChanged)
        
        
    }
    

    @IBAction func showController() {
        if titleSegment.selectedSegmentIndex == 0{
            selectedAlarm = nil
            self.showAlarm()
        } else if titleSegment.selectedSegmentIndex == 1 {
            selectedTodo = nil
            self.showTodo()
        }
    }
    
    fileprivate func showAlarm() {
        self.performSegue(withIdentifier: R.segue.remindersController.showAlarm, sender: nil)
    }
    
    fileprivate func showTodo() {
        self.performSegue(withIdentifier: R.segue.remindersController.showTodolist, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.remindersController.showAlarm(segue: segue)?.destination {
            if let al = selectedAlarm {
                vc.alarm = al
            }else{ 
                vc.isForAdd = true
            }
        }
        
        if let vc = R.segue.remindersController.showTodolist(segue: segue)?.destination {
            if let td = selectedTodo {
                vc.todo = td
            }else{
                vc.isForAdd = true
            }
        }
    }
    
    
    
    fileprivate func initView() {
        titleSegment.layer.cornerRadius = 6
        titleSegment.clipsToBounds = true
        titleSegment.borderWidth = 1
        titleSegment.borderColor = UIColor.white
        
        self.tableViw.delegate = self
        self.tableViw.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
        calendar.select(calendar.today)
        timeSelectBtn.setTitle(DateUtility.todayy(), for: .normal)
    }
    
}

//tablview代理方法
extension RemindersController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if titleSegment.selectedSegmentIndex == 0
        {
            if self.alarms.count == 0 {
                emptyView.isHidden = false
            }else{
                emptyView.isHidden = true
            }
            return self.alarms.count
        }else{
            if self.filterTodos.count == 0 {
                emptyView.isHidden = false
            }else{
                emptyView.isHidden = true
            }
            return self.filterTodos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.reminderCell.identifier, for: indexPath) as! RemindersCell
        
        if self.titleSegment.selectedSegmentIndex == 0{
            _cell.model = self.alarms[indexPath.row]
        }else{
            _cell.titleLabel?.text = self.filterTodos[indexPath.row].topic
            _cell.detailtitleLabel?.text = DateUtility.dateTostringyyMMdd(date: (self.filterTodos[indexPath.row].start)) + "--" + DateUtility.dateTostringMMdd(date: (self.filterTodos[indexPath.row].end))
            _cell.accviewBtn.isHidden = true
        }
        return _cell
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.titleSegment.selectedSegmentIndex == 0{
            selectedAlarm = self.alarms[indexPath.row]
            self.showAlarm()
        }else{
            selectedTodo = self.filterTodos[indexPath.row]
            self.showTodo()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return R.string.localizable.id_str_remove_alarm_title()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    //删除数据源数据
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //判断设备
        let preferredStyle: UIAlertControllerStyle = UIDevice.current.userInterfaceIdiom == .phone ? .actionSheet : .alert
        
        if editingStyle == .delete {
            if self.titleSegment.selectedSegmentIndex == 0{
                self.viewModel.reminderVariable.value.alarms.remove(at: indexPath.row)
                self.deleteTap.value += 1
            }
            else{
                if self.filterTodos[indexPath.row].repeatCount != 0 {
                    let alertController = UIAlertController(title: R.string.localizable.id_title_repeats_to(), message: nil, preferredStyle: preferredStyle)
                    
                    let cancelAction = UIAlertAction(title: R.string.localizable.id_cancel(), style: .cancel)
                    let deleteThis = UIAlertAction(title: R.string.localizable.id_delect_todolist(), style: .destructive, handler: {[weak self] _ in
                        self?.viewModel.reminderVariable.value.todo.remove(at: indexPath.row)
                        self?.deleteTap.value += 1
                    })
                    let deleteAll = UIAlertAction(title: R.string.localizable.id_delect_all_todolist(), style: .destructive, handler: {[weak self] _ in
                        self?.viewModel.reminderVariable.value.todo.removeAll()
                        self?.deleteTap.value += 1
                    })
                    
                    alertController.addAction(cancelAction)
                    alertController.addAction(deleteThis)
                    alertController.addAction(deleteAll)
                    
                    self.present(alertController, animated: true)
                    
                }else{
                    self.viewModel.reminderVariable.value.todo.remove(at: indexPath.row)
                    deleteTap.value += 1
                }
                
            }
            
        }
    }
    
}
//缺省页面
extension RemindersController {
    @objc fileprivate func changeShow() {
        let imageempty = emptyView.subviews[0] as! UIImageView
        let label = emptyView.subviews[1] as! UILabel
        if titleSegment.selectedSegmentIndex == 0
        {
            dateView.isHidden = true
            tableviewtopConstraint.constant = -60
            calendar.isHidden = true
            
            imageempty.image = R.image.reminder_empty()
            label.text = R.string.localizable.id_no_reminder_alarms()
        }else
        {
            self.changeBtnType(time: 0, date: Date.today().startDate)
            dateView.isHidden = false
            tableviewtopConstraint.constant = 0
            calendar.isHidden = true
            imageempty.image = R.image.todolist_empty()
            label.text = R.string.localizable.id_no_reminder_todolist()
        }
        
        self.tableViw.reloadData()
    }
    
}

//日历按钮事件
extension RemindersController {
    fileprivate func calenderIsOpen() {
        
        if isCalendarOpen == false {
            calendar.isHidden = false
            isCalendarOpen = true
        }else{
            calendar.isHidden = true
            isCalendarOpen = false
        }
    }
    
    fileprivate func lastDayClick() {
        let curday = calendar.selectedDate
        let perivday = calendar.date(bySubstractingDays: 1, from: curday!)
        calendar.select(perivday)
        let time = self.calenderConversion(from: calendar.today!, to: perivday)
        self.changeBtnType(time: time, date: perivday)
    }
    
    fileprivate func nextDayClick() {
        let curday = calendar.selectedDate
        let nextday = calendar.date(byAddingDays: 1, to: curday!)
        calendar.select(nextday)
        let time = self.calenderConversion(from: calendar.today!, to: nextday)
        self.changeBtnType(time: time, date: nextday)
    }
    
    fileprivate func changeBtnType(time : Int , date : Date){
        if time == 1 {
            timeBtnhelpBtn.setTitle(R.string.localizable.id_tomorrow(), for: .normal)
        }else if time == -1 {
            timeBtnhelpBtn.setTitle(R.string.localizable.id_yesterday(), for: .normal)
        }else if time == 0{
            timeBtnhelpBtn.setTitle(R.string.localizable.id_today(), for: .normal)
        }else{
            timeBtnhelpBtn.setTitle(date.stringDefaultYearMonthDay, for: .normal)
        }
       
        calendar.isHidden = true
        timeSelectBtn.setTitle(DateUtility.dateTostringyyMMddd(date: date), for: .normal)
        
        filterTodos.removeAll()
        for td in self.allTodos {
            let rp = RepeatCount(rawValue: td.repeatCount ?? 0)!
            switch rp {
            case .never:
                if let start = td.start {
                    if DateUtility.dateTostringyyMMddd(date: date) == DateUtility.dateTostringyyMMddd(date: start){
                        filterTodos.append(td)
                    }
                }
            case .day:
                filterTodos.append(td)
            case .week:
                if let start = td.start {
                    if DateUtility.getWeekDay(date: date) == DateUtility.getWeekDay(date: start){
                        filterTodos.append(td)
                    }
                }
            case .month:
                if let start = td.start {
                    if DateUtility.getDay(date: date) == DateUtility.getDay(date: start){
                        filterTodos.append(td)
                    }
                }
            }
        }
        self.tableViw.reloadData()
    }
    
    fileprivate func calenderConversion(from : Date , to : Date) -> Int {
        let result = Calendar.current.dateComponents([.day], from: from, to: to)
        return result.day!
    }
    
}

//日历控件代理方法
extension RemindersController: FSCalendarDelegate,FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let time = self.calenderConversion(from: calendar.today!, to: date)
        self.changeBtnType(time: time , date : date)
    }
    
}


