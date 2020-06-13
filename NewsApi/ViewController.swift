//
//  ViewController.swift
//  NewsApi
//
//  Created by Faizyy on 06/06/20.
//  Copyright © 2020 faiz. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var newsArticles: [NSManagedObject] = []
    
    override func awakeFromNib() {
        // Uncomment below line to clear the objects in core data.
//        clearDatabase()
        self.loadViewIfNeeded()
        fetchDataFromDatabase()
        guard newsArticles.count == 0 else { return }
        let services = Service()
        services.downloadData { [weak self] in
            self?.fetchDataFromDatabase()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(self.newsArticles.count > 0)
        
        tableView.rowHeight = UITableView.automaticDimension

        tableView.estimatedRowHeight = tableView.rowHeight
    }
    
    func clearDatabase() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Articles")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedObjectContext.execute(batchDeleteRequest)
        } catch {
            // Error Handling
        }

    }
    
    func fetchDataFromDatabase() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Articles")
        
        do {
            self.newsArticles = try managedContext.fetch(fetchRequest)
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if self.newsArticles.count > 0 {
            tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ExpandingTableViewCell
        cell.article = self.newsArticles[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let urlString = newsArticles[indexPath.row].value(forKey: "url") as? String,
            let newsUrl = URL(string: urlString)
            else { return }
        
        UIApplication.shared.open(newsUrl, options: [ : ], completionHandler: nil)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "News Today"
    }
}

