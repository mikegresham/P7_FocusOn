//
//  HeaderFooterCell.swift
//  FocusOn
//
//  Created by Michael Gresham on 03/06/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit

class HeaderFooterCell: UITableViewCell {
    
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = false
        layer.shadowOpacity = 0.23
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = UIColor.black.cgColor
        view.layer.cornerRadius = 10
        self.backgroundColor = .clear
    }
    
}
