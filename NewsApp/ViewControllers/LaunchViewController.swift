//
//  LaunchViewController.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/25/20.
//

import UIKit

class LaunchViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().tintColor = .label
        
        configureViewControllers()
    }
    
    fileprivate func configureViewControllers() {
        
        let featuredNewsController = UINavigationController(rootViewController: FeaturedNewsController())
        
        featuredNewsController.tabBarItem = UITabBarItem(tabBarSystemItem: .mostRecent, tag: 0)
        
        let viewController = UINavigationController(rootViewController: ViewController())
        
        viewController.title = "Browse By Category"
        
        viewController.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 1)
        
        let newsBrowserViewController = UINavigationController(rootViewController: NewsBrowserViewController())
        
        newsBrowserViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 2)
        
        viewControllers = [featuredNewsController,viewController, newsBrowserViewController]
        
        tabBarController?.selectedIndex = 0
        
    }
}
