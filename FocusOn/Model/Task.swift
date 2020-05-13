//
//  Task.swift
//  FocusOn
//
//  Created by Michael Gresham on 03/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation

class Task: NSObject, NSCoding {

    var title: String?
    var completion: Bool
    
    init(title: String, completion: Bool) {
        self.title = title
        self.completion = completion
    }
     override convenience init() {
        self.init(title: "Define task...", completion: false)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.title, forKey: "title")
        coder.encode(self.completion, forKey: "completion")
    }
    
    required init?(coder: NSCoder) {
        if let title = coder.decodeObject(forKey: "title") as? String {
            self.title = title
        }
        let completion = coder.decodeBool(forKey: "completion")
        self.completion = completion
    }
    
}
