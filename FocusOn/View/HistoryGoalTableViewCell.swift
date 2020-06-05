//
//  HistoryGoalTableViewCell.swift
//  FocusOn
//
//  Created by Michael Gresham on 06/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit

class HistoryGoalTableViewCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var goalTitleTextView: UITextView!
    @IBOutlet weak var goalCompletionButton: CheckMarkButtonWhite!
    var goalID = UUID()
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = 10
        createShadowLayer()
        goalTitleTextView.delegate = self
        goalTitleTextView.isScrollEnabled = false
    }
    func createShadowLayer(){
        layer.masksToBounds = false
        layer.shadowOpacity = 0.23
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = UIColor.black.cgColor
        self.backgroundColor = .clear
    }
    func setCellData(goal: Goal) {
        goalID = goal.id
        goalTitleTextView.text = goal.title
        manageTaskCompletionButton(goal.completion)
    }
    private func manageTaskCompletionButton(_ completion: Bool) {
        goalCompletionButton.isSelected = completion
    }
}
