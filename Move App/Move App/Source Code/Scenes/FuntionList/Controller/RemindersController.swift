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
    @IBOutlet weak var titleSegment: UISegmentedControl!
    
    @IBOutlet weak var addOutlet: UIButton!
    @IBOutlet weak var tableViw: UITableView!
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var timeSelectBtn: UIButton!
    @IBOutlet weak var timeBackBtn: UIButton!
    @IBOutlet weak var timeNextBtn: UIButton!
    
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var tableviewtopConstraint: NSLayoutConstraint!
    var isCalendarOpen : Bool = false
    
    var alarms: [NSDictionary]?
    var todos: [NSDictionary]?
    var oldtodos: [NSDictionary]?
    var fifleremeder: [NSDictionary]? = []

    
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
//        self.changeBtnType(time: 0, date: DateUtility.stringToDateyyMMddd(dateString: timeSelectBtn.titleLabel?.text ?? ""))
//        print(timeSelectBtn.titleLabel?.text)
    }
    
    func internationalization() {
       
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
        
        titleSegment.selectedSegmentIndex = 0
        self.changeShow()
        titleSegment.addTarget(self, action: #selector(RemindersController.changeShow), for: .valueChanged)
        
    }
    
    func changeShow() {
        let imageempty = emptyView.subviews[0] as! UIImageView
        let label = emptyView.subviews[1] as! UILabel
        if titleSegment.selectedSegmentIndex == 0
        {
            dateView.isHidden = true
            tableviewtopConstraint.constant = -60
            calendar.isHidden = true
        
            imageempty.image = R.image.reminder_empty()
            label.text = "No alarm this day,tap \"+\" to add a alarm."
        }else
        {
            self.changeBtnType(time: -1, date: Date.today().startDate)
            dateView.isHidden = false
            tableviewtopConstraint.constant = 0
            calendar.isHidden = true
            imageempty.image = R.image.todolist_empty()
            label.text = "No reminder this day,tap \"+\" to add a to do list."
        }
        self.tableViw.reloadData()
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
//                self.fifleremeder?.removeAll()
//                for i in 0 ..< (self.todos?.count ?? 0)!
//                {
////                    if self.timeSelectBtn.titleLabel?.text == (DateUtility.dateTostringyyMMddd(date: (self.todos?[i]["start"] as! Date))){
////                        self.fifleremeder?.append((self.todos?[i])!)
////                    }
//                    
//                    let tmepValue = self.todos?[i]["repeat"] as!Int
//                    switch tmepValue  {
//                    case 0:
//                        self.fifleremeder?.append((self.todos?[i])!)
//                        break
//                    case 1,2,3:
//                        self.fifleremeder?.append((self.todos?[i])!)
//                        break
//                    default:
//                        break
//                    }
//                }

//                self.tableViw.reloadData()
                
                let date  = DateUtility.stringToDateyyMMddd(dateString: self.timeSelectBtn.titleLabel?.text ?? "")
                self.changeBtnType(time: 0 , date : date)

            })
            .addDisposableTo(disposeBag)
    }
    
    func initView() {
        self.tableViw.delegate = self
        self.tableViw.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0)
        calendar.select(calendar.today)
        timeSelectBtn.setTitle(DateUtility.todayy(), for: .normal)
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
//        if time == 1 {
//            timeSelectBtn.setTitle("Tomorrow", for: .normal)
//        }else if time == -1 {
//            timeSelectBtn.setTitle("Yesterday", for: .normal)
////        }else if time == 0{
////            timeSelectBtn.setTitle("Today", for: .normal)
//        }else{
        
//        self.fifletodos?.removeAll()
//        for i in 0 ..< (self.todos?.count ?? 0)
//        {
////            if self.timeSelectBtn.titleLabel?.text == (DateUtility.dateTostringyyMMddd(date: (self.todos?[i]["start"] as! Date))){
//                self.fifletodos?.append((self.todos?[i])!)
////            }
//        }
            calendar.isHidden = true
            let string = self.formatter.string(from: date)
            timeSelectBtn.setTitle(string, for: .normal)
