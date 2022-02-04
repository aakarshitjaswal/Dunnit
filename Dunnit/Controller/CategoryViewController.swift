//
//  CategoryViewController.swift
//  Dunnit
//
//  Created by Aakarshit Jaswal on 28/01/22.
//

import Foundation
import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        self.tableView.rowHeight = 80
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let theColourWeAreUsing = FlatGrayDark()
        
        let navBarAppearance = UINavigationBarAppearance()
        let navBar = navigationController?.navigationBar
        let navItem = navigationController?.navigationItem
        navBarAppearance.configureWithOpaqueBackground()

        let contrastColour = ContrastColorOf(theColourWeAreUsing, returnFlat: true)

        navBarAppearance.titleTextAttributes = [.foregroundColor: contrastColour]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: contrastColour]
        navBarAppearance.backgroundColor = theColourWeAreUsing
//        navItem?.rightBarButtonItem?.tintColor = contrastColour
        navBar?.tintColor = contrastColour
        navBar?.standardAppearance = navBarAppearance
        navBar?.scrollEdgeAppearance = navBarAppearance

        self.navigationController?.navigationBar.setNeedsLayout()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    //MARK: TableView Datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "New category"
        cell.backgroundColor = UIColor(hexString: categories?[indexPath.row].color ?? "#ffffff")
        if let color = cell.backgroundColor {
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        return cell
        
    }
    
    //MARK: Swipe to Delete
    override func updateModel(indexPath: IndexPath) -> Bool {
        guard let category = categories?[indexPath.row] else {
            return false
        }
        do {
            try realm.write {
                //                realm.delete(category.items)
                realm.delete(category)
            }
        } catch {
            print("Error occured while Updating information \(error)")
        }
        
        loadData()
        
        return true
    }
    
    
    
    //MARK: Add a category
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a new Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            self.saveData(category: newCategory)
            
            self.loadData()
        }
        
        action.isEnabled = false
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Type category name here"
            alertTextField.autocapitalizationType = .words
            alertTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            textField = alertTextField
        }
        
        
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    //MARK: TextFieldDidChange
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let alert = presentedViewController as? UIAlertController,
           let action = alert.actions.last,
           let text = textField.text {
            action.isEnabled = text.count > 0
        }
    }
    
    
    //MARK: Data Manipulation
    
    func loadData() {
        do {
            try realm.write({
                categories = realm.objects(Category.self)
                tableView.reloadData()
            })
        } catch {
            print(error)
        }
    }
    
    func saveData(category: Category) {
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            print(error)
        }
    }
    
    
    //MARK: TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let currentIndexPath = tableView.indexPathForSelectedRow!
        let destinationVC = segue.destination as! ItemViewController
        if let categories = categories {
            destinationVC.selectedCategory = categories[currentIndexPath.row]
        }
    }
}



