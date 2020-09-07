//
//  BusinessCell.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/28/20.
//

import UIKit
import SDWebImage


class BusinessCell: UICollectionViewCell {
    
    fileprivate lazy var headingLabel: UILabel = {
        let label = CustomLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 19)
        return label
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = CustomLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "bloomberg")
        return imageView
    }()
    
    
    fileprivate lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var field: Everything.Articles? {
        didSet {
            self.downloadImage(from: field!.urlToImage ?? "")
            self.headingLabel.text = field!.title
            self.titleLabel.text = field!.source?.name ?? "Unknown"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stackView = UIStackView(arrangedSubviews: [
            headingLabel, titleLabel, imageView
        ])
        
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        
        stackView.setCustomSpacing(8, after: headingLabel)
        stackView.setCustomSpacing(8, after: titleLabel)
        
        imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/1.28).isActive = true
        
        imageView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor)
        ])
    }
    
    fileprivate func downloadImage(from urlString: String) {
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        activityIndicator.startAnimating()
        imageView.sd_setImage(with: url) { (_, _, _, _) in
            self.activityIndicator.stopAnimating()
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}


class CustomLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 16, dy: 0))
    }
}
