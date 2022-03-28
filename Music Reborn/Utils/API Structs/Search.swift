//
//  Search.swift
//  Music Reborn
//
//  Created by llsc12 on 28/03/2022.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let data = try? newJSONDecoder().decode(Videos.self, from: jsonData)

import Foundation

// MARK: - Video
struct Video: Codable {
    let type: TypeEnum
    let title, videoID, author, authorID: String
    let authorURL: String
    let videoThumbnails: [VideoThumbnail]
    let welcomeDescription, descriptionHTML: String
    let viewCount, published: Int
    let publishedText: String
    let lengthSeconds: Int
    let liveNow, premium, isUpcoming: Bool

    enum CodingKeys: String, CodingKey {
        case type, title
        case videoID = "videoId"
        case author
        case authorID = "authorId"
        case authorURL = "authorUrl"
        case videoThumbnails
        case welcomeDescription = "description"
        case descriptionHTML = "descriptionHtml"
        case viewCount, published, publishedText, lengthSeconds, liveNow, premium, isUpcoming
    }
}

enum TypeEnum: String, Codable {
    case video = "video"
}

// MARK: - VideoThumbnail
struct VideoThumbnail: Codable {
    let quality: Quality
    let url: String
    let width, height: Int
}

enum Quality: String, Codable {
    case end = "end"
    case high = "high"
    case maxres = "maxres"
    case maxresdefault = "maxresdefault"
    case medium = "medium"
    case middle = "middle"
    case qualityDefault = "default"
    case sddefault = "sddefault"
    case start = "start"
}

typealias Videos = [Video]

