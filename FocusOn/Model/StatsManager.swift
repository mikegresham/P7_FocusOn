//
//  StatsManager.swift
//  FocusOn
//
//  Created by Michael Gresham on 05/06/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation

class StatsManager {
    let timeManager = TimeManager()
    let dataManager = DataManager()
    
       func countCompleted(goals: [Goal]) -> Int {
           return goals.filter { (goal) -> Bool in
               return goal.completion == true
           }.count
       }
       func dataForYear(year: Date) -> [(completed: Int, total: Int)] {
           var data = [(completed: Int, total: Int)]()
           let year = Calendar.current.component(.year, from: year)
           for i in 1 ... 12 {
               let firstDayOfMonth = Calendar.current.date(from: DateComponents(year: year, month: i, day: 1))!
               let lastDayComponents = DateComponents(month: 1, day: -1)
               let lastDayOfMonth = Calendar.current.date(byAdding: lastDayComponents, to: firstDayOfMonth)!
               data.append(dataForDates(first: firstDayOfMonth, last: lastDayOfMonth))
           }
           return data
       }
       func dataForWeek(week: Date) -> [(completed: Int, total: Int)] {
           let firstDayOfweek = timeManager.firstDayOfWeek(for: week)
           let lastDayOfWeek = firstDayOfweek.addingTimeInterval(TimeInterval(6 * 24 * 3600))
           return taskDataForDates(first: firstDayOfweek, last: lastDayOfWeek)
       }
       func dataForDates(first: Date, last: Date) -> (Int, Int) {
           let goals = dataManager.fetchGoalHistory(from: first, to: last)! as [Goal]
           let goalsCompleted =  goals.filter { (goal) -> Bool in
               return goal.completion == true
           }.count
           return (goalsCompleted, goals.count)
       }
       func taskDataForDates(first: Date, last: Date) -> [(completed: Int, total: Int)] {
           var data = [(completed: Int, total: Int)]()
           let goals = dataManager.fetchGoalHistory(from: first, to: last)! as [Goal]

           var completed = 0
           var total = 0
           var date = first
           for _ in 1 ... 7 {
               let goalsForDate = goals.filter { $0.date == timeManager.startOfDay(for: date) }
               if goalsForDate.count > 0 {
                       completed = goalsForDate.filter { $0.completion == true }.count
                       total = goalsForDate.count
                       data.append((completed: completed, total: total))

               } else {
                   data.append((completed: 0, total: 0))
               }
               date.addTimeInterval(Double(3600 * 24))
           }
           return data
       }
    
    func fetchFirstDate() -> Date {
        let goals = dataManager.fetchGoalHistory(from: nil, to: nil)! as [Goal]
        return goals.first!.date
    }
    
}
