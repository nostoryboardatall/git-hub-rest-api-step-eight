//
//  Repository.swift
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

public struct Repository : Decodable {
    public let id : Int?
    public let nodeId : String?
    public let owner : Owner?
    public let name : String?
    public let fullName : String?
    public let descriptionField : String?
    public let createdAt : String?
    public let pushedAt : String?
    public let updatedAt : String?
    public let url : String?
    public let downloadsUrl : String?
    public let treesUrl : String?
    public let score : Float?
    public let stargazersCount : Int?
    public let watchersCount : Int?
    public let forksCount : Int?
    public let size : Int?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case nodeId = "node_id"
        case owner = "owner"
        case name = "name"
        case fullName = "full_name"
        case descriptionField = "description"
        case createdAt = "created_at"
        case pushedAt = "pushed_at"
        case updatedAt = "updated_at"
        case url = "url"
        case downloadsUrl = "downloads_url"
        case treesUrl = "trees_url"
        case score = "score"
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case size = "size"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        nodeId = try values.decodeIfPresent(String.self, forKey: .nodeId)
        owner = try values.decodeIfPresent(Owner.self, forKey: .owner)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        fullName = try values.decodeIfPresent(String.self, forKey: .fullName)
        descriptionField = try values.decodeIfPresent(String.self, forKey: .descriptionField)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        pushedAt = try values.decodeIfPresent(String.self, forKey: .pushedAt)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        downloadsUrl = try values.decodeIfPresent(String.self, forKey: .downloadsUrl)
        treesUrl = try values.decodeIfPresent(String.self, forKey: .treesUrl)
        score = try values.decodeIfPresent(Float.self, forKey: .score)
        stargazersCount = try values.decodeIfPresent(Int.self, forKey: .stargazersCount)
        watchersCount = try values.decodeIfPresent(Int.self, forKey: .watchersCount)
        forksCount = try values.decodeIfPresent(Int.self, forKey: .forksCount)
        size = try values.decodeIfPresent(Int.self, forKey: .size)
    }
}
