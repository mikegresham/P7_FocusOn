//
//  TodayTests.swift
//  FocusOnTests
//
//  Created by Michael Gresham on 12/06/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import XCTest
import CoreData
@testable import FocusOn

class TodayTests: XCTestCase {

    var dataManager: DataManager!
    var timeManager: TimeManager!
    var todayViewController: TodayViewController!
    
    override func setUp() {
        super.setUp()
        dataManager = DataManager()
        timeManager = TimeManager()
        todayViewController = TodayViewController()
        
    }
    
    //MARK: Helpers
    
    func deleteGoal(id: UUID) {
        dataManager.deleteGoal(for: id)
    }
    
    func deleteTask(id: UUID) {
        dataManager.deleteTask(for: id)
    }
    
    //MARK: Tests
    
    func testGivenGoalExistsForToday_WhenCheckExistingGoal_ThenReturnExistingGoal() {
        //setup
        let goal = dataManager.createEmptyGoal()
        
        //test
        todayViewController.checkExistingGoal()
        
        //result
        XCTAssert(todayViewController.goals.count >= 1)
        
        deleteGoal(id: goal)
    }
    
    func testGivenNoGoalsExist_WhenCheckExistingGoal_ThenNewGoalCreated() {
        //setup
        dataManager.deleteAll()
        
        //test
        todayViewController.checkExistingGoal()
        
        //result -  1 goal should be created
        XCTAssert(todayViewController.goals.count == 1)
        
    }
    
    func  testGivenUncompletedGoalExistsForYesterday_WhenCheckYesterdaysGoal_ThenAskUser(){
        //setup
        dataManager.deleteAll()
        let goalID = dataManager.createEmptyGoal()
        let goal = dataManager.fetchGoal(for: goalID) as! Goal
        goal.date = timeManager.yesterday
        goal.completion = false
        dataManager.updateGoal(goal: goal)
        
        //test
        todayViewController.checkYesterdaysGoal()
        
        //result - no goal should be created - until user selects option - so goal should equal 0
        XCTAssert(todayViewController.goals.count == 0)
        
        deleteGoal(id: goalID)
    }
    
    func testGivenNoGoalExistsForYesterday_WhenCheckYesterdaysGoal_ThenCreateNewGoal(){
        //setup
        dataManager.deleteAll()
        
        //test
        todayViewController.checkYesterdaysGoal()
        
        //result - goal should be created as no goals exist for yesterday - so goal should equal 0
        XCTAssert(todayViewController.goals.count == 1)
        
    }
    
    func testGivenGoalsExistForYesterday_WhenRepeatGoals_ThenRepeatOnlyUncompletedGoals() {
        dataManager.deleteAll()
        let goalID1 = dataManager.createEmptyGoal()
        let goal1 = dataManager.fetchGoal(for: goalID1) as! Goal
        goal1.date = timeManager.yesterday
        goal1.completion = false
        let goalID2 = dataManager.createEmptyGoal()
        let goal2 = dataManager.fetchGoal(for: goalID2) as! Goal
        goal2.date = timeManager.yesterday
        goal2.completion = true
        dataManager.updateGoals(goals: [goal1, goal2])
        
        //test
        todayViewController.repeatGoals()
        
        //result - only 1 goal is umcompleted, so should return 1 goal
        XCTAssert(todayViewController.goals.count == 1)
        
        deleteGoal(id: goalID1)
        deleteGoal(id: goalID2)
    }
    
    func testGivenNewGoal_WhenNewGoalCreated_ThenGoalsIncreaseByOne() {
        //setup
        let goalsBeforeTest = todayViewController.goals.count
        
        //test
        todayViewController.newGoal()
        let goalsAfterTest = todayViewController.goals.count
        
        //result
        XCTAssertEqual(goalsBeforeTest, goalsAfterTest - 1)
    }
}
