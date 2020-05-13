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
    @IBOutlet weak var summaryTitle: UILabel!
    func setSummaryLabel(title: String) {
        summaryTitle.text = title
    }
}
