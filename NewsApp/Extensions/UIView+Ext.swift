//
//  UIView+Ext.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/31/20.
//

import UIKit


extension UIView {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
