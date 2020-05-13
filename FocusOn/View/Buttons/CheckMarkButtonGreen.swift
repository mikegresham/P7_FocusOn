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
}
