//
//  SecondViewController.swift
//  TinkoffLab
//
//  Created by Roman Tverdokhleb on 03.02.2023.
//

import UIKit
import Network

class SecondViewController: UIViewController {
    
    var url: String
    var imageURL: String
    var titleText: String
    var textContent: String
    var author: String
    var date: String
    
    init(url: String, imageURL: String, titleText: String, textContent: String, author: String, date: String) {
        self.url = url
        self.imageURL = imageURL
        self.titleText = titleText
        self.textContent = textContent
        self.author = author
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imageCache = NSCache<NSString, UIImage>()
    
    private let articleTitle: UILabel = {
        let title = UILabel()
        title.text = "Need to be titled"
        title.numberOfLines = 0
        title.textAlignment = .center
        title.font = .systemFont(ofSize: 22, weight: .semibold)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private let authorTitle: UILabel = {
        let author = UILabel()
        author.text = "Where is the author?"
        author.textColor = .gray
        author.numberOfLines = 0
        author.textAlignment = .left
        author.font = .systemFont(ofSize: 15, weight: .light)
        author.translatesAutoresizingMaskIntoConstraints = false
        return author
    }()
    
    private let articleDate: UILabel = {
        let date = UILabel()
        date.textColor = .gray
        date.text = "01.01.2023"
        date.numberOfLines = 0
        date.textAlignment = .right
        date.font = .systemFont(ofSize: 15, weight: .light)
        date.translatesAutoresizingMaskIntoConstraints = false
        return date
    }()
    
    private let articleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGroupedBackground
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let articleText: UILabel = {
        let contentText = UILabel()
        contentText.text = "Must be described"
        contentText.numberOfLines = 0
        contentText.textAlignment = .natural
        contentText.font = .systemFont(ofSize: 18, weight: .regular)
        contentText.translatesAutoresizingMaskIntoConstraints = false
        return contentText
    }()
    
    private let buttonMore: UIButton = {
        let button = UIButton()
        button.setTitle("Open full article", for: .normal)
        button.backgroundColor = .systemRed
        button.addTarget(nil, action: #selector(buttonClicked(sender: )), for: .touchUpInside)
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let noConnectionLabel: UILabel = {
        let label = UILabel()
        label.text = "No connection"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Article"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
        
        view.addSubview(articleTitle)
        view.addSubview(authorTitle)
        view.addSubview(articleDate)
        view.addSubview(articleImage)
        view.addSubview(articleText)
        view.addSubview(buttonMore)
        
        articleTitleSetup()
        authorTitleSetup()
        articleDateSetup()
        articleImageSetup()
        articleTextSetup()
        buttonSetup()
        
        internetCheck()
        
    }
    
    private func articleTitleSetup() {
        NSLayoutConstraint.activate([
            articleTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            articleTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            articleTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height/9)
        ])
        articleTitle.text = titleText
    }
    
    private func authorTitleSetup() {
        NSLayoutConstraint.activate([
            authorTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            authorTitle.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -20),
            authorTitle.topAnchor.constraint(equalTo: articleTitle.bottomAnchor, constant: 10)
        ])
        authorTitle.text = author
    }
    
    private func articleDateSetup() {
        NSLayoutConstraint.activate([
            articleDate.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            articleDate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            articleDate.topAnchor.constraint(equalTo: articleTitle.bottomAnchor, constant: 10)
        ])
        articleDate.text = dateConvert(date: date)
    }
    
    private func articleImageSetup() {
        NSLayoutConstraint.activate([
            articleImage.topAnchor.constraint(equalTo: articleDate.bottomAnchor, constant: 20),
            articleImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            articleImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            articleImage.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        let url = (URL(string: imageURL) ?? URL(string: "https://cdn.nerdschalk.com/wp-content/uploads/2021/10/unsupported-logo-759x427.png?width=800"))!
        
        downloadImage(url: url) { image in
            self.articleImage.image = image
        }
    }
    
    private func articleTextSetup() {
        NSLayoutConstraint.activate([
            articleText.topAnchor.constraint(equalTo: articleImage.bottomAnchor, constant: 20),
            articleText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            articleText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        articleText.text = textContent
    }
    
    private func buttonSetup() {
        NSLayoutConstraint.activate([
            buttonMore.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonMore.topAnchor.constraint(equalTo: articleText.bottomAnchor, constant: 20),
            buttonMore.widthAnchor.constraint(equalToConstant: 150),
            buttonMore.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func dateConvert(date: String) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let date = dateFormatter.date(from: date)!
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let finalDate = calendar.date(from:components)!
        
        dateFormatter.dateFormat = "HH:mm  dd.MM.yyyy"
        
        let stringDate = dateFormatter.string(from: finalDate)
        return stringDate
    }
    
    private func internetCheck() {
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.noConnectionLabel.isHidden = true
                    self.buttonMore.isEnabled = true
                }
            } else {
                DispatchQueue.main.async {
                    self.noConnectionLabel.isHidden = false
                    self.buttonMore.isEnabled = false
                    self.buttonMore.backgroundColor = .systemGray3
                }
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    @objc func buttonClicked(sender: UIButton) {
        let vc = WebKitPage(url: url)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
            
        } else {
            
            let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 10)
            
            let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                
                guard error == nil,
                      data != nil,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else { return }
                
                guard let image = UIImage(data: data!) else { return }
                self?.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            dataTask.resume()
        }
    }
}
