//
//  ContentViewController.swift
//  PointsOnMap
//
//  Created by Thomas Huitema on 2/27/21.
//

import UIKit
import MapKit

class ContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {    
    @IBOutlet weak var myTableView: UITableView!
    var data = [
        "[NAME]",
        "[ADDRESS]",
        "[PHONE]",
        "[COORDINATES]"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for:  indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.numberOfLines = 0 // wraps lines of text
        return cell
    }
}
