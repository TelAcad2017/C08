//
//  FirstTableViewController.swift
//  20180127A
//
//  Created by bla on 1/27/18.
//  Copyright © 2018 bla. All rights reserved.
//

import UIKit

extension UIImageView
{
    public func imageFromUrl(url: URL)
    {
        let request = URLRequest(url: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: .main)
        {
            (response: URLResponse?, imageData: Data?, error: Error?) -> Void in
            if let imageData = imageData
            {
                self.image = UIImage(data: imageData)
            }
        }
    }
}

class FirstTableViewController: UITableViewController {
    // MARK: enum for expected errors
    enum ExpectedError : Error {
        case FirstError
        case FileNotFound
        case IllegalOperation
        case UnknownError
    }
    // this is the metadata (description) for a object representation of a Fruit
    struct Fruit {
        let name : String
        let imageUrl : NSURL
        let description : String
    }
    // a collection of fruits
    var fruits = [Fruit]()

    override func viewDidAppear(_ animated: Bool) {
        print("First table is ready!")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("fill!")
        parseFruits()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        // #warning Incomplete implementation, return the number of rows
        print(fruits.count)
        return fruits.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let fruit = fruits[indexPath.row]
        cell.textLabel!.text = fruit.name
        cell.detailTextLabel?.text = fruit.description
        cell.imageView?.imageFromUrl(url: fruit.imageUrl as URL)
        
        return cell
    }
    
    // my custom functions
    
    // parse the json file and get the fruits out of it
    func parseFruits()
    {
        do {
            let path = try getPathFromBundle(fileName: "myJsonFile", fileType: "json")
            let content = try String(contentsOfFile: path)
            let data = content.data(using: .utf8)
            let objectString = String(data: data!, encoding: .utf8)
            let newdata = objectString?.data(using: .utf8)
            do {
                if let xdata = newdata,
                    let json = try JSONSerialization.jsonObject(with: xdata) as? [String: Any],
                    let fruitsArray = json["fruits"] as? [[String: Any]] {
                    for fruit in fruitsArray {
                        let name = fruit["Name"] as? String
                        let url = fruit["Picture"] as? String
                        let description = fruit["Description"] as? String
                        let newFruit = Fruit(name: name!, imageUrl: NSURL(string: url!)!, description: description!)
                        fruits.append(newFruit)
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
        } catch {
            return
        }
        
        self.tableView.reloadData()
    }
    
    func getPathFromBundle(fileName : String, fileType : String) throws -> String
    {
        let path = Bundle.main.path(forResource: fileName, ofType: fileType)
        
        if path == nil
        {
            throw ExpectedError.FileNotFound
        }
        
        return path!
    }
}
