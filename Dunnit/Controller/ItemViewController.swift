//
//  DunnitViewController.swift
//  Dunnit
//
//  Created by Aakarshit Jaswal on 28/01/22.
//

import Foundation
import UIKit
import RealmSwift
import ChameleonFramework
import DeveloperToolsSupport

class ItemViewController: SwipeTableViewController, UITextFieldDelegate {
    
    let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory.name
        if let categoryColor = UIColor(hexString: selectedCategory.color) {
            searchBar.backgroundColor = categoryColor
            searchBar.searchBarStyle = .minimal
          
            
            
            //To change the colour of status bar
            let navBarAppearance = UINavigationBarAppearance()
            let navBar = navigationController?.navigationBar
            navBarAppearance.configureWithOpaqueBackground()
            
            //Contrast color from Chamaleon to set the color of the text based on the category color
            let contrastColour = ContrastColorOf(categoryColor, returnFlat: true)
            
            //SearchBar Placeholder Colour Change
            searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
                string: "Search",
                attributes: [.foregroundColor: contrastColour]
            )
            searchBar.searchTextField.textColor = contrastColour
            
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: contrastColour]
            navBarAppearance.titleTextAttributes =  [.foregroundColor: contrastColour]
            navBarAppearance.shadowColor = .none
            navBarAppearance.backgroundColor = categoryColor
            navBar?.tintColor = contrastColour
            navBar?.standardAppearance = navBarAppearance
            navBar?.scrollEdgeAppearance = navBarAppearance
        }
    }
    
    var selectedCategory = Category() {
        didSet {
            loadData()
        }
    }
    
    var items: Results<Item>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    

    
    //MARK: TableView Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = items?[indexPath.row].title ?? "No items added yet"
        
        cell.backgroundColor = UIColor(hexString: selectedCategory.color)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(items!.count))
        
        
        if let color = cell.backgroundColor {
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            cell.tintColor = ContrastColorOf(color, returnFlat: true)
        }
        cell.accessoryType = items?[indexPath.row].done ?? false ? .checkmark : .none
        
        return cell
    }
    
    //MARK: Delete Item
    override func updateModel(indexPath: IndexPath) -> Bool {
        
                do {
                    try realm.write {
                        realm.delete(selectedCategory.items[indexPath.row])
                    }
                } catch {
                    print("Error occured while deleting item \(error)")
                }
        loadData()
        return true
    }

    
    
    
    //MARK: Add Item
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        
        
        var alertTextField = UITextField()
        
        let alert = UIAlertController(title: "Add a new Dunnit", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            let newItem = Item()
            newItem.title = alertTextField.text!
           
            
            
            do {
                try self.realm.write {
                    self.selectedCategory.items.append(newItem)
                }
            } catch {
                print(error)
            }
            
            self.loadData()
            
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        action.isEnabled = false
        alert.addAction(action)
        
        alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Your name"
                textField.autocapitalizationType = .words
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
                alertTextField = textField
        })
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK: Delete Cell

    func updateAction(action: UIAlertAction, alert: UIAlertController) {
        alert.addAction(action)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let alert = presentedViewController as? UIAlertController,
                let action = alert.actions.last,
                let text = textField.text {
                action.isEnabled = text.count > 0
            }
    }
    
    
    
    //MARK: Load Persistent Data
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










