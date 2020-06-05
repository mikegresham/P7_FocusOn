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

class HistoryViewController: UITableViewController {
    let dataManager = DataManager()
    let timeManager = TimeManager()
    var sections = [Any]()
    var months = 1
    var monthIndex = [Int]()
    var dateIndex = [Date]()
    var stats: [(index: Int, completed: Int, total: Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //Reload data
        setData()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        //Sections store months, and days logged
        return sections.count > 0 ? sections.count : 1
    }
    @IBAction func settings(_ sender: Any) {
        //Demo data
        present(AlertContoller.init().settingAlertContoller(self), animated: true)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if monthIndex.contains(section) {
            //Summary label for Month
            return 1
        } else if sections.count == 0{
            return 1
        } else {
            // All goals for date
            let date = sections[section] as! Date
            return dataManager.fetchGoalHistory(from: date, to: date)!.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            if sections.count == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataCellID", for: indexPath)
                return cell
            } else if monthIndex.contains(indexPath.section) {
                //Summary label for Month
                let cell = tableView.dequeueReusableCell(withIdentifier: "HistorySummaryTableViewCellID", for: indexPath) as! HistorySummaryTableViewCell
                cell.setSummaryLabel(title: getSummaryString(for: indexPath.section))
                return cell
            } else {
                // Goal for row
                let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryGoalTableViewCellID", for: indexPath) as! HistoryGoalTableViewCell
                let date = sections[indexPath.section] as! Date
                let goals = dataManager.fetchGoalHistory(from: date, to: date)! as [Goal]
                cell.setCellData(goal: goals[indexPath.row])
                return cell
            }
        default:
            // Goal for row
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryGoalTableViewCellID", for: indexPath) as! HistoryGoalTableViewCell
            let date = sections[indexPath.section] as! Date
            let goals = dataManager.fetchGoalHistory(from: date, to: date)! as [Goal]
            cell.setCellData(goal: goals[indexPath.row])
            return cell
        }
    }
    
    func setData() {
        //Function to set data, for all goals stored in CoreData
        stats.removeAll()
        monthIndex.removeAll()
        sections.removeAll()
        
        var totalGoals = 0
        var goalsCompleted = 0
        var previousMonth = Int()
        var date: Date?
        //Fetch all goals
        let goals = dataManager.fetchGoalHistory(from: nil, to: nil)! as [Goal]
        
        for i in stride(from: goals.count - 1, to: -1, by: -1) {
            //Algorithm to calculate goals completed in each month, and store month headings and dates with goals logged for table sections.
            if i == goals.count - 1 {
                //First Goal
                monthIndex.append(0)
                sections.append(timeManager.monthCaption(for: goals[i].date))
            } else if i < goals.count {
                //If Goal month is not the same as previous goal
                if timeManager.monthValue(for: goals[i].date) != previousMonth {
                    //Store completed goals vs total goals for previous month
                    stats.append((index: monthIndex.last!, completed: goalsCompleted, total: totalGoals))
                    //Add new month index
                    monthIndex.append(sections.count)
                    sections.append(timeManager.monthCaption(for: goals[i].date))
                    //Reset Counters
                    totalGoals = 0
                    goalsCompleted = 0
                }
            }
            if date == nil {
                //First Goal
                sections.append(goals[i].date)
            } else if timeManager.startOfDay(for: date!) != timeManager.startOfDay(for: goals[i].date){
                //Only store each date once
                sections.append(goals[i].date)
            }
            date = goals[i].date
            previousMonth = timeManager.monthValue(for: (goals[i].date))
            totalGoals += 1
            goalsCompleted += goals[i].completion == true ? 1 : 0
            if i == 0 {
                //Last goal
                stats.append((index: monthIndex.last!, completed: goalsCompleted, total: totalGoals))
            }
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //Custom view for tableview header
        if sections.count > 0 {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 22))
        returnedView.backgroundColor = UIColor.secondarySystemBackground
        let label = UILabel(frame: CGRect(x: 0, y: 4, width: UIScreen.main.bounds.width, height: 20))
        label.font = UIFont(name: "Avenir-Medium", size: 17)
        label.textColor = UIColor.black
        label.font = monthIndex.contains(section) ? UIFont(name: "Avenir-Black", size: 18) : UIFont(name: "Avenir-Heavy", size: 17)
        label.text = monthIndex.contains(section) ? (sections[section] as! String) : timeManager.dateCaption(for: sections[section] as! Date)
        label.textAlignment = .center
        returnedView.addSubview(label)
        return returnedView
        }
        return nil
    }

    func getSummaryString(for section: Int) -> String {
        // Function to summarise goals completedo out total goals
        let i = stats.firstIndex(where: { $0.index == section})!
        return "\(stats[i].completed) out of \(stats[i].total) goals completed"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Send selected goal to segue
        if segue.identifier == "viewGoalSegueID" {
            let goalViewController = segue.destination as! GoalViewController
            goalViewController.goal = dataManager.fetchGoal(for: (sender as! HistoryGoalTableViewCell).goalID) as! Goal
        }
    }
    
 
}

