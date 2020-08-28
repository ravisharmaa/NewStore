//
//  CategoriesHeader.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/25/20.
//

import UIKit

class CategoriesHeader: UICollectionReusableView {
    
    let label = UILabel()
    
    let borderLayer = CALayer()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        label.font = UIFont.boldSystemFont(ofSize: 20)
        
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        borderLayer.frame = .init(x: 20, y: frame.size.height - 5, width: frame.size.width - 50, height: 0.5)
        
        borderLayer.backgroundColor = UIColor.gray.cgColor
        
        layer.addSublayer(borderLayer)
    }
}
