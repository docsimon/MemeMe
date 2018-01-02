//
//  DetailViewController.swift
//  MemeMe
//
//  Created by doc on 02/01/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var memedImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = memedImage {
            imageView.image = image
        }
    }
}