//        }
        //获取周
//        print(DateUtility.getDateWeekDay(date: date as NSDate))
        //获取日  every month3 ,every week2, every day1 ,never0
//        print(DateUtility.getDay(date: date as NSDate))
        
        self.fifleremeder?.removeAll()
        for i in 0 ..< (self.todos?.count ?? 0)!
        {
            if self.timeSelectBtn.titleLabel?.text != (DateUtility.dateTostringyyMMddd(date: (self.todos?[i]["start"] as! Date))){
            switch self.todos?[i]["repeat"] as! Int {
            case 0:
               print(self.todos?[i]["repeat"] as! Int)
                break
            case 1:
                    self.fifleremeder?.append((self.todos?[i])!)
                break
            case 2:
                //周日判断有毒
                if ((DateUtility.getDateWeekDay(date: date as NSDate)) == (DateUtility.getDateWeekDay(date: (self.todos?[i]["start"] as! NSDate)) - 1)) || ((DateUtility.getDateWeekDay(date: date as NSDate)) - (DateUtility.getDateWeekDay(date: (self.todos?[i]["start"] as! NSDate)) - 1) == 7)
                        {
                            self.fifleremeder?.append((self.todos?[i])!)
                    }
                    
                break
            case 3:
                if DateUtility.getDay(date: date as NSDate) == DateUtility.getDay(date: (self.todos?[i]["start"] as! NSDate))
                {
                    self.fifleremeder?.append((self.todos?[i])!)
                }
                break
            default:
                break
                }
            }
            //加当天
            if self.timeSelectBtn.titleLabel?.text == (DateUtility.dateTostringyyMMddd(date: (self.todos?[i]["start"] as! Date))){
                self.fifleremeder?.append((self.todos?[i])!)
            }
        }
        
            self.tableViw.reloadData()
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
        let action1 = BasePopoverAction(placeholderImage: R.image.reminder_alarm(),
                                        title: R.string.localizable.id_alarm(),
                                        isSelected: false)
        
        let action2 = BasePopoverAction(placeholderImage: R.image.reminder_todolist(),
                                        title: R.string.localizable.id_todolist(),
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

        if titleSegment.selectedSegmentIndex == 0
        {
            if self.alarms?.count == 0 {emptyView.isHidden = false}
            else
            {emptyView.isHidden = true}
            
            return (self.alarms?.count ?? 0)!
        }else
        {
            if self.fifleremeder?.count == 0 {emptyView.isHidden = false}
            else
            {emptyView.isHidden = true}
            return (self.fifleremeder?.count ?? 0)!
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        let _cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.reminderCell.identifier, for: indexPath) as! RemindersCell

        if self.titleSegment.selectedSegmentIndex == 0{
        
            _cell.model = self.alarms?[indexPath.row]

        }
       else 
        {
                _cell.titleLabel?.text = self.fifleremeder?[indexPath.row]["topic"] as? String
                _cell.detailtitleLabel?.text = "\(DateUtility.dateTostringyyMMdd(date: (self.fifleremeder?[indexPath.row]["start"] as! Date)))\("--")\(DateUtility.dateTostringMMdd(date: (self.fifleremeder?[indexPath.row]["end"] as! Date)))"
                _cell.titleimage?.image = UIImage.init(named: "reminder_homework")
                _cell.accviewBtn.isHidden = true

        }
        return _cell
    }
    //编辑
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      if self.titleSegment.selectedSegmentIndex == 0
       {
        
            if let vc = R.storyboard.account.addAlarm() {
                vc.alarms = self.alarms?[indexPath.row]
                self.navigationController?.show(vc, sender: nil)
            }
        
        }
        else
        {
            var fifleretodo = self.fifleremeder
//            for i in 0 ..< (self.fifleremeder?.count)!
//            {
//                if self.fifleremeder?[i] == self.fifleremeder?[indexPath.row]
//                {
//                    fifleretodo?.remove(at: i)
//                }
//            }
            fifleretodo?.remove(at: indexPath.row)
            
            if let vc = R.storyboard.account.addTodo() {
                vc.todo = self.fifleremeder?[indexPath.row]
                vc.todos = (fifleretodo ?? nil)!
                self.navigationController?.show(vc, sender: nil)
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
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
            else
            {
                if (self.fifleremeder?[indexPath.row]["repeat"] as? Int)! != 0
                {
                    let alertController = UIAlertController(title: "This is a repeating to do list", message: "", preferredStyle: preferredStyle)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    let deletThis = UIAlertAction(title: "Delete this To do list only", style: .destructive, handler: { (UIAlertAction) in
                        var inde: Int?
                        for i in 0 ..< (self.todos?.count)!
                        {
                            if self.fifleremeder?[indexPath.row] == self.todos?[i]
                            {
                                inde = i
                            }
                        }

                        self.viewModel.reminderVariable.value.todo.remove(at: inde!)
                        
                        self.deleteTap.value += 1
                    })
                    let deletall = UIAlertAction(title: "Delete All To do list", style: .destructive, handler: { (UIAlertAction) in
//                        var index = self.fifleremeder?.count
//                        while index! > 0{
//                            var inde: Int?
//                            for i in 0 ..< (self.todos?.count)!
//                            {
//                                if self.fifleremeder?[0] == self.todos?[i]
//                                {
//                                    inde = i
//                                }
//                            }
//                            self.viewModel.reminderVariable.value.todo.remove(at: inde!)
//                            
//                            index = index! - 1
//                            self.deleteTap.value += 1
//                        }
                          self.viewModel.reminderVariable.value.todo.removeAll()
                          self.deleteTap.value += 1
                    })
//                    if let popoverController = alertController.popoverPresentationController {
//                        popoverController.sourceView = self.view
//                        popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.size.width*0.5, y: UIScreen.main.bounds.size.height, width: 1, height: 1)
//                    }

                    alertController.addAction(cancelAction)
                    alertController.addAction(deletThis)
                    alertController.addAction(deletall)
                   
                    self.present(alertController, animated: true, completion: nil)
                }else
                {
                    var inde: Int?
                    for i in 0 ..< (self.todos?.count)!
                    {
                        if self.fifleremeder?[indexPath.row] == self.todos?[i]
                        {
                            inde = i
                        }
                    }
                    
                    self.viewModel.reminderVariable.value.todo.remove(at: inde!)
                    deleteTap.value += 1
                    
                }
                
            }
           
        }
    }
}
extension RemindersController {

    func showSubController(action: BasePopoverAction) {
        if action.title == R.string.localizable.id_alarm() {
//            if (self.alarms?.count)! <= 9{
                self.performSegue(withIdentifier: R.segue.remindersController.showAlarm, sender: nil)
//            }
//            else
//            {
//                let alertController = UIAlertController(title: R.string.localizable.id_warming(), message: "You have add 10 alarm,please delete some to add new.", preferredStyle: .alert)
//                let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alertController.addAction(okActiojn)
//                self.present(alertController, animated: true)
//            }
            
        } else if action.title == R.string.localizable.id_todolist() {
            //应该是当前日的todo不能超过10
//            if (self.todos?.count)! <= 9{
            
                if let vc = R.storyboard.account.addTodo() {
                    vc.todos = (self.todos ?? nil)!
                    self.navigationController?.show(vc, sender: nil)
                }
//            }
//            else
//            {
//                let alertController = UIAlertController(title: R.string.localizable.id_warming(), message: "You have add 10 to do list,please delete some to add new.", preferredStyle: .alert)
//                let okActiojn = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alertController.addAction(okActiojn)
//                self.present(alertController, animated: true)
//            }

            
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


