//
//  FeaturedCell.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/28/20.
//

import UIKit
import SDWebImage

class FeaturedCell: UICollectionViewCell {
    
    fileprivate lazy var thumbnailImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "bloomberg")
        return imageView
    }()
    
    lazy var newsContent:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        
        label.font = UIFont.systemFont(ofSize: 18)
        return label
        
    }()
    
    var field: Everything.Articles? {
        didSet {
            self.newsContent.text = field?.description ?? field?.content ?? "Content Unavailable"
            
            guard let url = URL(string: field?.urlToImage ?? "") else { return }
            thumbnailImage.sd_setImage(with: url, completed: nil)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let contentStack = UIStackView(arrangedSubviews: [
            newsContent
        ])
        
        contentStack.axis = .vertical
        
       
       let stack = UIStackView(arrangedSubviews: [
        thumbnailImage, contentStack
       ])
        
        stack.spacing = 8
        
        addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        
        thumbnailImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
