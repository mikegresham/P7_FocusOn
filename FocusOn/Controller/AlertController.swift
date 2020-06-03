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
        let alertController = UIAlertController.init(title: "Congratulations!", message: "Look's like you've completed all your tasks for today, did you want to mark your goal as completed?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes Please", style: .default, handler: { action in
            sender.goals[section].completion = true
            sender.tableView.reloadData()
            //sender.goalCompleted()
        })
        let noAction = UIAlertAction(title: "Not Yet", style: .destructive)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        return alertController
    }
    func repeatGoalAlertContoller(_ sender: TodayViewController) -> UIAlertController {
        let alertController = UIAlertController.init(title: "Welcome Back!", message: "Look's like you didn't finish yesterday's goal, did you want to continue with yesterday's goal, or start a new goal?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Continue Goal", style: .default, handler: { action in
            sender.repeatGoals()
        })
        let noAction = UIAlertAction(title: "New Goal", style: .default, handler: { action in
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
    /*
    func settingAlertContoller(_ sender: HistoryViewController) -> UIAlertController {
        let alertController = UIAlertController.init(title: "Settings", message: "Choose from below", preferredStyle: .actionSheet)
        let deleteAllAction = UIAlertAction(title: "Delete All Data", style: .destructive, handler: { action in
            sender.dataController.deleteAll()
        })
        let createAction = UIAlertAction(title: "Create Dummy Data", style: .default, handler: { action in
            sender.dataController.createDummyData(days: 500)
        })
        let deleteTodayAction = UIAlertAction(title: "Delete Today's Entry", style: .default, handler: { action in
            sender.dataController.deleteGoal(for: Date.init())
        })
        let deleteYesterdayAction = UIAlertAction(title: "Delete Yesterdays's Entry", style: .default, handler: { action in
            sender.dataController.deleteGoal(for: Date.init().addingTimeInterval(-24 * 3600))
        })
        alertController.addAction(deleteTodayAction)
        alertController.addAction(deleteYesterdayAction)
        alertController.addAction(deleteAllAction)
        alertController.addAction(createAction)
        return alertController
    }
 */
}
