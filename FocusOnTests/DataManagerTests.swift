//
//  DataManagerTests.swift
//  FocusOnTests
//
//  Created by Michael Gresham on 05/06/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import XCTest
import CoreData
@testable import FocusOn

class DataManagerTests: XCTestCase {

    var dataManager: DataManager!
    var timeManager: TimeManager!
    var managedContext: NSManagedObjectContext!
    var goalsBeforeTest: Int!
    var goalsAfterTest: Int!
    var tasksBeforeTest: Int!
    var tasksAfterTest: Int!
    
    override func setUp() {
        super.setUp()
        dataManager = DataManager()
        timeManager = TimeManager()
        managedContext = dataManager.context
        
    }
    
    //MARK: Helpers
    func deleteGoal(id: UUID) {
        dataManager.deleteGoal(for: id)
    }
    
    func deleteTask(id: UUID) {
        dataManager.deleteTask(for: id)
    }
    
    //MARK: Tests
    
    func testGivenGoalIsCreated_WhenFucntionCalled_ThenOneObjectIsAddedToContext() {
        goalsBeforeTest = dataManager.fetchGoalHistory(from: nil, to: nil)!.count
        let id = dataManager.createEmptyGoal()
        goalsAfterTest = dataManager.fetchGoalHistory(from: nil, to: nil)!.count
        XCTAssertEqual(goalsBeforeTest + 1, goalsAfterTest)
        deleteGoal(id: id)
    }
    
    func testGivenTaskAndGoalAreCreated_WhenFunctionsCalled_ThenTwoObjectsAreAddedToContext() {
        //setup
        var goals = dataManager.fetchGoalHistory(from: nil, to: nil)! as [Goal]
        goalsBeforeTest = goals.count
        var tasks = [Task]()
        for goal in goals {
            let tasksForGoal = dataManager.fetchTasks(for: goal.id)! as! [Task]
            for task in  tasksForGoal {
                tasks.append(task)
            }
        }
        tasksBeforeTest = tasks.count
        
        //test
        let goalId = dataManager.createEmptyGoal()
        let taskId = dataManager.createEmptyTask(forGoal: goalId)
        
        //results
        goals.removeAll()
        tasks.removeAll()
        goals = dataManager.fetchGoalHistory(from: nil, to: nil)! as [Goal]
        goalsAfterTest = goals.count
        for goal in goals {
            let tasksForGoal = dataManager.fetchTasks(for: goal.id)! as! [Task]
            for task in  tasksForGoal {
                tasks.append(task)
            }
        }
        tasksAfterTest = tasks.count
        
        XCTAssertEqual(goalsBeforeTest + 1, goalsAfterTest)
        XCTAssertEqual(tasksBeforeTest + 1, tasksAfterTest)
        deleteTask(id: taskId)
        deleteGoal(id: goalId)
    }
    
    func testGivenTasksExistForGoal_WhenGoalIsDeleted_ThenTasksAreAlsoDeleted() {
        //setup
        var goals = dataManager.fetchGoalHistory(from: nil, to: nil)! as [Goal]
        goalsBeforeTest = goals.count
        var tasks = [Task]()
        for goal in goals {
            let tasksForGoal = dataManager.fetchTasks(for: goal.id)! as! [Task]
            for task in  tasksForGoal {
                tasks.append(task)
            }
        }
        tasksBeforeTest = tasks.count
        
        
        //create goal with 2 tasks
        let goalId = dataManager.createEmptyGoal()
        let _ = dataManager.createEmptyTask(forGoal: goalId)
        let _ = dataManager.createEmptyTask(forGoal: goalId)
        
        //deleteGoal
        deleteGoal(id: goalId)
        
        //results
        goals.removeAll()
        tasks.removeAll()
        goals = dataManager.fetchGoalHistory(from: nil, to: nil)! as [Goal]
        goalsAfterTest = goals.count
        for goal in goals {
            let tasksForGoal = dataManager.fetchTasks(for: goal.id)! as! [Task]
            for task in  tasksForGoal {
                tasks.append(task)
            }
        }
        tasksAfterTest = tasks.count
        
        //Test if both task and goal are deleted
        XCTAssertEqual(goalsBeforeTest + tasksBeforeTest, tasksAfterTest + goalsAfterTest)
    }
    
    func testGivenGoalsExist_WhenAllGoalsFetched_ThenReturnAll() {
        //create 3 goals
        let goal1 = dataManager.createEmptyGoal()
        let goal2 = dataManager.createEmptyGoal()
        let goal3 = dataManager.createEmptyGoal()
        
        //fetch all goals
        let goals = dataManager.fetchGoalHistory(from: nil, to: nil)!
        XCTAssert(goals.count >= 3)
        
        //delete goals
        deleteGoal(id: goal1)
        deleteGoal(id: goal2)
        deleteGoal(id: goal3)
    }
    
    func testGivenGoalsExist_WhenSpecificDate_ThenForThatDate() {
        //create 3 goals
        let goal1 = dataManager.createEmptyGoal()
        let goal2 = dataManager.createEmptyGoal()
        let goal3 = dataManager.createEmptyGoal()
        
        //fetch goals for today
        let goals = dataManager.fetchGoalHistory(from: timeManager.today, to: nil)!
        XCTAssert(goals.count >= 3)
        
        //delete goals
        deleteGoal(id: goal1)
        deleteGoal(id: goal2)
        deleteGoal(id: goal3)
    }
    
    func testGivenGoalExists_WhenTitleIsChanged_ThenTitleIsUpdated() {
        //setup
        let goalId = dataManager.createEmptyGoal()
        let goal = dataManager.fetchGoal(for: goalId) as! Goal
        let titleBeforeTest = goal.title
        
        //Change Title
        goal.title = "This Title Is Different"
        dataManager.updateGoal(goal: goal)
        

        //Results
        let goalAfterTest = dataManager.fetchGoal(for: goalId) as! Goal
        XCTAssert(goalAfterTest.title != titleBeforeTest)
        
        deleteGoal(id: goalId)
    }
    
    func testDeleteGoal() {
        //setup
        let goalId = dataManager.createEmptyGoal()
        goalsBeforeTest = dataManager.fetchGoalHistory(from: nil, to: nil)?.count

        //test
        dataManager.deleteGoal(for: goalId)
        goalsAfterTest = dataManager.fetchGoalHistory(from: nil, to: nil)?.count
        
        //results
        XCTAssertEqual(goalsBeforeTest, goalsAfterTest + 1)
    }
    
    func testDeleteTask() {
        //setup
        let goalId = dataManager.createEmptyGoal()
        let taskId = dataManager.createEmptyTask(forGoal: goalId)
        tasksBeforeTest = dataManager.fetchTasks(for: goalId)?.count

        //test
        dataManager.deleteTask(for: taskId)
        tasksAfterTest = dataManager.fetchTasks(for: goalId)?.count
        
        //results
        XCTAssertEqual(tasksBeforeTest, tasksAfterTest + 1)
        
        deleteGoal(id: goalId)
    }
}
