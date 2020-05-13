//
//  Goal.swift
//  FocusOn
//
//  Created by Michael Gresham on 03/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation

class Goal {
    var title: String
    var tasks: [Task]
    var date: Date
    var completion: Bool

    init(title: String, tasks: [Task], date: Date, completion: Bool) {
        self.title = title
        self.tasks = tasks
        self.date = date
        self.completion = completion
    }
    
    convenience init() {
        let title = "Set your goal..."
        var tasks = [Task]()
        for _ in 1 ... 3 {
            tasks.append(Task.init(title: "Define task...", completion: false))
        }
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let date =  calendar.startOfDay(for: Date.init())
        let completion = false
        self.init(title: title, tasks: tasks, date: date, completion: completion)
    }
    
    func createDummyGoal() {
        
    }
    
    func insertTask(task: Task, at row:Int){
        tasks[row] = task
    }
    
    func apendTask(task: Task){
        self.tasks.append(task)
    }
    
    func removeTask(at indexPath: IndexPath){
        tasks.remove(at: indexPath.row)
    }
    
    func changeTaskState(at indexPath: IndexPath){
        tasks[indexPath.row].completion.toggle()
    }
    
    func changeGoalState() {
        self.completion.toggle()
    }
}
