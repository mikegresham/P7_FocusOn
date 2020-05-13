//
//  HistoryTaskTableViewCell.swift
//  FocusOn
//
//  Created by Michael Gresham on 06/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit

protocol HistoryTaskTableViewCellDelegate {
    func updateRowHeight()
}

class HistoryTaskTableViewCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var taskCompletionButton: CheckMarkButtonGreen!
    @IBOutlet weak var taskTextView: UITextView!
    var delegate: HistoryTaskTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        taskTextView.delegate = self
        taskTextView.isScrollEnabled = false
    }
    
    func setCellData(task: Task) {
        taskTextView.text = task.title
        manageTaskCompletionButton(task.completion)
        self.textViewDidChange(taskTextView)
    }
    private func manageTaskCompletionButton(_ completion: Bool) {
        taskCompletionButton.isSelected = completion
    }
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.frame.size.height = estimatedSize.height
        delegate?.self.updateRowHeight()
    }
}
