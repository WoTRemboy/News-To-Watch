//
//  APICaller.swift
//  TinkoffLab
//
//  Created by Roman Tverdokhleb on 03.02.2023.
//

import Foundation

final class APICaller {
    static let called = APICaller()
    
    private func urlIs(pageNumber: Int) -> URL? {
        return URL(string: "https://newsapi.org/v2/everything?q=apple&sortBy=popularity&pageSize=20&page=\(pageNumber)&apiKey=070d0d1bb86a4e6b9c8411219e07835a")
        
// Reserve URLs with another APIKeys
//   "https://newsapi.org/v2/everything?q=apple&sortBy=popularity&pageSize=20&page=\(pageNumber)&apiKey=d3efa0f55da348b9ab760dd24292560a"
//        "https://newsapi.org/v2/everything?q=apple&sortBy=popularity&pageSize=20&page=\(pageNumber)&apiKey=123bf8680484428e94a06802b8b04f09"
//   "https://newsapi.org/v2/everything?q=apple&sortBy=popularity&pageSize=20&page=\(pageNumber)&apiKey=621d67f11a1347f5883f811ddd19a269"
    }
    
    var isPaginating = false
    var page = 1
    
    private init() {}
    
    public func getFirstLines(pagination: Bool = false, completion: @escaping(Result<[Article], Error>) -> Void) {
        
        page = 1
        
        guard let url = urlIs(pageNumber: page) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                
                    completion(.success(result.articles))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    public func fetchNews(pagination: Bool = false, completion: @escaping(Result<[Article], Error>) -> Void) {
        
        isPaginating = true
        page += 1
        
        guard let url = urlIs(pageNumber: page) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    
                    completion(.success(result.articles))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(4)) {
            self.isPaginating = false
        }
        
    }
}

// Working with models

struct APIResponse: Codable {
    let articles: [Article]
}

struct Article: Codable {
    let source: Source
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String
    let author: String?
    var clickCounter: Int?
}

struct Source: Codable {
    let name: String
}
