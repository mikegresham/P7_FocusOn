//
//  Task.swift
//  FocusOn
//
//  Created by Michael Gresham on 03/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import CoreData

class Task: NSManagedObject {

    static var entityName: String { return "Task" }
    
    //Attributes
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var completion: Bool
    
    //Relationships
    @NSManaged var goal: Goal
}
