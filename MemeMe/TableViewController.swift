//
//  TableViewController.swift
//  MemeMe
//
//  Created by doc on 01/01/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let cellHeight: CGFloat = 150
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Sent Memes"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let meme = appDelegate.memes[indexPath.row]
        cell.customLabel.text = meme.topText + "..." + meme.bottomText
        cell.customImageView.image = meme.memedImage
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

}
