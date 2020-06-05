//
//  HistorySummaryTableViewCell.swift
//  FocusOn
//
//  Created by Michael Gresham on 05/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit

class HistorySummaryTableViewCell: UITableViewCell {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var summaryTitle: UILabel!
    func setSummaryLabel(title: String) {
        createShadowLayer()
        view.layer.cornerRadius = 10
        summaryTitle.text = title
    }
    func createShadowLayer(){
        layer.masksToBounds = false
        layer.shadowOpacity = 0.23
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = UIColor.black.cgColor
        self.backgroundColor = .clear
    }
}
