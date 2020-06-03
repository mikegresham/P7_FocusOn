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
    func taskUpdate(cell: TodayTaskTableViewCell)
    func taskCompleted(completion:Bool, cell: TodayTaskTableViewCell)
}

class TodayTaskTableViewCell: UITableViewCell {
    var delegate: TodayTaskCellDelegate?
    var goalId = UUID.init()
    let dataController = DataController()
    var task: Task?
    
    @IBOutlet weak var taskTextView: UITextView!
    @IBOutlet weak var taskCompletionButton: UIButton!
    @IBOutlet weak var addTaskButton: CheckMarkButtonGreen!
    
    @IBAction func addTaskButtonPressed(_ sender: Any) {
        self.taskTextView.becomeFirstResponder()
    }
    @IBAction func taskCompletionButtonPressed(_ sender: UIButton){
        taskCompletionButton.isSelected.toggle()
        task?.completion.toggle()
        delegate?.self.taskUpdate(cell: self)
        delegate?.self.taskCompleted(completion: taskCompletionButton.isSelected, cell: self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = false
        layer.shadowOpacity = 0.23
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = UIColor.black.cgColor
        taskTextView.delegate = self
        taskTextView.isScrollEnabled = false
        textViewDidChange(taskTextView)
        self.backgroundColor = .clear
    }
    
    func setCellData(task: Task, goalId: UUID) {
        self.goalId = goalId
        self.task = task
        taskTextView.text = task.title
        manageTaskCompletionButton(task.completion)
        setTextProperties(text: task.title)
        addTaskButton.isHidden = true
    }
    func setNewCellData(goalId: UUID) {
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
extension TodayTaskTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.frame.size.height = estimatedSize.height
        delegate?.self.updateRowHeight()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n"){
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.task == nil {
            let id = dataController.createEmptyTask(forGoal: goalId)
            self.task = dataController.fetchTask(for: id) as? Task
            print("hi")
        }
        task?.title = taskTextView.text
        task?.completion = taskCompletionButton.isSelected
        delegate?.self.taskUpdate(cell: self)
        if taskTextView.text != "" {
            addTaskButton.isHidden = true
            taskCompletionButton.isHidden = false
        }
        print("hi")
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Define task..." {
            textView.text = ""
        }
        setTextProperties(text: textView.text)
    }

    func setTextProperties(text: String) {
        if text == "Define task..." {
            self.taskTextView.textColor = UIColor.gray
            self.taskTextView.font = UIFont(name: "Avenir-Oblique", size: 17)
        } else {
        self.taskTextView.textColor = UIColor.black
        self.taskTextView.font = UIFont(name: "Avenir-Book", size: 17)
        }
    }

    
}
