//
//  SwipeTableViewController.swift
//  Dunnit
//
//  Created by Aakarshit Jaswal on 03/02/22.
//

import UIKit

class SwipeTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: Datasource

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    //MARK: Swipeable Delegate

    //The swipe to delete without using the pod
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
     
        // Create contextual action for delete
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
     
            // Perform the deletion
            let result = self?.updateModel(indexPath: indexPath) ?? false
     
            // Signal that the handler succeeded
            completionHandler(result)
        }
     
        // Set background color
        action.backgroundColor = .systemRed
     
        // Create configuration
        let configuration = UISwipeActionsConfiguration(actions: [action])
     
        return configuration
     
    }
    
    func updateModel(indexPath: IndexPath) -> Bool  {
        print("TableView Updated")
        return true
    }
    
    
    
    


}
