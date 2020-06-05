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

class DataManager {
    var timeManager = TimeManager()
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
        emptyGoal.date = timeManager.startOfDay(for: Date.init())
        
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
            predicate = NSPredicate(format: "date >= %@ AND date <= %@", timeManager.startOfDay(for: from) as NSDate, timeManager.startOfDay(for: to) as NSDate)
        } else if let from = from {
            predicate = NSPredicate(format: "date >= %@", timeManager.startOfDay(for: from) as NSDate)
        }
        else if let to = to {
            predicate = NSPredicate(format: "date <= %@", timeManager.startOfDay(for: to) as NSDate)
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
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Task.id), task.id as CVarArg)
        
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

    //MARK: Demo Data
    
    func createDummyData(days: Int) {
        deleteAll()
        var titles = ["Create a New App", "Finish next Project on OC", "Brainstorm ideas for next project", "Refactor and test my code"]
        var taskTitles = ["Work Hard", " Send important emails", "Schedule meeting on Zoom", "Submit project on OC", "Commit project to GitHub", "Continue to develop your Swift skills", "Put comments in your code", "Test code thoroughly"]
        for i in 1 ..< days {
            let rand = Int.random(in: 0 ... 5)
            for _ in 0 ..< rand {
                titles = titles.shuffled()
                let goalID = createEmptyGoal()
                let goal = fetchGoal(for: goalID) as! Goal
                var date = Date.init()
                date.addTimeInterval(-Double(i * 3600 * 24))
                goal.title = titles.first!
                goal.date = timeManager.startOfDay(for: date)
                var tasks = [Task]()
                for _ in 0 ..< rand {
                    let taskID = createEmptyTask(forGoal: goal.id)
                    let task = fetchTask(for: taskID) as! Task
                    taskTitles = taskTitles.shuffled()
                    let completion = Int.random(in: 0 ... 1) == 1 ? true : false
                    task.completion = completion
                    task.title = taskTitles.first!
                    updateTask(task: task)
                    tasks.append(task)
                }
                let completion = tasks.filter { $0.completion == true }.count == tasks.count ? true : false
                goal.completion = completion
                updateGoal(goal: goal)
            }
        }
        saveContext()
    }
}
