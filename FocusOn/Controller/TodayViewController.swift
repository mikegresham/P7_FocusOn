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
        tableView.reloadData()
    }

    func congfig() {
        //Initial Setup
        tableView.delegate = self
        tableView.dataSource = self
        registerForKeyboardNotifications()
        checkExistingGoal()
        
        //Custom UI
        tableView.separatorStyle = .none
    }

    func checkExistingGoal() {
        //Function to see if there are already Goals for today
        if let existingGoals = dataController.fetchGoalHistory(from: Date.init(), to: nil) {
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
        if let yesterdaysGoals = dataController.fetchGoalHistory(from: dataController.yesterday, to: nil) {
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
        goals = dataController.fetchGoalHistory(from: dataController.yesterday, to: nil)! as [Goal]
        goals.removeAll(where: { $0.completion == true })
        for i in 0 ..< goals.count {
            goals[i].date = dataController.startOfDay(for: Date.init())
        }
        saveAndReload()
    }
    
    func saveAndReload() {
        //Function to save changes to goals, and reload table data.
        dataController.updateGoals(goals: goals)
        tableView.reloadData()
    }

    func newGoal() {
        let id = dataController.createEmptyGoal()
        goals.append(dataController.fetchGoal(for: id) as! Goal)
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
            dataController.deleteGoal(for: goals[indexPath.section].id)
            goals.remove(at: indexPath.section)
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .left)
        } else {
            //If task deleted
            let tasksInSection = dataController.fetchTasks(for: goals[indexPath.section].id)! as! [Task]
            //Account for, header, goal, and summary cells from indexpath.row (-3)
            let taskForRow = tasksInSection[indexPath.row - 3]
            dataController.deleteTask(for: taskForRow.id)
            tableView.deleteRows(at: [indexPath], with:.left)
        }
        tableView.endUpdates()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.saveAndReload()
        }
     }
}
