//
//  DetailController.swift
//
//  Created by Home on 2019.
//  Copyright 2017-2018 NoStoryboardsAtAll Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

let kImageViewSize: CGFloat = 144.0

class DetailController: UIViewController {
    public var repository: Repository! {
        didSet {
            authorNameLabel.text = repository.owner?.login ?? ""
            authorNameLabel.sizeToFit()
            repositoryNameLabel.text = repository.name ?? ""
            repositoryNameLabel.sizeToFit()
            repositoryDescriptionLabel.text = repository.descriptionField ?? ""
            repositoryDescriptionLabel.sizeToFit()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            
            if let date = dateFormatter.date(from: repository.createdAt ?? "") {
                dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
                repositoryCreatedAtLabel.text = "created At: \(dateFormatter.string(from: date))"
            } else {
                repositoryCreatedAtLabel.text = "created At: <<Unknown>>"
            }
            repositoryCreatedAtLabel.sizeToFit()
        }
    }
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 18.0
        
        return stack
    }()

    private let authorStackView: UIStackView = {
        let stack = UIStackView()
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 12.0
        
        return stack
    }()

    private let authorNameStackView: UIStackView = {
        let stack = UIStackView()
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = UIStackView.Alignment.leading
        stack.distribution = .fill
        stack.spacing = 4.0
        
        return stack
    }()

    private let repositoryStackView: UIStackView = {
        let stack = UIStackView()
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 12.0
        
        return stack
    }()
    
    private let authorAvatar: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.image = UIImage(named: "user")
        
        return imageView
    }()

    private let authorNameLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 27.0)
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()

    private let repositoryNameLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 23.0)
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()

    private let repositoryDescriptionLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()

    private let repositoryCreatedAtLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 11.0)
        label.textAlignment = .right
        
        return label
    }()

    private let activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView()
        
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.style = .white
        
        return activityView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func loadView() {
        super.loadView()
        prepareView()
    }
    
    // calculate the scrollview height
    override func viewDidLayoutSubviews() {
        scrollView.contentSize.height = mainStackView.frame.height
        super.viewDidLayoutSubviews()
    }
    
    fileprivate func setupView() {
        view.backgroundColor = .white
        
        // Setup the navigation bar
        navigationItem.title = repository.fullName
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // start download the author avatar
        guard let avatarUrl = repository.owner?.avatarUrl else {
            return
        }
        activityView.startAnimating()
        GithubAPIManager.shared.downloadImageAsData(at: avatarUrl) { ( result ) in
            switch result {
            case .failure( let error ):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.activityView.stopAnimating()
                }
            case .success( let imageAsData ):
                DispatchQueue.main.async {
                    self.authorAvatar.image = UIImage(data: imageAsData)
                    self.activityView.stopAnimating()
                }
            }
        }
    }
    
    fileprivate func prepareView() {
        authorNameStackView.addArrangedSubview(authorNameLabel)
        
        authorStackView.addArrangedSubview(authorAvatar)
        authorStackView.addArrangedSubview(authorNameStackView)
        
        repositoryStackView.addArrangedSubview(repositoryNameLabel)
        repositoryStackView.addArrangedSubview(repositoryDescriptionLabel)
        repositoryStackView.addArrangedSubview(repositoryCreatedAtLabel)
        
        // add some space to the top )))
        mainStackView.addArrangedSubview( UIView() )
        mainStackView.addArrangedSubview(authorStackView)
        mainStackView.addArrangedSubview(repositoryStackView)
        
        scrollView.addSubview(mainStackView)
        scrollView.addSubview(activityView)
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor),

            authorAvatar.widthAnchor.constraint(equalToConstant: kImageViewSize),
            authorAvatar.heightAnchor.constraint(equalToConstant: kImageViewSize),
            
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            
            repositoryCreatedAtLabel.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            repositoryCreatedAtLabel.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            
            activityView.centerXAnchor.constraint(equalTo: authorAvatar.centerXAnchor),
            activityView.centerYAnchor.constraint(equalTo: authorAvatar.centerYAnchor)
        ])
    }
}
