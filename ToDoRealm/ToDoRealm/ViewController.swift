//
//  ViewController.swift
//  ToDoRealm
//
//  Created by Dilraj Devgun on 4/1/17.
//  Copyright © 2017 Dilraj Devgun. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UIActionSheetDelegate {

    @IBOutlet weak var tableview: UITableView!
    let realm = try! Realm()
    var results = try! Realm().objects(Task.self)
    var notificationToken: NotificationToken?
    let searchController = UISearchController(searchResultsController: nil)
    var filtered = [Task]()
    var filterStyle:String = "alpha"
    let priorityColors = [UIColor(red: 49/255, green: 237/255, blue: 137/255, alpha:1), UIColor(red: 255/255, green: 188/255, blue: 71/255, alpha:1), UIColor(red: 219/255, green: 31/255, blue: 91/255, alpha:1)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.dataSource = self
        self.tableview.delegate = self
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.tableview.tableHeaderView = self.searchController.searchBar
        self.tableview.tableFooterView = UIView()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.notificationToken = results.addNotificationBlock { (changes: RealmCollectionChange) in
            try! self.results = Realm().objects(Task.self)
            self.filterContentForSearchText(searchText: self.searchController.searchBar.text!)
            switch changes {
            case .initial:
                self.tableview.reloadData()
                break
            case .update(_, _, _, _):
                self.sortDataOnFilter()
                self.tableview.reloadData()
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.sortDataOnFilter()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filtered.count
        }
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell
        
        var task:Task
        if searchController.isActive && searchController.searchBar.text != "" {
            task = filtered[indexPath.row]
        } else {
            task = results[indexPath.row]
        }
        
        cell.setColor(color: self.priorityColors[task.priority-1])
        cell.textLabel?.text = task.taskName
        cell.detailTextLabel?.text = task.date.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            realm.beginWrite()
            var index = indexPath.row
            if searchController.isActive && searchController.searchBar.text != "" {
                index = results.index(of: filtered[indexPath.row])!
            }
            realm.delete(results[index])
            try! realm.commitWrite()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "addTVC") as! AddTaskViewController
        if searchController.isActive && searchController.searchBar.text != "" {
            vc.taskToEdit = filtered[indexPath.row]
        } else {
            vc.taskToEdit = results[indexPath.row]
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filtered = results.filter({ task in
            return task.taskName.lowercased().contains(searchText.lowercased())
        })
        self.tableview.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }

    @IBAction func addTask(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "addTVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func filterTasks(_ sender: UIBarButtonItem) {
        //Create the AlertController and add Its action like button in Actionsheet
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "Filter:", message: "", preferredStyle: .actionSheet)
        
        let cancel: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { void in
        }
        actionSheetControllerIOS8.addAction(cancel)
        
        let alphabetical: UIAlertAction = UIAlertAction(title: "A-Z", style: .default) { void in
            self.filterStyle = "alpha"
            self.sortDataOnFilter()
            self.tableview.reloadData()
        }
        actionSheetControllerIOS8.addAction(alphabetical)
        
        let reverseAlpha: UIAlertAction = UIAlertAction(title: "Z-A", style: .default) { void in
            self.filterStyle = "revAlpha"
            self.sortDataOnFilter()
            self.tableview.reloadData()
        }
        actionSheetControllerIOS8.addAction(reverseAlpha)
        
        let byDate: UIAlertAction = UIAlertAction(title: "by date added", style: .default) { void in
            self.filterStyle = "date"
            self.sortDataOnFilter()
            self.tableview.reloadData()
        }
        actionSheetControllerIOS8.addAction(byDate)
        
        let byPriority: UIAlertAction = UIAlertAction(title: "by priority", style: .default) { void in
            self.filterStyle = "priority"
            self.sortDataOnFilter()
            self.tableview.reloadData()
        }
        actionSheetControllerIOS8.addAction(byPriority)
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
    }
    
    func sortDataOnFilter() {
        switch self.filterStyle {
        case "alpha":
            self.filtered.sort(by: {(task1:Task, task2:Task) -> Bool in
                switch task1.taskName.compare(task2.taskName) {
                case ComparisonResult.orderedAscending: return true
                case ComparisonResult.orderedDescending: return false
                case ComparisonResult.orderedSame: return true
                }
            })
            self.results = self.results.sorted(byKeyPath: "taskName", ascending: true)
            break;
        case "revAlpha":
            self.filtered.sort(by: {(task1:Task, task2:Task) -> Bool in
                switch task1.taskName.compare(task2.taskName) {
                case ComparisonResult.orderedAscending: return false
                case ComparisonResult.orderedDescending: return true
                case ComparisonResult.orderedSame: return true
                }
            })
            self.results = self.results.sorted(byKeyPath: "taskName", ascending: false)
            break;
        case "date":
            self.filtered.sort(by: {(task1:Task, task2:Task) -> Bool in
                switch task1.date.compare(task2.date as Date) {
                case ComparisonResult.orderedAscending: return true
                case ComparisonResult.orderedDescending: return false
                case ComparisonResult.orderedSame: return true
                }
            })
            self.results = self.results.sorted(byKeyPath: "date", ascending: true)
            break;
        case "priority":
            self.filtered.sort(by: {(task1:Task, task2:Task) -> Bool in
                return task1.priority >= task2.priority ? true : false
            })
            self.results = self.results.sorted(byKeyPath: "priority", ascending: false)
            break;
        default:
            break;
        }
    }
}

