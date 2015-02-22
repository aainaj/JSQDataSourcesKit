//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQDataSourcesKit
//
//
//  GitHub
//  https://github.com/jessesquires/JSQDataSourcesKit
//
//
//  License
//  Copyright (c) 2015 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit
import CoreData
import JSQDataSourcesKit

class FetchedTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let stack = CoreDataStack()

    var dataSourceProvider: TableViewFetchedResultsDataSourceProvider<Thing, TableViewCellFactory<TableViewCell, Thing> >?

    var delegateProvider: TableViewFetchedResultsDelegateProvider<Thing, TableViewCellFactory<TableViewCell, Thing> >?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: tableCellId)

        let factory = TableViewCellFactory(reuseIdentifier: tableCellId) { (cell: TableViewCell, model: Thing, tableView: UITableView, indexPath: NSIndexPath) -> TableViewCell in
            cell.textLabel?.text = model.displayName
            cell.textLabel?.textColor = model.displayColor
            cell.detailTextLabel?.text = "\(indexPath.section), \(indexPath.row)"
            return cell
        }

        let frc: NSFetchedResultsController = NSFetchedResultsController(fetchRequest: Thing.fetchRequest(), managedObjectContext: stack.context, sectionNameKeyPath: "category", cacheName: nil)

        self.delegateProvider = TableViewFetchedResultsDelegateProvider(tableView: tableView, cellFactory: factory, controller: frc)

        self.dataSourceProvider = TableViewFetchedResultsDataSourceProvider(fetchedResultsController: frc, cellFactory: factory, tableView: tableView)
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.dataSourceProvider?.performFetch()
    }


    @IBAction func didTapAddButton(sender: UIBarButtonItem) {

        if let indexPaths = tableView.indexPathsForSelectedRows() as? [NSIndexPath] {
            for i in indexPaths {
                tableView.deselectRowAtIndexPath(i, animated: true)
            }
        }

        let newThing = Thing.newThing(stack.context)
        stack.saveAndWait()
        dataSourceProvider?.performFetch()

        if let indexPath = dataSourceProvider?.fetchedResultsController.indexPathForObject(newThing) {
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .Middle)
        }

        println("Added new thing: \(newThing)")
    }


    @IBAction func didTapDeleteButton(sender: UIBarButtonItem) {

        if let indexPaths = tableView.indexPathsForSelectedRows() as? [NSIndexPath] {

            println("Deleting things at indexPaths: \(indexPaths)")

            for i in indexPaths {
                let thingToDelete = dataSourceProvider?.fetchedResultsController.objectAtIndexPath(i) as! Thing
                stack.context.deleteObject(thingToDelete)
            }
            
            stack.saveAndWait()
            dataSourceProvider?.performFetch()
        }
    }
    
}
