//
//  HistoryViewController.swift
//  FocusOn
//
//  Created by Michael Gresham on 03/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class HistoryViewController: UITableViewController, HistoryGoalTableViewCellDelegate, HistoryTaskTableViewCellDelegate {
    let dataController = DataController()
    var sections = [Any]()
    var months = 1
    var monthIndex = [Int]()
    var stats: [(index: Int, completed: Int, total: Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setData()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView?.backgroundColor = UIColor.init(red: 0/255, green: 166/255, blue: 118/255, alpha: 1)
        tableView.separatorInset.left = 0
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    @IBAction func settings(_ sender: Any) {
        //present(AlertContoller.init().settingAlertContoller(self), animated: true)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if monthIndex.contains(section) {
            return 2
        } else {
            return dataController.fetchTasks(for: (sections[section] as! Goal).id)!.count + 2
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            if monthIndex.contains(indexPath.section) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "HistorySummaryTableViewCellID", for: indexPath) as! HistorySummaryTableViewCell
                cell.setSummaryLabel(title: getSummaryString(for: indexPath.section))
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryGoalTableViewCellID", for: indexPath) as! HistoryGoalTableViewCell
                cell.setCellData(goal: (sections[indexPath.section] as! Goal))
                return cell
            }
        case 1 :
            if monthIndex.contains(indexPath.section) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SpacingCellID", for: indexPath)
                    cell.layer.borderColor = UIColor.darkGray.cgColor
                    cell.layer.borderWidth = 0.4
                    return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTaskTableViewCellID", for: indexPath) as! HistoryTaskTableViewCell
                //cell.setCellData(task: (sections[indexPath.section] as! Goal).tasks[indexPath.row - 1])
                return cell
            }
        case dataController.fetchTasks(for: (sections[indexPath.section] as! Goal).id)!.count + 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpacingCellID", for: indexPath)
            cell.layer.borderColor = UIColor.darkGray.cgColor
            cell.layer.borderWidth = 0.3
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTaskTableViewCellID", for: indexPath) as! HistoryTaskTableViewCell
            //cell.setCellData(task: (sections[indexPath.section] as! Goal).tasks[indexPath.row - 1])
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if monthIndex.contains(indexPath.section) {
            return indexPath.row == 0 ? tableView.estimatedRowHeight : 10
        } else if indexPath.row == dataController.fetchTasks(for: (sections[indexPath.section] as! Goal).id)!.count + 1 {
            return 10
        }
        return tableView.estimatedRowHeight
    }

    func updateRowHeight() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    /*
    func setData() {
        stats.removeAll()
        monthIndex.removeAll()
        sections.removeAll()
        var totalDays = 0
        var daysCompleted = 0
        var logs: [NSManagedObject]
        var previousMonth = Int()
        logs = dataController.logs(from: nil, to: nil)
        for i in 0 ..< logs.count {
            let title = (logs[i] as! GoalEntity).title!
            let date = (logs[i] as! GoalEntity).date!
            let completion = (logs[i] as! GoalEntity).completion
            let tasks = (logs[i] as! GoalEntity).tasks as! [Task]
            totalDays += 1
            daysCompleted += (logs[i] as! GoalEntity).completion == true ? 1 : 0
            if i == 0 {
                monthIndex.append(0)
                sections.append(dataController.monthCaption(for: date))
            } else if i == logs.count - 1 {
                stats.append((index: monthIndex.last!, completed: daysCompleted, total: totalDays))
            } else if i > 0 {
                if dataController.monthValue(for: date) != previousMonth {
                    stats.append((index: monthIndex.last!, completed: daysCompleted, total: totalDays))
                    monthIndex.append(sections.count)
                    months += 1
                    totalDays = 0
                    daysCompleted = 0
                    sections.append(dataController.monthCaption(for: date))
                }
            }
            
            sections.append(Goal.init(title: title, tasks: tasks, date: date, completion: completion))
            previousMonth = dataController.monthValue(for: date)
        }
        print(months)
        tableView.reloadData()
    }
    */
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 22))
        returnedView.backgroundColor = UIColor.init(red: 0/255, green: 169/255, blue: 114/255, alpha: 1)
        //returnedView.backgroundColor = UIColor.white
        let label = UILabel(frame: CGRect(x: 0, y: 4, width: UIScreen.main.bounds.width, height: 20))
        label.font = UIFont(name: "Avenir-Medium", size: 17)
        //label.textColor = UIColor.init(red: 28/255, green: 35/255, blue: 33/255, alpha: 1)
        label.textColor = UIColor.white
        label.font = monthIndex.contains(section) ? UIFont(name: "Avenir-Black", size: 18) : UIFont(name: "Avenir-Heavy", size: 17)
        label.text = monthIndex.contains(section) ? (sections[section] as! String) : dataController.dateCaption(for: (sections[section] as! Goal).date)
        label.textAlignment = .center
        returnedView.addSubview(label)
        return returnedView
    }

    func getSummaryString(for section: Int) -> String {
        
        let i = stats.firstIndex(where: { $0.index == section})!
        return "\(stats[i].completed) out of \(stats[i].total) goals completed"
        
    }
 
}

