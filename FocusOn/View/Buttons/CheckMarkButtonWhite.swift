//
//  CheckMarkButtonWhite.swift
//  FocusOn
//
//  Created by Michael Gresham on 05/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit

class CheckMarkButtonWhite: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
        self.setImage(UIImage.init(named: "uncheckedWhite"), for: .normal)
        self.setImage(UIImage.init(named: "checkedWhite"), for: .selected)
    }
}
