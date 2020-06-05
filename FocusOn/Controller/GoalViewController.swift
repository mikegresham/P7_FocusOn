//
//  GoalViewController.swift
//  FocusOn
//
//  Created by Michael Gresham on 03/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GoalViewController: UITableViewController {

    let dataController = DataController()
    var goal = Goal()

    @IBAction func deleteGoalButton(_ sender: Any) {
        dataController.deleteGoal(for: goal.id)
        navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        congfig()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = UIColor.init(red: 0/255, green: 170/255, blue: 115/255, alpha: 1)
        self.title = dataController.dateCaption(for: goal.date)
    }


    func congfig() {
        //Initial Setup
        tableView.delegate = self
        tableView.dataSource = self
        //Custom UI
        tableView.separatorStyle = .none
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
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
            //Account for header, goal, and footer row (+3)
            return (dataController.fetchTasks(for: goal.id))!.count + 3
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
                cell.setCellData(goal: goal)
                return cell
            case lastRowInSection:
                //Footer Cell
                let cell = tableView.dequeueReusableCell(withIdentifier: "FooterCellID", for: indexPath)
                return cell
            default:
                //Task Cell
                let cell = tableView.dequeueReusableCell(withIdentifier: "TodayTaskTableViewCellID", for: indexPath) as! TodayTaskTableViewCell
                let tasksInSection = dataController.fetchTasks(for: goal.id)! as! [Task]
                let taskForRow = tasksInSection[indexPath.row-2]
                cell.setCellData(task: taskForRow, goalId: goal.id)
                return cell
            }
        }
}
