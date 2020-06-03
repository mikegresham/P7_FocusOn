//
//  CheckMarkButtonGreen.swift
//  FocusOn
//
//  Created by Michael Gresham on 03/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit

class CheckMarkButtonGreen: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
        self.setImage(UIImage.init(named: "uncheckedGreen"), for: .normal)
        self.setImage(UIImage.init(named: "checkedGreen"), for: .selected)
    }
    func plusButton() {
        let config = UIImage.SymbolConfiguration(scale: .large)
        self.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
    }
    func checkButton() {
        self.setImage(UIImage.init(named: "uncheckedGreen"), for: .normal)
        self.setImage(UIImage.init(named: "checkedGreen"), for: .selected)
    }
    
}
