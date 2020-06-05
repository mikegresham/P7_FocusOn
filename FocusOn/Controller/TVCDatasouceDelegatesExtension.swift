//
//  TVCDatasouceDelegatesExtension.swift
//  FocusOn
//
//  Created by Michael Gresham on 03/06/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension TodayViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return goals.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //Custom height for header and footer cells
        let lastRowInSection = tableView.numberOfRows(inSection: indexPath.section) - 1
        if indexPath.row == 0 || indexPath.row == lastRowInSection {
            return 20
        }
        return tableView.estimatedRowHeight
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Account for header, goal, summary, add task, and footer row (+5)
        return (dataManager.fetchTasks(for: goals[section].id)!.count) + 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lastRowInSection = tableView.numberOfRows(inSection: indexPath.section) - 1
        switch indexPath.row {
        case 0:
            //Header Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCellID", for: indexPath)
            return cell
        case 1:
            //Goal Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodayGoalTableViewCellID", for: indexPath) as! TodayGoalTableViewCell
            cell.delegate = self
            cell.setCellData(goal: goals[indexPath.section])
            return cell
        case 2:
            //Summary Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryCellID", for: indexPath) as! TaskSummaryTableViewCell
            let tasks = dataManager.fetchTasks(for: goals[indexPath.section].id) as! [Task]
            let count = tasks.filter{ $0.completion == false }.count
            if tasks.count == 0 {
                cell.summaryLabel.text = "Add some tasks below..."
            } else {
                let plural = count != 1 ? "s" : ""
                cell.summaryLabel.text = "\(count) task\(plural) to achieve your goal"
            }
            return cell
        case lastRowInSection - 1:
            //Add Task Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodayTaskTableViewCellID", for: indexPath) as! TodayTaskTableViewCell
            cell.delegate = self
            cell.setNewCellData(goalId: goals[indexPath.section].id)
            return cell
        case lastRowInSection:
            //Footer Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "FooterCellID", for: indexPath)
            return cell
        default:
            //Task Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodayTaskTableViewCellID", for: indexPath) as! TodayTaskTableViewCell
            cell.delegate = self
            let tasksInSection = dataManager.fetchTasks(for: goals[indexPath.section].id)! as! [Task]
            let taskForRow = tasksInSection[indexPath.row-3]
            cell.setCellData(task: taskForRow, goalId: goals[indexPath.section].id)
            return cell
        }
    }
}

extension TodayViewController : TodayTaskCellDelegate, TodayGoalCellDelegate {
    // MARK: TableViewCell Protocols
     func updateRowHeight() {
        //TableViewController handles row height automatically
         tableView.beginUpdates()
         tableView.endUpdates()
     }

    func taskUpdate(task: Task) {
        //Function to Update Task
        let goalIndex = goals.firstIndex { $0.id == task.goal.id }!
        if task.title != "" {
            //Update Task
            dataManager.updateTask(task: task)
            //If user has unchecked task, then umcomplete goal
            if task.completion == false {
                goals[goalIndex].completion = false
            }
        } else {
            //Delete if task is empty
            dataManager.deleteTask(for: task.id)
        }
        saveAndReload()
        manageLocalNotifications()
     }

     func goalUpdate(cell: TodayGoalTableViewCell) {
        //Function to update goal
        let indexPath = self.tableView.indexPath(for: cell)!
        goals[indexPath.section].title = cell.goalTextView.text
        goals[indexPath.section].completion = cell.goalCompletionButton.isSelected
        saveAndReload()
        manageLocalNotifications()

     }
    
    func taskCompleted(task: Task) {
        //Upon task completion, present animation, if all tasks completed offer to user to complete goal
        let goal = goals.filter{ $0.id == task.goal.id }.first
        let taskAnimation = TaskCompletionAnimation()
        self.navigationController?.view.addSubview(taskAnimation)
        if task.completion == false {
            //upon task completion
            taskAnimation.animateFailPopUp()
        } else {
            //upon unchecking task
            taskAnimation.animateSuccessPopUp()
        }
        //Check if all tasks are completed, if so offer user to complete goal
        let tasks = dataManager.fetchTasks(for: goal!.id) as! [Task]
        let count = tasks.filter{ $0.completion == true }.count
        if count == tasks.count {
            let section = goals.firstIndex { $0.id == goal!.id }
            let alertController = AlertContoller.init().tasksCompletedAlertContoller(self, section: section!)
            present(alertController, animated: true)
        }
        manageLocalNotifications()
    }
    
    func goalCompleted(goalId: UUID) {
        //Display goal animation, and mark all tasks for goal as completed
        let goalAnimation = GoalCompletionAnimation()
        self.navigationController?.view.addSubview(goalAnimation)
        let tasks = dataManager.fetchTasks(for: goalId) as! [Task]
        for i in 0 ..< tasks.count {
            tasks[i].completion = true
            dataManager.updateTask(task: tasks[i])
        }
        saveAndReload()
        goalAnimation.animatePopUp(self)
        manageLocalNotifications()
    }
}
