//
//  TodayGoalTableViewCell.swift
//  FocusOn
//
//  Created by Michael Gresham on 03/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit

protocol TodayGoalCellDelegate {
    func updateRowHeight()
    func goalUpdate(cell: TodayGoalTableViewCell)
    func goalCompleted()
}

class TodayGoalTableViewCell: UITableViewCell {
    var delegate: TodayGoalCellDelegate?

    @IBOutlet weak var goalTextView: UITextView!
    @IBOutlet weak var goalCompletionButton: CheckMarkButtonGreen!
    
    @IBAction func goalCompletionButtonAction(_ sender: Any) {
        goalCompletionButton.isSelected.toggle()
                delegate?.self.goalUpdate(cell: self)
        if goalCompletionButton.isSelected == true {
            delegate?.self.goalCompleted()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        goalTextView.isScrollEnabled = false
        goalTextView.delegate = self
        textViewDidChange(goalTextView)
    }
    
    func setCellData(goal: Goal) {
        goalTextView.text = goal.title
        manageGoalCompletionButton(goal.completion)
    }
    func manageGoalCompletionButton(_ completion: Bool) {
        goalCompletionButton.isSelected = completion
    }
}

extension TodayGoalTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.size.width, height: .infinity)
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
        if textView.text == "" {
            textView.text = "Set your goal..."
        } else {
        delegate?.self.goalUpdate(cell: self)
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Set your goal..." {
            textView.text = ""
        }
    }
}
