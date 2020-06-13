//
//  TodayViewController.swift
//  FocusOn
//
//  Created by Michael Gresham on 03/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import CoreData

class TodayViewController: UITableViewController {

    let dataManager = DataManager()
    let timeManager = TimeManager()
    var goals: [Goal] = []

    @IBAction func addBarButtonAction(_ sender: Any) {
        //Add New Goal
        newGoal()
        saveAndReload()
        //Scroll to Goal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let newGoalIndexPath = IndexPath(row: 0, section: self.tableView.numberOfSections - 1)
            self.tableView.scrollToRow(at: newGoalIndexPath, at: .top, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        congfig()
    }

    override func viewWillAppear(_ animated: Bool) {
        goals.removeAll()
        goals = dataManager.fetchGoalHistory(from: timeManager.today, to: nil)! as [Goal]
        tableView.reloadData()
    }

    func congfig() {
        //Initial Setup
        tableView.delegate = self
        tableView.dataSource = self
        registerForKeyboardNotifications()
        checkExistingGoal()
        manageLocalNotifications()
        
        //Custom UI
        tableView.separatorStyle = .none
    }

    func checkExistingGoal() {
        //Function to see if there are already Goals for today
        if let existingGoals = dataManager.fetchGoalHistory(from: Date.init(), to: nil) {
            if existingGoals.count > 0 {
                self.goals = existingGoals
            } else {
            //If there are no goals, check yesterday.
                checkYesterdaysGoal()
            }
        }
    }

    func checkYesterdaysGoal(){
        //Function to check if there are any unfinished goals from yesterday, and offer to user to complete
        if let yesterdaysGoals = dataManager.fetchGoalHistory(from: timeManager.yesterday, to: nil) {
            var yesterdayCompletion = true
            for i in 0 ..< yesterdaysGoals.count {
                if yesterdaysGoals[i].completion == false { yesterdayCompletion = false }
            }
            if yesterdayCompletion == false {
                //If any goals remained umcompleted, offer to user to repeat them today.
                present(AlertContoller.init().repeatGoalAlertContoller(self, yesterdaysGoals.count), animated: true)
            } else {
                //If not, create new goal
                newGoal()
                saveAndReload()
            }
        }
    }

    func repeatGoals(){
        //Function to fetch umcompleted goals to repeat
        goals = dataManager.fetchGoalHistory(from: timeManager.yesterday, to: nil)! as [Goal]
        goals.removeAll(where: { $0.completion == true })
        for i in 0 ..< goals.count {
            goals[i].date = timeManager.startOfDay(for: Date.init())
        }
        saveAndReload()
    }
    
    func saveAndReload() {
        //Function to save changes to goals, and reload table data.
        dataManager.updateGoals(goals: goals)
        tableView.reloadData()
    }

    func newGoal() {
        let id = dataManager.createEmptyGoal()
        goals.append(dataManager.fetchGoal(for: id) as! Goal)
        saveAndReload()
    }


    //MARK: Keyboard Handling
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification){
        let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        adjustLayoutForKeyboard(targetHeight: keyboardFrame.size.height)
    }

    @objc func keyboardWillHide(notification: NSNotification){
        adjustLayoutForKeyboard(targetHeight: 0)
    }

    func adjustLayoutForKeyboard(targetHeight: CGFloat){
        tableView.contentInset.bottom = targetHeight
    }
    
    //MARK: Notifications
    
    func manageLocalNotifications() {
        // prepare content
        let totalGoals = goals.count
        let completedGoals = goals.filter{ $0.completion == true}.count
        
        var title: String?
        var body: String?

        if totalGoals == 0 { // no goals
            title = "It's lonely here"
            body = "Add Some Goals!"
        }
        else if completedGoals == 0 { // nothing completed
            title = "Get started!"
            let plural = totalGoals == 1 ? "goal" : "goals"
            body = "You've got \(totalGoals) \(plural) to go!"
        }
        else if completedGoals < totalGoals { // completedTasks less totalTasks
            title = "Progress in action!"
            let plural = (totalGoals - completedGoals) == 1 ? "goal" : "goals"
            body = "\(completedGoals) down \(totalGoals - completedGoals) \(plural) to go!"
        }
        
        // schedule (or remove) reminders
        scheduleLocalNotification(title: title, body: body)
        scheduleMorningNotification()
    }
    
    func scheduleLocalNotification(title: String?, body: String?) {
       let identifier = "FocusOnGoalSummary"
       let notificationCenter = UNUserNotificationCenter.current()
       
       // remove previously scheduled notifications
       notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
       
       if let newTitle = title, let newBody = body {
           // create content
           let content = UNMutableNotificationContent()
           content.title = newTitle
           content.body = newBody
           content.sound = UNNotificationSound.default
           
           // create trigger
           let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
           
           // create request
           let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
           
           // schedule notification
           notificationCenter.add(request, withCompletionHandler:nil)
       }
    }
    
    func scheduleMorningNotification() {
        //Morning reminder to set some goals
        let identifier = "FocusOnMorningReminder"
        let notificationCenter = UNUserNotificationCenter.current()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        // remove previously scheduled notifications
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
       

        // create content
        let content = UNMutableNotificationContent()
        content.title = "Let's Get Started"
        content.body = "Set Some Goals For Today!"
        content.sound = UNNotificationSound.default
           
        // create trigger for 8am
        let date = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date.init().addingTimeInterval(86400))
        let comps = calendar.dateComponents([.day, .hour, .minute, .second], from: date!)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
           
        // create request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
           
        // schedule notification
        notificationCenter.add(request, withCompletionHandler:nil)

    }

    //MARK: Cell Swipe Actions
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //Prevent user from deleting add task, header, footer and summary rows from tableView
        let lastRowInSection = tableView.numberOfRows(inSection: indexPath.section) - 1
        switch indexPath.row {
        case 0, 2, lastRowInSection, lastRowInSection - 1:
            return false
        default:
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) ->
        UISwipeActionsConfiguration? {
            //Delete action to delete task or goal
            let delete = UIContextualAction(style: .destructive, title: "Delete") {(action, view, completion) in
                self.deleteTask(at: indexPath)
            }
            return UISwipeActionsConfiguration.init(actions: [delete])
       }

    func deleteTask (at indexPath: IndexPath) {
        tableView.beginUpdates()
        if (indexPath.row == 1){
            //If goal deleted
            dataManager.deleteGoal(for: goals[indexPath.section].id)
            goals.remove(at: indexPath.section)
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .left)
        } else {
            //If task deleted
            let tasksInSection = dataManager.fetchTasks(for: goals[indexPath.section].id)! as! [Task]
            //Account for, header, goal, and summary cells from indexpath.row (-3)
            let taskForRow = tasksInSection[indexPath.row - 3]
            dataManager.deleteTask(for: taskForRow.id)
            tableView.deleteRows(at: [indexPath], with:.left)
        }
        tableView.endUpdates()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.saveAndReload()
        }
        manageLocalNotifications()
     }
}
