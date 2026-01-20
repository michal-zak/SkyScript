//
//  APOModels.swift
//  SkyScript
//
//  Created by user945522 on 1/19/26.
//

import Foundation

// MARK: - NASA APOD Model
struct NasaModel: Codable {
    let title: String
    let date: String
    let explanation: String
    let url: URL
    let hdurl: URL?
    let mediaType: String
    let copyright: String?
    
    enum CodingKeys: String, CodingKey {
        case title, date, explanation, url, hdurl, copyright
        case mediaType = "media_type"
    }
}

// MARK: - Horoscope Model
struct HoroscopeModel: Codable {
    let status: Int
    let success: Bool
    let data: HoroscopeData
}

struct HoroscopeData: Codable {
    let date: String
    let horoscope_data: String
}

// MARK: - App Internal Model
// זה המודל המעובד שה-ViewModel חושף ל-View
struct DailyDashboardData {
    let imageTitle: String
    let imageUrl: URL
    let horoscopeText: String
}
