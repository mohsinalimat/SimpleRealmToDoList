//
//  Task.swift
//  ToDoRealm
//
//  Created by Dilraj Devgun on 4/1/17.
//  Copyright © 2017 Dilraj Devgun. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    dynamic var taskName = ""
    dynamic var priority = 0
    dynamic var date = NSDate()
}
