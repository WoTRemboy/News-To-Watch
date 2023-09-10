//
//  TableViewCell.swift
//  TinkoffLab
//
//  Created by Roman Tverdokhleb on 03.02.2023.
//

import UIKit
import Network

class TableViewCellModel: NSObject, NSCoding {
    
    let title: String
    let subtitle: String
    let imageURL: URL?
    var imageData: Data?
    
    init(title: String, subtitle: String, imageURL: URL?, imageData: Data? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(title, forKey: "title")
        coder.encode(subtitle, forKey: "subtitle")
        coder.encode(imageURL, forKey: "imageURL")
    }
    
    required init?(coder: NSCoder) {
        title = coder.decodeObject(forKey: "title") as? String ?? ""
        subtitle = coder.decodeObject(forKey: "subtitle") as? String ?? ""
        
        imageURL = coder.decodeObject(forKey: "imageURL") as? URL ?? URL(string: "https://cdn.nerdschalk.com/wp-content/uploads/2021/10/unsupported-logo-759x427.png?width=800")!
    }
}

class TableViewCell: UITableViewCell {
    static let identifier = "TableViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.text = "Counter is here"
        label.textColor = .gray
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(newsImageView)
        contentView.addSubview(counterLabel)
        contentView.addSubview(titleLabel)
        
        titleLabelSetup()
        counterLabelSetup()
        newsImageViewSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func titleLabelSetup() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -190)
        ])
    }
    
    private func counterLabelSetup() {
        NSLayoutConstraint.activate([
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            counterLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            counterLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -190)
        ])
    }
    
    private func newsImageViewSetup() {
        NSLayoutConstraint.activate([
            newsImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            newsImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            newsImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 20),
            newsImageView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        counterLabel.text = nil
        newsImageView.image = nil
    }
    
    func configure(with viewModel: TableViewCellModel, counter: Int) {
        
        var imageToLoad = true
        
        let monitor = NWPathMonitor()
        let userObject = TableViewCellModel(title: viewModel.title, subtitle: viewModel.subtitle, imageURL: viewModel.imageURL)
        
        UserSettings.userModel = userObject
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.titleLabel.text = viewModel.title
                }
            } else {
                DispatchQueue.main.async {
                    self.titleLabel.text = UserSettings.userModel.title
                }
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        
        counterLabel.text = "Clicks count: \(counter)"
        
        if imageToLoad {
            if let data = viewModel.imageData {
                newsImageView.image = UIImage(data: data)
            }
            else if let url = viewModel.imageURL {
                URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    viewModel.imageData = data
                    DispatchQueue.main.async {
                        if self?.newsImageView.image != UIImage(data: data) {
                            self?.newsImageView.image = UIImage(data: data)

                        }
                    }
                } .resume()
            }
            imageToLoad = false
        }
    }
}
