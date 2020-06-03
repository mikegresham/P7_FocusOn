//
//  DataContoller.swift
//  FocusOn
//
//  Created by Michael Gresham on 03/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol DataManagerDelegate {
    var goals: [Goal] { get set }
}

class DataController {
    var delegate: DataManagerDelegate?
    var context: NSManagedObjectContext
    var entity: NSEntityDescription?

    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: Goal.entityName, in: context)
    }
    
    //MARK: Create
    
    func createEmptyGoal() -> UUID {
        let emptyGoal = NSEntityDescription.insertNewObject(forEntityName: Goal.entityName, into: context) as! Goal
        
        emptyGoal.id = UUID()
        emptyGoal.title = "Set your goal..."
        emptyGoal.completion = false
        emptyGoal.date = Date.init()
        
        saveContext()

        return emptyGoal.id
    }
    
    func createEmptyTask(forGoal goalID: UUID) -> UUID {
        let emptyTask = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: context) as! Task
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Goal.entityName)
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Goal.id), goalID as CVarArg)
        
        do {
            let result = try context.fetch(fetchRequest)
            if let returnedResult = result as? [Goal] {
                if returnedResult.count != 0 {
                    let fetchedGoal = returnedResult.first!
                    
                    emptyTask.id = UUID()
                    emptyTask.title = ""
                    emptyTask.completion = false
                    emptyTask.goal = fetchedGoal
                    
                    
                } else { print("Fetch result was empty for specified goal id: \(goalID)") }
            }
        } catch { print("Fetch on goal id: \(goalID) failed. \(error)") }
        
        saveContext()
        
        return emptyTask.id
    }
    
    //MARK: Read
    
    func fetchGoal(for id: UUID) -> NSManagedObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Goal.entityName)
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Goal.id), id as CVarArg)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [NSManagedObject]
            return result.first
        } catch { print("Fetch on goal id: \(id) failed. \(error)") }
        return nil
    }
    
    func fetchTask(for taskId: UUID) -> NSManagedObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Task.entityName)
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Task.id), taskId as CVarArg)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [NSManagedObject]
            return result.first
        } catch { print("Fetch on goal id: \(taskId) failed. \(error)") }
        return nil
    }
    
    func fetchTasks(for goalId: UUID) -> [NSManagedObject]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Task.entityName)
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Task.goal.id), goalId as CVarArg)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [NSManagedObject]
            return result
        } catch { print("Fetch on goal id: \(goalId) failed. \(error)") }
        return nil
    }
    
    func fetchGoalHistory(from: Date?, to: Date?) -> [Goal]?{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Goal.entityName)
        
        var predicate: NSPredicate?
        
        if let from = from, let to = to {
            predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfDay(for: from) as NSDate, startOfDay(for: to) as NSDate)
        } else if let from = from {
            predicate = NSPredicate(format: "date >= %@", startOfDay(for: from) as NSDate)
        }
        else if let to = to {
            predicate = NSPredicate(format: "date <= %@", startOfDay(for: to) as NSDate)
        }
        request.predicate = predicate
        let sectionSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sectionSortDescriptor]
        
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [Goal]
            return result
        }
        catch {
            
        }
        return nil
    }
    
    //MARK: Update
    
    
    
    func updateGoal(goal: Goal) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Goal.entityName)
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Goal.id), goal.id as CVarArg)
            do {
                let result = try context.fetch(request)
                if let returnedResult = result as? [Goal] {
                    if returnedResult.count != 0 {
                        let fetchedGoal = returnedResult.first!
                        fetchedGoal.title = goal.title
                        fetchedGoal.date = goal.date
                        fetchedGoal.completion = goal.completion
                        //fetchedGoal.tasks = goal.tasks
                        saveContext()
                    } else { print("Fetch result was empty for specified goal id: \(goal.id)") }
                }
           } catch { print("Fetch on goal id: \(goal.id) failed. \(error)") }
       }
    

    func updateGoals(goals: [Goal]) {
        for i in 0 ..< goals.count {
            updateGoal(goal: goals[i])
        }
    }
    
    func updateTask(task: Task) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Task.entityName)
        let withGoalIDPredicate = NSPredicate(format: "%K == %@", #keyPath(Task.goal.id), task.goal.id as CVarArg)
        let findTaskPredicate = NSPredicate(format: "%K == %@", #keyPath(Task.id), task.id as CVarArg)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [withGoalIDPredicate, findTaskPredicate])
        
        do {
            let result = try context.fetch(fetchRequest)
            if let returnedResult = result as? [Task] {
                if returnedResult.count != 0 {
                    let fetchedTask = returnedResult.first!
        
                        // Set new values for task if not nill.
                    fetchedTask.title = task.title
                    fetchedTask.completion = task.completion
                    
                    saveContext()
                } else {
                    print("Fetch result was empty for specified task id: \(task.id), goal id: \(task.goal.id).")
                }
            }
        } catch {
            print("Fetch on task id: \(task.id), goal id: \(task.goal.id) failed. \(error)")
        }
    }
       
    
    //MARK: Delete
    
    func deleteGoal(for id: UUID) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Goal.entityName)
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Goal.id), id as CVarArg)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [Goal]
            context.delete(result.first!)
        } catch {
            
        }
    }
    
    func deleteTask(for id: UUID) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Task.entityName)
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Task.id), id as CVarArg)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [Task]
            context.delete(result.first!)
        } catch {
            
        }
    }
    
    func deleteAll () {
        var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Goal.entityName)
        var batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
        }
        catch{
            
        }
        fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Task.entityName)
        batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
        }
        catch{
            
        }
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
        }
        catch {
            print("Save failed: \(error)")
            context.rollback()
        }
    }
    
    /*
    
    func log(goal: Goal){
        var goalEntity = fetchGoalEntity(date: today)
        if goalEntity == nil {
            goalEntity = createGoalEntity()
        }
        updateGoalEntity(goalEntity: goalEntity, goal: goal)
        saveContext()
    }
    
    func fetchGoal(date: Date) -> Goal? {
        if let goalObject = fetchGoalEntity(date: date) {
            print("HI")
            let title = (goalObject as! GoalEntity).title!
            let tasks = (goalObject as! GoalEntity).tasks as! [Task]
            let date = (goalObject as! GoalEntity).date!
            let completion = (goalObject as! GoalEntity).completion
            return Goal.init(title: title, tasks: tasks, date: date, completion: completion)
        }
        return nil
    }
    
    
    private func fetchGoalEntity(date: Date) -> NSManagedObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(format: "date = %@", startOfDay(for: date) as NSDate)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [NSManagedObject]
            return result.first
        } catch {
            
        }
        return nil
    }
    
    func fetchFirstDate() -> Date {
        let logs = self.logs(from: nil, to: nil)
        return (logs.last as! GoalEntity).date!
    }
    
    private func saveContext() {
        do {
            try context.save()
        }
        catch {
            
        }
    }
    
    private func createGoalEntity() -> NSManagedObject? {
        if let entity = entity {
            return NSManagedObject(entity: entity, insertInto: context)
        }
        return nil
    }
    
    func deleteGoal(for date: Date) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(format: "date = %@", startOfDay(for: date) as NSDate)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [NSManagedObject]
            context.delete(result.first!)
        } catch {
            
        }
    }
    
    func updateGoalEntity(goalEntity: NSManagedObject?, goal: Goal) {
        if let goalEntity = goalEntity {
            goalEntity.setValue(goal.title, forKey:"title")
            goalEntity.setValue(goal.date, forKey: "date")
            goalEntity.setValue(goal.tasks, forKey: "tasks")
            goalEntity.setValue(goal.completion, forKey: "completion")
        }
    }
    
    func deleteAll () {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
        }
        catch{
            
        }
        saveContext()
    }
    
    func logs(from: Date?, to: Date?) -> [NSManagedObject]{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        var predicate: NSPredicate?
        
        if let from = from, let to = to {
            predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfDay(for: from) as NSDate, startOfDay(for: to) as NSDate)
        } else if let from = from {
            predicate = NSPredicate(format: "date >= %@", startOfDay(for: from) as NSDate)
        }
        else if let to = to {
            predicate = NSPredicate(format: "date <= %@", startOfDay(for: to) as NSDate)
        }
        request.predicate = predicate
        let sectionSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sectionSortDescriptor]
        
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [NSManagedObject]
            return result
        }
        catch {
            
        }
        return [NSManagedObject]()
    }
    
    func createDummyData(days: Int) {
        deleteAll()
        var titles = ["Create a New App", "Finish next Project on OC", "Brainstorm ideas for next project", "Refactor and test my code"]
        var taskTitles = ["Work Hard", " Send important emails", "Schedule meeting on Zoom", "Submit project on OC", "Commit project to GitHub", "Continue to develop your Swift skills", "Put comments in your code", "Test code thoroughly"]
        for i in 1 ..< days {
            titles = titles.shuffled()
            let goalEntity = createGoalEntity()
            if let goalEntity = goalEntity {
                var date = Date.init()
                date.addTimeInterval(-Double(i * 3600 * 24))
                goalEntity.setValue(titles.first, forKey: "title")
                goalEntity.setValue(startOfDay(for: date), forKey: "date")
                var tasks = [Task]()
                let rand = Int.random(in: 1 ... 5)
                for _ in 0 ..< rand {
                    taskTitles = taskTitles.shuffled()
                    let completion = Int.random(in: 0 ... 1) == 1 ? true : false
                    tasks.append(Task(title: taskTitles.first!, completion: completion))
                }
                let completion = tasks.filter { $0.completion == true }.count == tasks.count ? true : false
                goalEntity.setValue(completion, forKey: "completion")
                goalEntity.setValue(tasks, forKey: "tasks")
            }
        }
        saveContext()
    }
    func countCompleted(logs: [NSManagedObject]) -> Int {
        return logs.filter { (log) -> Bool in
            return (log as! GoalEntity).completion == true
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
        let firstDayOfweek = self.firstDayOfWeek(for: week)
        let lastDayOfWeek = firstDayOfweek.addingTimeInterval(TimeInterval(6 * 24 * 3600))
        return taskDataForDates(first: firstDayOfweek, last: lastDayOfWeek)
    }
    func dataForDates(first: Date, last: Date) -> (Int, Int) {
        let logs = self.logs(from: first, to: last)
        let goalsCompleted =  logs.filter { (log) -> Bool in
            return (log as! GoalEntity).completion == true
        }.count
        return (goalsCompleted, logs.count)
    }
    func taskDataForDates(first: Date, last: Date) -> [(completed: Int, total: Int)] {
        var data = [(completed: Int, total: Int)]()
        var logs = self.logs(from: first, to: last)

        var completed = 0
        var total = 0
        var date = first
        for _ in 1 ... 7 {
            if logs.count > 0 {
                if (logs.last as! GoalEntity).date! == self.startOfDay(for: date) {
                    let tasks = (logs.last as! GoalEntity).tasks as! [Task]
                    completed = tasks.filter { $0.completion == true }.count
                    total = tasks.count
                    data.append((completed: completed, total: total))
                    logs.removeLast()
                } else {
                    data.append((completed: 0, total: 0))
                }
            } else {
                data.append((completed: 0, total: 0))
            }
            date.addTimeInterval(Double(3600 * 24))
        }

        return data
    }
 */
}
// MARK: Date Variables and Functions
extension DataController {
    var today: Date {
        return startOfDay(for: Date())
    }
    var yesterday: Date {
        return today - 86400
    }
    
    func firstDayOfYear(for date: Date) -> Date {
        let year = Calendar.current.component(.year, from: date)
        let firstDayOfYear = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1))!
        return startOfDay(for: firstDayOfYear)
    }

    func firstDayOfWeek(for date: Date) -> Date{
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let difference = TimeInterval((2 - weekday) * 24 * 3600)
        return startOfDay(for: date.addingTimeInterval(difference))
    }

    func startOfDay(for date: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar.startOfDay(for: date)
    }
    func yearCaption(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    func dateCaption(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: date)
    }
    func weekCaption(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.timeStyle = .none
        
        return "Week beginning \(dateFormatter.string(from: date))"
    }
    func monthCaption(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: date)
    }
    func monthValue(for date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: date)
    }
 
}
