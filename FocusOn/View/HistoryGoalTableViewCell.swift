//
//  HistoryGoalTableViewCell.swift
//  FocusOn
//
//  Created by Michael Gresham on 06/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit

protocol HistoryGoalTableViewCellDelegate {
    func updateRowHeight()
}

class HistoryGoalTableViewCell: UITableViewCell, UITextViewDelegate {
    var delegate: HistoryGoalTableViewCellDelegate?
    @IBOutlet weak var goalTitleTextView: UITextView!
    @IBOutlet weak var goalCompletionButton: CheckMarkButtonWhite!
    override func awakeFromNib() {
        super.awakeFromNib()
        goalTitleTextView.delegate = self
        goalTitleTextView.isScrollEnabled = false
    }
    
    func setCellData(goal: Goal) {
        goalTitleTextView.text = goal.title
        manageTaskCompletionButton(goal.completion)
        self.textViewDidChange(goalTitleTextView)
    }
    private func manageTaskCompletionButton(_ completion: Bool) {
        goalCompletionButton.isSelected = completion
    }
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.frame.size.height = estimatedSize.height
        delegate?.self.updateRowHeight()
    }
}
