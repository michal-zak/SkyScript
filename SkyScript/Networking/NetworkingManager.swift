//
//  NetworkingManager.swift
//  SkyScript
//
//  Created by michal-zak on 1/19/26.
//

import Foundation
import Combine

class NetworkManager {
    
    // פונקציה גנרית לביצוע קריאות רשת ופענוח JSON
    func fetch<T: Decodable>(url: URL) -> AnyPublisher<T, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
