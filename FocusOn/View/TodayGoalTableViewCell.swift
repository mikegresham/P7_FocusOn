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
    func goalCompleted(goalId: UUID)
}

class TodayGoalTableViewCell: UITableViewCell {
    var delegate: TodayGoalCellDelegate?
    var goalID = UUID()

    @IBOutlet weak var goalTextView: UITextView!
    @IBOutlet weak var goalCompletionButton: CheckMarkButtonGreen!
    
    @IBAction func goalCompletionButtonAction(_ sender: Any) {
        //Button action for Goal Checkmark
        goalCompletionButton.isSelected.toggle()
        delegate?.self.goalUpdate(cell: self)
        if goalCompletionButton.isSelected == true {
            //If completed, present goal animation
            delegate?.self.goalCompleted(goalId: goalID)
        }
    }
    override func awakeFromNib() {
        //Inital Set Up
        createShadowLayer()
        goalTextView.isScrollEnabled = false
        goalTextView.delegate = self
        textViewDidChange(goalTextView)
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
    
    func setCellData(goal: Goal) {
        goalTextView.text = goal.title
        manageGoalCompletionButton(goal.completion)
        goalID = goal.id
    }
    func manageGoalCompletionButton(_ completion: Bool) {
        goalCompletionButton.isSelected = completion
    }
}

//MARK: Text View Interactions
extension TodayGoalTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        //Adjust size of text view, whilst users is typing.
        let size = CGSize(width: textView.frame.size.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.frame.size.height = estimatedSize.height
        delegate?.self.updateRowHeight()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //If user presses return, keyboard should close.
        if (text == "\n"){
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            //Placeholder text for goal
            textView.text = "Set your goal..."
        } else {
            //Update Goal
        delegate?.self.goalUpdate(cell: self)
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        //If placeholder text, set to blank
        if textView.text == "Set your goal..." {
            textView.text = ""
        }
    }

}
