//
//  GithubAPIManager.swift
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

import Foundation

// Constants
enum API {
    static let baseURL: String = "https://api.github.com"
    static let paramString: String = "?q=%@&sort=%@&order=%@"
    static let itemsPerPage: Int = 20
}


// Custom Error
enum FetchError: Error {
    case dataIsNil, invalidResponse, invalidJSON, incompleteResult, unknownError
}

// Custom Error description
extension FetchError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .dataIsNil:
            return "Data is NULL"
        case .invalidResponse:
            return "Invalid Response"
        case .invalidJSON:
            return "Invalid JSON"
        case .incompleteResult:
            return "Result is Incomplete"
        default:
            return "Unknown Error"
        }
    }
}

// classes for NSCache key-value
fileprivate class CacheKey {
    var key: String = ""
    
    init(_ key: String) {
        self.key = key
    }
}

fileprivate class CacheValue {
    var value: Data = Data()
    
    init(_ value: Data) {
        self.value = value
    }
}

// Singletone pattern
class GithubAPIManager {

    // MARK: -Enums for sort types
    enum SortType: Int {
        case byDefault, stars, forks, helpWanted
        
        func asString() -> String {
            switch self {
            case .helpWanted:
                return "help-wanted-issues"
            case .stars:
                return "stars"
            case .forks:
                return "forks"
            default:
                return ""
            }
        }
    }
    
    enum OrderType: String {
        case desc, asc
    }

    static let shared = GithubAPIManager(baseURL: API.baseURL)
    
    // MARK: -Properties
    var page: Int
    var baseURL: String
    private(set) var keyword: String = ""
    
    fileprivate var itemsPerPage: Int = API.itemsPerPage
    fileprivate var sort: SortType = .byDefault
    fileprivate var order: OrderType = .desc
    
    fileprivate var parameters: [String:String] {
        get {
            var dictionary: [String:String] = [:]
            dictionary.updateValue(self.keyword,                                   forKey: "q")
            dictionary.updateValue(self.sort.asString(),                           forKey: "sort")
            dictionary.updateValue(self.order.rawValue,                            forKey: "order")
            dictionary.updateValue(NSNumber(value: self.page).stringValue,         forKey: "page")
            dictionary.updateValue(NSNumber(value: self.itemsPerPage).stringValue, forKey: "per_page")
            
            return dictionary
        }
    }
    
    fileprivate let cache = NSCache<CacheKey, CacheValue>()
    
    // MARK: -Initialization
    private init(baseURL: String) {
        self.baseURL = baseURL
        self.page = 1
    }
    
    // MARK: -Methods
    // 1. Change type for completionHandler
    public func fetchRepositories(by keyword: String, sort: SortType = .stars, order: OrderType = .desc,
                    page: Int = 1, itemsPerPage: Int = API.itemsPerPage,
                    completionHandler: @escaping ( (Result<FetchedRepositoryResult, Error>) -> Void)) {
        self.page = page
        self.keyword = keyword
        self.itemsPerPage = itemsPerPage
        self.sort = sort
        self.order = order
        
        let urlString = "\(baseURL)/search/repositories"
        
        get(urlString, params: parameters) { ( result ) in
            switch result {
            case .success( let data ):
                do {
                    let fetchedResult = try JSONDecoder().decode(FetchedRepositoryResult.self, from: data)
                    completionHandler(.success(fetchedResult))
                } catch let decodeError {
                    completionHandler(.failure(decodeError))
                }
            case .failure( let error ):
                completionHandler(.failure(error))
            }
        }
    }
    
    public func fetchNextRepositories(itemsPerPage: Int = API.itemsPerPage,
                                      completionHandler: @escaping ( (Result<FetchedRepositoryResult, Error>) -> Void)) {
        self.page = self.page + 1
        self.itemsPerPage = itemsPerPage
        let urlString = "\(baseURL)/search/repositories"
        get(urlString, params: parameters) { ( result ) in
            switch result {
            case .success( let data ):
                do {
                    let fetchedResult = try JSONDecoder().decode(FetchedRepositoryResult.self, from: data)
                    completionHandler(.success(fetchedResult))
                } catch let decodeError {
                    completionHandler(.failure(decodeError))
                }
            case .failure( let error ):
                completionHandler(.failure(error))
            }
        }
    }
    
    // download image as data
    public func downloadImageAsData(at path: String,
                                    completionHandler: @escaping ( (Result<Data, Error>) -> Void)) {
        guard let url = URL(string: path) else {
            // error with url ?!?!?
            completionHandler(.failure(FetchError.unknownError))
            return
        }
        
        let cacheKey = CacheKey(path)
        if let imageData = cache.object(forKey: cacheKey)?.value {
             completionHandler(.success(imageData))
        } else {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    // standart error
                    completionHandler(.failure(error))
                    return
                }
                
                if let data = data {
                    // success
                    // 1. set cache
                    let cacheValue = CacheValue(data)
                    self.cache.setObject(cacheValue, forKey: cacheKey)
                    // 2. complete func
                    completionHandler(.success(data))
                    return
                }
                // unknown error
                completionHandler(.failure(FetchError.unknownError))
            }.resume()
        }
    }
    
    fileprivate func get(_ path: String, params: [String:String],
                         completionHandler: @escaping ( (Result<Data, Error>) -> Void) ) {
        
        // 1. Creating query URL
        var queryItems: [URLQueryItem] = []
        params.keys.forEach { ( key ) in
            let queryItem = URLQueryItem(name: key, value: params[key])
            queryItems.append( queryItem )
        }
        var components = URLComponents(string: path)
        components?.queryItems = queryItems
        guard let url = components?.url else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // 2. Check for data is not nil
            guard let data = data else {
                completionHandler(.failure(FetchError.dataIsNil))
                return
            }

            // 3. Check that response exists and equal 200
            if let httpResponse = response as? HTTPURLResponse {
                if ( httpResponse.statusCode != 200 ) {
                    completionHandler(.failure(FetchError.invalidResponse))
                    return
                }
            } else {
                completionHandler(.failure(FetchError.invalidResponse))
                return
            }
            
            // 4. Check for standart errors
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            
            // 5. Success
            completionHandler(.success(data))
        }.resume()
    }
}
