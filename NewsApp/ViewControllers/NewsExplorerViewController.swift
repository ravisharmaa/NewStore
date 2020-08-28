//
//  NewsExplorerViewController.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/27/20.
//

import UIKit

class NewsExplorerViewController: UITableViewController {

    var item: Item
    
    init(item: Item) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}
