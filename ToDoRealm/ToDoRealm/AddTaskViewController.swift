//
//  AddTaskViewController.swift
//  ToDoRealm
//
//  Created by Dilraj Devgun on 4/1/17.
//  Copyright © 2017 Dilraj Devgun. All rights reserved.
//

import UIKit
import RealmSwift

class AddTaskViewController: UIViewController {

    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var priorityControl: UISegmentedControl!
    let realm = try! Realm()
    var taskToEdit:Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.taskTextField.becomeFirstResponder()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let tsk = taskToEdit {
            self.taskTextField.text = tsk.taskName
            self.priorityControl.selectedSegmentIndex = tsk.priority - 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addTask(_ sender: Any) {
        if taskTextField.text != "" {
            if let tsk = self.taskToEdit {
                try! realm.write {
                    tsk.taskName = self.taskTextField.text!
                    tsk.priority = priorityControl.selectedSegmentIndex + 1
                }
            }
            else {
                realm.beginWrite()
                let date = Date()
                let timeZone = TimeZone(abbreviation: "GMT")
                let nowTimeZone = TimeZone.current
                let currentGMTOffset = timeZone?.secondsFromGMT(for: date)
                let nowGMTOffset = nowTimeZone.secondsFromGMT(for: date)
                let interval = nowGMTOffset - currentGMTOffset!
                let nowdate = NSDate(timeInterval: TimeInterval(interval), since: date)
                realm.create(Task.self, value: [taskTextField.text, self.priorityControl.selectedSegmentIndex+1, nowdate])
                try! realm.commitWrite()
            }
        }
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

}
