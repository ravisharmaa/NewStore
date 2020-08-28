//
//  NewsDetailViewController.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/27/20.
//

import UIKit
import Combine

class NewsDetailViewController: UIViewController {
    
    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    fileprivate lazy var newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
    
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    fileprivate lazy var authorLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    
    let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let item: Everything.Articles
    
    var subscription: AnyCancellable!
    
    init(item: Everything.Articles) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.backgroundColor = .systemBackground
        
        let titleAndContentStackView = UIStackView(arrangedSubviews: [
            titleLabel, contentLabel, authorLabel
        ])
        
        titleAndContentStackView.axis = .vertical
        
        titleAndContentStackView.spacing = 15
        
        titleAndContentStackView.isLayoutMarginsRelativeArrangement = true
        
        titleAndContentStackView.layoutMargins = .init(top: 0, left: 10, bottom: 0, right: 10)
        
        
        let stack = UIStackView(arrangedSubviews: [
            newsImageView, titleAndContentStackView , UIView(),UIView()
        ])
        
        view.addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.axis = .vertical
        
        stack.spacing = 10
        
        
        newsImageView.heightAnchor.constraint(equalTo: stack.heightAnchor, multiplier: 1/2).isActive = true
        
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        
        titleLabel.text = item.title
        
        contentLabel.text = item.content
        
        authorLabel.text = "Authored By: \(item.author ?? "Unknown")" 
        
        if let url = URL(string: item.urlToImage ?? "" ) {
            subscription = URLSession.shared.dataTaskPublisher(for: url).map({UIImage(data: $0.data)})
                .receive(on: RunLoop.main)
                .replaceError(with: UIImage(named: "bloomberg"))
                .assign(to: \.image, on: newsImageView)
            
        }
        
      
       
    }
    

}
