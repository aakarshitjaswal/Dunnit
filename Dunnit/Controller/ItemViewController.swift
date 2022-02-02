//
//  DunnitViewController.swift
//  Dunnit
//
//  Created by Aakarshit Jaswal on 28/01/22.
//

import Foundation
import UIKit
import RealmSwift
import SwipeCellKit

class ItemViewController: UITableViewController {
    
    let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false

        loadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
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
    
    //MARK: TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedItem = items?[indexPath.row] {
            do {
                try realm.write {
                    selectedItem.done = !selectedItem.done
                }
            } catch {
                print(error)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    
}

//MARK: SearchBar Delegate

extension ItemViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text!.count > 0 {
            items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateAdded", ascending: true)
        } else {
            
            loadData()
        }
        
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            loadData()
        } else {
            DispatchQueue.main.async {
                self.items = self.realm.objects(Item.self).filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateAdded", ascending: true)
                self.tableView.reloadData()
            }
        }
    }
}

extension ItemViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        print(indexPath)
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            do {
                
                    try self.realm.write {
                        self.realm.delete(self.selectedCategory.items[indexPath.row])
                        self.loadData()
                    
                
                }
            }   catch {
                print(error)
            }
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
    }
}















