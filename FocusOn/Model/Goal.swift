//
//  Goal.swift
//  FocusOn
//
//  Created by Michael Gresham on 03/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import CoreData

class Goal: NSManagedObject {
    
    static var entityName: String { return "Goal" }
    
    //Attributes
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var date: Date
    @NSManaged var completion: Bool
    
    //Relationships
    @NSManaged var tasks: NSMutableSet?
    
    func changeGoalState() {
        self.completion.toggle()
    }
}
