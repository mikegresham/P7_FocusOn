//
//  HistoryTaskTableViewCell.swift
//  FocusOn
//
//  Created by Michael Gresham on 06/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit


class HistoryTaskTableViewCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var taskCompletionButton: CheckMarkButtonGreen!
    @IBOutlet weak var taskTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        taskTextView.delegate = self
        taskTextView.isScrollEnabled = false
    }
    
    func setCellData(task: Task) {
        taskTextView.text = task.title
        manageTaskCompletionButton(task.completion)
    }
    private func manageTaskCompletionButton(_ completion: Bool) {
        taskCompletionButton.isSelected = completion
    }
}
