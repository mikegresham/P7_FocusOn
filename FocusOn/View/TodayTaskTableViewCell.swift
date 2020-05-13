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
    func taskCompleted(completion:Bool)
}

class TodayTaskTableViewCell: UITableViewCell {
    var delegate: TodayTaskCellDelegate?
    
    @IBOutlet weak var taskTextView: UITextView!
    @IBOutlet weak var taskCompletionButton: UIButton!
    
    @IBAction func taskCompletionButtonPressed(_ sender: UIButton){
        taskCompletionButton.isSelected.toggle()
        delegate?.self.taskUpdate(cell: self)
        delegate?.self.taskCompleted(completion: taskCompletionButton.isSelected)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        taskTextView.delegate = self
        taskTextView.isScrollEnabled = false
        textViewDidChange(taskTextView)
    }
    
    func setCellData(task: Task, row: Int) {
        taskTextView.text = task.title
        manageTaskCompletionButton(task.completion)
        setTextProperties(text: task.title!)
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
        delegate?.self.taskUpdate(cell: self)
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
            taskCompletionButton.isHidden = true
        } else {
        self.taskTextView.textColor = UIColor.black
        self.taskTextView.font = UIFont(name: "Avenir-Book", size: 17)
        taskCompletionButton.isHidden = false
        }
    }
    
}
