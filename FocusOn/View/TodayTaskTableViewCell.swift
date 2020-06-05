//
//  TodayTaskTableViewCell.swift
//  FocusOn
//
//  Created by Michael Gresham on 03/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

protocol TodayTaskCellDelegate {
    func updateRowHeight()
    func taskUpdate(task: Task)
    func taskCompleted(task: Task)
}

class TodayTaskTableViewCell: UITableViewCell {
    var delegate: TodayTaskCellDelegate?
    var goalId = UUID.init()
    let dataController = DataManager()
    var task: Task?
    
    @IBOutlet weak var taskTextView: UITextView!
    @IBOutlet weak var taskCompletionButton: UIButton!
    @IBOutlet weak var addTaskButton: CheckMarkButtonGreen!
    
    @IBAction func addTaskButtonPressed(_ sender: Any) {
        //Present keyboard
        self.taskTextView.becomeFirstResponder()
    }
    @IBAction func taskCompletionButtonPressed(_ sender: UIButton){
        //Task completed, present animation
        taskCompletionButton.isSelected.toggle()
        task?.completion.toggle()
        delegate?.self.taskUpdate(task: task!)
        delegate?.self.taskCompleted(task: task!)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        //Initial Set Up
        createShadowLayer()
        taskTextView.delegate = self
        taskTextView.isScrollEnabled = false
        textViewDidChange(taskTextView)
    }
    
    func createShadowLayer() {
        super.awakeFromNib()
        layer.masksToBounds = false
        layer.shadowOpacity = 0.23
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = UIColor.black.cgColor
        self.backgroundColor = .clear
    }
    
    func setCellData(task: Task, goalId: UUID) {
        //Set cell data for existing task
        self.goalId = goalId
        self.task = task
        taskTextView.text = task.title
        manageTaskCompletionButton(task.completion)
        addTaskButton.isHidden = true
    }
    func setNewCellData(goalId: UUID) {
        //set cell data for placeholder add task cell
        self.goalId = goalId
        taskTextView.text = ""
        taskCompletionButton.isSelected = false
        taskCompletionButton.isHidden = true
        addTaskButton.isHidden = false
    }

    func manageTaskCompletionButton(_ completion: Bool) {
        taskCompletionButton.isSelected = completion
    }
}

//MARK: Text View Interactions

extension TodayTaskTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        //Fucntion to resize text view as user edits text
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.frame.size.height = estimatedSize.height
        delegate?.self.updateRowHeight()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //If user presses enter, hide keyboard
        if (text == "\n"){
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //It task is empty, create new task
        if self.task == nil {
            let id = dataController.createEmptyTask(forGoal: goalId)
            self.task = dataController.fetchTask(for: id) as? Task
        }
        //Update task
        task?.title = taskTextView.text
        task?.completion = taskCompletionButton.isSelected
        delegate?.self.taskUpdate(task: task!)
        //If no longer a placeholder cell, present checkmark button
        if taskTextView.text != "" {
            addTaskButton.isHidden = true
            taskCompletionButton.isHidden = false
        } else {
            task = nil
        }
    }
}
