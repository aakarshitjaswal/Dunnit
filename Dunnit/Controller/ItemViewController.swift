//
//  DunnitViewController.swift
//  Dunnit
//
//  Created by Aakarshit Jaswal on 28/01/22.
//

import Foundation
import UIKit
import RealmSwift

class ItemViewController: UITableViewController {
    
    let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    var selectedCategory = Category() {
        didSet {
            loadData()
        }
    }
    
    var items: Results<Item>?
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       items?.count ?? 0
    }
    
    //MARK: TableView Data Source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        
            cell.textLabel?.text = items?[indexPath.row].title ?? "No items added yet"
            
            cell.accessoryType = items?[indexPath.row].done ?? false ? .checkmark : .none
    
        return cell
    }
    
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a new Dunnit", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            let newItem = Item()
            newItem.title = textField.text!
            do {
                try self.realm.write {
                    self.selectedCategory.items.append(newItem)
                }
            } catch {
                print(error)
            }
            
            self.loadData()
            
        }
        
        alert.addAction(action)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Type here"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK: TableView Data Manipulation

    func loadData() {
        items = selectedCategory.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
        
    }
    
    
    
    
    
    
    
    
    
}















