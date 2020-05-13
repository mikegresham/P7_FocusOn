//
//  TodayViewController.swift
//  FocusOn
//
//  Created by Michael Gresham on 03/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreData

class TodayViewController: UITableViewController {

    let dataController = DataController()
    var goal = Goal.init()
    var deletedTask: Task?
    var deletedIndexPath: IndexPath?

    @IBAction func addBarButtonAction(_ sender: Any) {
        let indexPath = IndexPath(row: goal.tasks.count, section: 1)
        goal.apendTask(task: Task.init())
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        dataController.log(goal: goal)
        let cell = tableView.cellForRow(at: indexPath) as! TodayTaskTableViewCell
        cell.taskTextView.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        registerForKeyboardNotifications()
        navigationItem.leftBarButtonItem = editButtonItem
        checkExistingGoal()
    }

    func checkExistingGoal() {
        if let existingGoal = dataController.fetchGoal(date: Date.init()) {
            self.goal = existingGoal
        } else {
            checkYesterdaysGoal()
        }
    }

    func checkYesterdaysGoal(){
        if let yesterdaysGoal = dataController.fetchGoal(date: dataController.yesterday) {
            if yesterdaysGoal.completion == false {
                present(AlertContoller.init().repeatGoalAlertContoller(self), animated: true)
            }
        }
    }

    func repeatGoal(){
        goal = dataController.fetchGoal(date: dataController.yesterday)!
        goal.date = dataController.today
        saveAndReload()
        dataController.deleteGoal(for: dataController.yesterday)
    }
    
    func saveAndReload() {
        dataController.log(goal: goal)
        tableView.reloadData()
    }

    func newGoal() {
        saveAndReload()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(editing, animated: true)
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

    //MARK: Cell Swipe Actions
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           let delete = UIContextualAction(style: .destructive, title: "Delete") {(action, view, completion) in
               self.deleteTask(at: indexPath)
           }
           return UISwipeActionsConfiguration.init(actions: [delete])
       }

    func deleteTask (at indexPath: IndexPath) {
        tableView.beginUpdates()
        if (indexPath.section == 1){
             deletedTask = goal.tasks[indexPath.row]
             deletedIndexPath = indexPath
             goal.removeTask(at: indexPath)
             dataController.log(goal: goal)
         }
        tableView.deleteRows(at: [indexPath], with:.left)
        tableView.endUpdates()
        saveAndReload()
     }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        // Undo
        if let task = deletedTask, let indexPath = deletedIndexPath {
            self.deletedTask = nil
            self.deletedIndexPath = nil
            self.goal.insertTask(task: task, at: indexPath.row)
            saveAndReload()
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }

// MARK: TableView Delegate & DataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return goal.tasks.count
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodayGoalTableViewCellID", for: indexPath) as! TodayGoalTableViewCell
            cell.delegate = self
            cell.setCellData(goal: goal)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodayTaskTableViewCellID", for: indexPath) as! TodayTaskTableViewCell
            cell.delegate = self
            cell.setCellData(task: goal.tasks[indexPath.row], row: indexPath.row)
            return cell
        default:
            return UITableViewCell.init()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            let count = goal.tasks.filter{ $0.completion == false }.count
            let plural = count != 1 ? "s" : ""
            return "\(count) task\(plural) to achieve your goal"
        default:
             return nil
         }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1 ? true : false
    }
}

extension TodayViewController : TodayTaskCellDelegate, TodayGoalCellDelegate {
    // MARK: TableViewCell Protocols
     func updateRowHeight() {
         tableView.beginUpdates()
         tableView.endUpdates()
     }

     func taskUpdate(cell: TodayTaskTableViewCell) {
        let task = Task(title: cell.taskTextView.text, completion: cell.taskCompletionButton.isSelected)
        let indexPath = self.tableView.indexPath(for: cell)!
        if task.title != "" {
            goal.insertTask(task: task, at: indexPath.row)
            if task.completion == false {
                goal.completion = false
            }
        } else {
            goal.removeTask(at: indexPath)
        }
        saveAndReload()
     }

     func goalUpdate(cell: TodayGoalTableViewCell) {
        goal.title = cell.goalTextView.text
        goal.completion = cell.goalCompletionButton.isSelected
        saveAndReload()
     }
    func taskCompleted(completion:Bool) {
        let popUp = PopUp()
        self.navigationController?.view.addSubview(popUp)
        if completion == false {
            popUp.animateFailPopUp()
        } else {
            popUp.animateSuccessPopUp()
        }
        let count = goal.tasks.filter{ $0.completion == true }.count
        if count == goal.tasks.count {
            let alertController = AlertContoller.init().tasksCompletedAlertContoller(self)
            present(alertController, animated: true)
        }
    }
    func goalCompleted() {
        let goalPopUp = GoalCompletionPopUp()
        self.navigationController?.view.addSubview(goalPopUp)
        for i in 0 ..< goal.tasks.count {
            goal.tasks[i].completion = true
        }
        saveAndReload()
        goalPopUp.animatePopUp(self)
    }
}
