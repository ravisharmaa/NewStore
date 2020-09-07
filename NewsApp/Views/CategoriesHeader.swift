//
//  CategoriesHeader.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/25/20.
//

import UIKit
import Combine

class CategoriesHeader: UICollectionReusableView {
    
    let label = UILabel()
    
    let borderLayer = CALayer()
    
    let seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See All", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleSeeAll), for: .touchUpInside)
        return button
    }()
    
    var seeAllClickHandler: (()-> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        let stackView = UIStackView(arrangedSubviews: [
            label, seeAllButton
        ])
        
        label.font = UIFont.boldSystemFont(ofSize: 20)
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.isLayoutMarginsRelativeArrangement = true
        
        stackView.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 25)
        
        stackView.axis = .horizontal
        
        stackView.alignment = .fill
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
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
    
   
    @objc func handleSeeAll() {
        seeAllClickHandler?()
    }
}
