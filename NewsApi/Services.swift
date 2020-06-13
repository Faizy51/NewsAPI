//
//  Services.swift
//  NewsApi
//
//  Created by Faizyy on 06/06/20.
//  Copyright © 2020 faiz. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Service {
    
    let queue = DispatchQueue.global(qos: .userInitiated)
    
    // thread safe dictionary
    var urlToDataMapping = [String: Data]()
    
    var saveCompletionHandler: (() -> Void)?
    let endpoint = "http://newsapi.org/v2/top-headlines?country=us&apiKey=c973b5ec072b42bd845526374bda68a9"
    let apiKey = "c973b5ec072b42bd845526374bda68a9"
    
    func downloadData(callback: @escaping ()->Void) {
        self.saveCompletionHandler = callback
        
        guard let url = URL(string: endpoint) else { return }
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                if let errorMessage = error?.localizedDescription {
                    print(errorMessage)
                }
                return
            }
            // Decode
            var dataModel: Model?
            do {
                dataModel = try JSONDecoder().decode(Model.self, from: data)
                print(dataModel?.articles.count ?? "No data")
                // Download icons
                self.downloadImages(dataModel?.articles ?? [])
            }
            catch let error as NSError {
                print("Error downloading data: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func downloadImages(_ listOfArticles: [Article]) {
        let downloadGroup = DispatchGroup()

        for article in listOfArticles {
            guard let imageUrl = URL(string: article.urlToImage) else { continue }
            downloadGroup.enter()
            
            URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                if let _ = error {
                    print("error downloading image for url \(imageUrl)")
                }
                else {
                    self.urlToDataMapping[article.urlToImage] = data
                    downloadGroup.leave()
                }
            }.resume()
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) {
            //save to coreData.
            self.save(list: listOfArticles)
        }
    }
    
    func save(list: [Article]) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Articles", in: managedContext)!
        
        for listItem in list {
            let article = NSManagedObject(entity: entity, insertInto: managedContext)

            article.setValue(listItem.title, forKey: "title")
            article.setValue(listItem.desc, forKey: "desc")
            article.setValue(listItem.url, forKey: "url")
            var data: Data?
            data = self.urlToDataMapping[listItem.urlToImage]
            article.setValue(data, forKey: "imageData")
        }
        
        do {
            try managedContext.save()
            self.saveCompletionHandler?()
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
