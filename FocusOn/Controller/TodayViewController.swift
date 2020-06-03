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
    var goals: [Goal] = []
    var deletedTask: Task?
    var deletedIndexPath: IndexPath?

    @IBAction func addBarButtonAction(_ sender: Any) {
        newGoal()
        saveAndReload()

        let sections = tableView.numberOfSections - 1
        let row = 0
        let indexPath = IndexPath(row: row, section: sections)
        
        let newGoal = tableView.cellForRow(at: indexPath) as? TodayGoalTableViewCell
        if let newGoal = newGoal {
            newGoal.goalTextView.becomeFirstResponder()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }

    override func viewDidLoad() {
        tableView.separatorStyle = .none
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        registerForKeyboardNotifications()
        navigationItem.leftBarButtonItem = editButtonItem
        checkExistingGoal()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

    }

    func checkExistingGoal() {
        if let existingGoals = dataController.fetchGoalHistory(from: Date.init(), to: nil) {
            if existingGoals.count > 0 {
                self.goals = existingGoals
            } else {
            checkYesterdaysGoal()
            }
        }
    }

    func checkYesterdaysGoal(){
        if let yesterdaysGoals = dataController.fetchGoalHistory(from: dataController.yesterday, to: nil) {
            var yesterdayCompletion = true
            for i in 0 ..< yesterdaysGoals.count {
                if yesterdaysGoals[i].completion == false {
                    yesterdayCompletion = false
                }
            }
            if yesterdayCompletion == false {
                present(AlertContoller.init().repeatGoalAlertContoller(self), animated: true)
            } else {
                newGoal()
                saveAndReload()
                
            }
        }
    }

    func repeatGoals(){
        goals = dataController.fetchGoalHistory(from: dataController.yesterday, to: nil)!
        for i in 0 ..< goals.count {
            goals[i].date = dataController.today
        }
        saveAndReload()
    }
    
    func saveAndReload() {
        dataController.updateGoals(goals: goals)
        tableView.reloadData()
    }

    func newGoal() {
        let id = dataController.createEmptyGoal()
        goals.append(dataController.fetchGoal(for: id) as! Goal)
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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         let lastRowInSection = tableView.numberOfRows(inSection: indexPath.section) - 1
        switch indexPath.row {
        case 0:
            return false
        case lastRowInSection:
            return false
        case lastRowInSection - 1:
            return false
        default:
            return true
        }
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) ->
        UISwipeActionsConfiguration? {
            
            let delete = UIContextualAction(style: .destructive, title: "Delete") {(action, view, completion) in
                self.deleteTask(at: indexPath)
            }
            return UISwipeActionsConfiguration.init(actions: [delete])
       }

    func deleteTask (at indexPath: IndexPath) {
        tableView.beginUpdates()
        if (indexPath.row == 1){
            dataController.deleteGoal(for: goals[indexPath.section].id)
            goals.remove(at: indexPath.section)
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .left)
        } else {
            let tasksInSection = dataController.fetchTasks(for: goals[indexPath.section].id)! as! [Task]
            let taskForRow = tasksInSection[indexPath.row-2]
            dataController.deleteTask(for: taskForRow.id)
            tableView.deleteRows(at: [indexPath], with:.left)

        }
        tableView.endUpdates()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.saveAndReload()
        }

     }
/*
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        // Undo
        if let task = deletedTask, let indexPath = deletedIndexPath {
            self.deletedTask = nil
            self.deletedIndexPath = nil
            self.goals[].insertTask(task: task, at: indexPath.row)
            saveAndReload()
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
 */

// MARK: TableView Delegate & DataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return goals.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let lastRowInSection = tableView.numberOfRows(inSection: indexPath.section) - 1
        if indexPath.row == 0 || indexPath.row == lastRowInSection {
            return 20
        }
        return tableView.estimatedRowHeight
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataController.fetchTasks(for: goals[section].id)!.count) + 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lastRowInSection = tableView.numberOfRows(inSection: indexPath.section) - 1
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodayGoalTableViewCellID", for: indexPath) as! TodayGoalTableViewCell
            cell.delegate = self
            cell.setCellData(goal: goals[indexPath.section])
            return cell
        
        case lastRowInSection - 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodayTaskTableViewCellID", for: indexPath) as! TodayTaskTableViewCell
            cell.delegate = self
            cell.setNewCellData(goalId: goals[indexPath.section].id)
            return cell
        case lastRowInSection:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FooterCell", for: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodayTaskTableViewCellID", for: indexPath) as! TodayTaskTableViewCell
            cell.delegate = self
            let tasksInSection = dataController.fetchTasks(for: goals[indexPath.section].id)! as! [Task]
            let taskForRow = tasksInSection[indexPath.row-2]
            cell.setCellData(task: taskForRow, goalId: goals[indexPath.section].id)
            return cell

        }
    }

    /*
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            let count = goals[section].tasks.filter{ $0.completion == false }.count
            let plural = count != 1 ? "s" : ""
            return "\(count) task\(plural) to achieve your goal"
        default:
             return nil
         }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1 ? true : false
    }
    */
}

extension TodayViewController : TodayTaskCellDelegate, TodayGoalCellDelegate {
    // MARK: TableViewCell Protocols
     func updateRowHeight() {
         tableView.beginUpdates()
         tableView.endUpdates()
     }

    func taskUpdate(cell: TodayTaskTableViewCell) {
        let indexPath = tableView.indexPath(for: cell)
        let lastRowInSection = tableView.numberOfRows(inSection: indexPath!.section) - 2
        let task = cell.task!

        if task.title != "" {
            dataController.updateTask(task: task)
            if task.completion == false {
                //mark goal as uncomplete
            }
            if indexPath!.row == lastRowInSection {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let newIndexPath = IndexPath(row: indexPath!.row + 1, section: indexPath!.section)
                    self.tableView.insertRows(at: [newIndexPath], with: .automatic)
                    self.tableView.reloadRows(at: [newIndexPath], with: .automatic)
                }
            }
        } else {
            dataController.deleteTask(for: task.id)
        }
     }

     func goalUpdate(cell: TodayGoalTableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)!
        goals[indexPath.section].title = cell.goalTextView.text
        goals[indexPath.section].completion = cell.goalCompletionButton.isSelected
        saveAndReload()
     }
    func taskCompleted(completion:Bool, cell: TodayTaskTableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)!
        let popUp = PopUp()
        self.navigationController?.view.addSubview(popUp)
        if completion == false {
            popUp.animateFailPopUp()
        } else {
            popUp.animateSuccessPopUp()
        }
        let tasks = dataController.fetchTasks(for: goals[indexPath.section].id) as! [Task]
        let count = tasks.filter{ $0.completion == true }.count
        print(count)
        print(tasks.count)
        if count == tasks.count {
            let alertController = AlertContoller.init().tasksCompletedAlertContoller(self, section: indexPath.section)
            present(alertController, animated: true)
        }
    }
    func goalCompleted(cell: TodayGoalTableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        let goalPopUp = GoalCompletionPopUp()
        self.navigationController?.view.addSubview(goalPopUp)
        let tasks = dataController.fetchTasks(for: goals[indexPath!.section].id) as! [Task]
        for i in 0 ..< tasks.count {
            tasks[i].completion = true
            dataController.updateTask(task: tasks[i])
        }
        saveAndReload()
        goalPopUp.animatePopUp(self)
        
    }

}
