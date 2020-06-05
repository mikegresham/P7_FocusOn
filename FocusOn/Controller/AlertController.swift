//
//  AlertController.swift
//  FocusOn
//
//  Created by Michael Gresham on 06/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit

class AlertContoller {
    init() {
        
    }
    func tasksCompletedAlertContoller(_ sender: TodayViewController, section: Int) -> UIAlertController {
        let alertController = UIAlertController.init(title: "Congratulations!", message: "Look's like you've completed all your tasks for this goal, did you want to mark this goal as completed?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes Please", style: .default, handler: { action in
            sender.goals[section].completion = true
            sender.tableView.reloadData()
            sender.goalCompleted(goalId: sender.goals[section].id)
        })
        let noAction = UIAlertAction(title: "Not Yet", style: .destructive)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        return alertController
    }
    func repeatGoalAlertContoller(_ sender: TodayViewController, _ goalCount: Int) -> UIAlertController {
        let plural =  goalCount > 1 ? "goals" : "goal"
        let alertController = UIAlertController.init(title: "Welcome Back!", message: "Look's like you didn't finish yesterday's \(plural), did you want to continue with yesterday's \(plural), or start a new goal?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Continue \(plural)", style: .default, handler: { action in
            sender.repeatGoals()
        })
        let noAction = UIAlertAction(title: "New goal", style: .default, handler: { action in
            sender.newGoal()
        })
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        return alertController
    }
    func futureAlertContoller(_ sender: ProgressViewController) -> UIAlertController {
        let alertController = UIAlertController.init(title: "Wait a minute Doc!", message: "We haven't mastered time travel yet", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        return alertController
    }
    func pastAlertContoller(_ sender: ProgressViewController) -> UIAlertController {
        let alertController = UIAlertController.init(title: "Error 404!", message: "No previous dates found", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        return alertController
    }
    
    func settingAlertContoller(_ sender: HistoryViewController) -> UIAlertController {
        let alertController = UIAlertController.init(title: "Demo Settings", message: "Choose from options", preferredStyle: .actionSheet)
        let deleteAllAction = UIAlertAction(title: "Delete All Data", style: .destructive, handler: { action in
            sender.dataManager.deleteAll()
            sender.viewWillAppear(true)
        })
        let createAction = UIAlertAction(title: "Create Dummy Data", style: .default, handler: { action in
            sender.dataManager.createDummyData(days: 100)
            sender.viewWillAppear(true)
        })
        let deleteTodayAction = UIAlertAction(title: "Prepare Repeat Yesterday", style: .default, handler: { action in
            let goals = sender.dataManager.fetchGoalHistory(from: Date.init(), to: Date.init())! as [Goal]
            for i in 0 ..< goals.count{
                sender.dataManager.deleteGoal(for: goals[i].id)
            }
            sender.dataManager.createDummyData(days: 2)
        })
        alertController.addAction(deleteTodayAction)
        //alertController.addAction(deleteYesterdayAction)
        alertController.addAction(deleteAllAction)
        alertController.addAction(createAction)
        return alertController
    }
 
}
