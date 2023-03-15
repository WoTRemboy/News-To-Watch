//
//  ViewController.swift
//  TinkoffLab
//
//  Created by Roman Tverdokhleb on 03.02.2023.
//

import UIKit
import WebKit
import Network

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifier)
        return table
    }()
    
    private var articles = [Article]()
    private var viewModels = [TableViewCellModel]()
    let userDefaults = UserDefaults.standard
    
    private let noConnectionLabel: UILabel = {
        let label = UILabel()
        label.text = "No connection"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let updateButton: UIButton = {
        let button = UIButton()
        button.setTitle("Update", for: .normal)
        button.backgroundColor = .systemRed
        button.addTarget(self, action: #selector(buttonClicked(sender: )), for: .touchUpInside)
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshAction(sender: )), for: .allEvents)
        return refresh
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News"
        
        view.addSubview(tableView)
        view.addSubview(noConnectionLabel)
        view.addSubview(updateButton)
        
        self.noConnectionLabel.isHidden = true
        self.updateButton.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = .systemBackground
        tableView.refreshControl = refreshControl
        
        noConnectionLabelSetup()
        updateButtonSetup()
    
        firstLines()
        internetCheck()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func noConnectionLabelSetup() {
        noConnectionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noConnectionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20).isActive = true
    }
    
    private func updateButtonSetup() {
        updateButton.topAnchor.constraint(equalTo: noConnectionLabel.topAnchor, constant: 40).isActive = true
        updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        updateButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        updateButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func internetCheck() {
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.tableView.isHidden = false
                    self.noConnectionLabel.isHidden = true
                    self.updateButton.isHidden = true
                }
            } else {
                DispatchQueue.main.async {
                    self.tableView.isHidden = true
                    self.noConnectionLabel.isHidden = false
                    self.updateButton.isHidden = false
                }
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    @objc func buttonClicked(sender: UIButton) {
        firstLines()
        internetCheck()
        
        self.tableView.reloadData()
        tableView.isHidden = false
    }
    
    @objc private func refreshAction(sender: UIRefreshControl) {
        DispatchQueue.main.async {
            self.firstLines()
            self.internetCheck()
            self.tableView.reloadData()
            
            sender.endRefreshing()
        }
    }
    
    private func firstLines() {
        APICaller.called.getFirstLines { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    TableViewCellModel(title: $0.title, subtitle: $0.description ?? "No description", imageURL: URL(string: $0.urlToImage ?? ""))
                })
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(_):
                return
            }
        }
    }
    
    private func fetchNews() {
        APICaller.called.fetchNews(pagination: true) { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles.append(contentsOf: articles)
                self?.viewModels += articles.compactMap({
                    TableViewCellModel(title: $0.title, subtitle: $0.description ?? "No description", imageURL: URL(string: $0.urlToImage ?? ""))
                })
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(_):
                return
            }
            if (self?.clickCounter.count)! <= (self?.viewModels.count)! {
                for _ in 0..<20 {
                    self?.clickCounter.append(0)
                }
            }
        }
    }
    
    // Working with table
    var clickCounter = [Int]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let modelsCount = viewModels.count
        
        if clickCounter.isEmpty {
            for _ in 0..<100 {
                clickCounter.append(0)
            }
        }
        clickCounter = userDefaults.object(forKey: "counter") as? [Int] ?? clickCounter
        return modelsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier, for: indexPath) as? TableViewCell else {
            fatalError()
        }
        
        cell.configure(with: viewModels[indexPath.row], counter: clickCounter[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = articles[indexPath.row]
        
        guard let url = article.url else {
            return
        }
        
        clickCounter[indexPath.row] += 1
        userDefaults.set(clickCounter, forKey: "counter")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.reloadData()
        }
     
        let vc = SecondViewController(url: url, imageURL: article.urlToImage ?? "", titleText: article.title, textContent: article.description ?? "No description", author: article.author ?? "No author", date: article.publishedAt)
        
        navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        
        if position > (tableView.contentSize.height-scrollView.frame.size.height) {
            guard !APICaller.called.isPaginating else {
                return
            }
            
            fetchNews()
        }
    }

}
