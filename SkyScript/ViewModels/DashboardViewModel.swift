//
//  DashboardViewModel.swift
//  SkyScript
//
//  Created by user945522 on 1/19/26.
//

import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    
    // Inputs
    @Published var selectedDate: Date = Date()
    @Published var selectedSign: String = "aries"
    
    // Outputs
    @Published var dailyData: DailyDashboardData?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let networkManager = NetworkManager()
    
    init() {
        setupPipeline()
    }
    
    private func setupPipeline() {
            // שלב 1: הגדרת הקלט (Input) בנפרד
            // אנחנו מגדירים את הטיפוסים בתוך ה-removeDuplicates באופן מפורש כדי לעזור לקומפיילר
            let inputPublisher = Publishers.CombineLatest($selectedDate, $selectedSign)
                .removeDuplicates { (prev: (Date, String), curr: (Date, String)) -> Bool in
                    return prev.0 == curr.0 && prev.1 == curr.1
                }
                .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
                .eraseToAnyPublisher() // הופך את הטיפוס למשהו פשוט יותר להמשך הדרך

            // שלב 2: שרשור לוגיקת הטעינה
            inputPublisher
                .handleEvents(receiveOutput: { [weak self] _ in
                    self?.isLoading = true
                    self?.errorMessage = nil
                })
                .map { [weak self] (date, sign) -> AnyPublisher<DailyDashboardData?, Never> in
                    // שימוש ב-createDataPublisher שיצרנו קודם
                    guard let self = self else { return Just(nil).eraseToAnyPublisher() }
                    return self.createDataPublisher(date: date, sign: sign)
                }
                .switchToLatest() // לוקח את ה-Publisher החדש ביותר
                .receive(on: DispatchQueue.main)
                .sink { [weak self] data in
                    self?.isLoading = false
                    if let validData = data {
                        self?.dailyData = validData
                    }
                }
                .store(in: &cancellables)
        }
    
    // --- פונקציית עזר חדשה: מקלה על הקומפיילר ומכילה את לוגיקת הרשת והשגיאות ---
    private func createDataPublisher(date: Date, sign: String) -> AnyPublisher<DailyDashboardData?, Never> {
        return self.fetchData(date: date, sign: sign)
            .map { (nasa, horoscope) -> DailyDashboardData? in
                return DailyDashboardData(
                    imageTitle: nasa.title,
                    imageUrl: nasa.url,
                    horoscopeText: horoscope.data.horoscope_data
                )
            }
            .catch { [weak self] error -> Just<DailyDashboardData?> in
                print("Error inside stream: \(error)")
                DispatchQueue.main.async {
                    self?.errorMessage = "תקלה בטעינת הנתונים: \(error.localizedDescription)"
                }
                return Just(nil)
            }
            .eraseToAnyPublisher()
    }
    
    // פונקציית הרשת המקורית (נשארה אותו דבר)
    private func fetchData(date: Date, sign: String) -> AnyPublisher<(NasaModel, HoroscopeModel), Error> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        // וודאי ששמת כאן את המפתח האמיתי שלך מנאס"א!
        let nasaURLString = "https://api.nasa.gov/planetary/apod?api_key=FWAbie1UNQvKSMONtaSuCukQmZcneTG8nsKYuSbw&date=\(dateString)"
        let horoscopeURLString = "https://horoscope-app-api.vercel.app/api/v1/get-horoscope/daily?sign=\(sign)&day=today"
        
        guard let nasaURL = URL(string: nasaURLString),
              let horoscopeURL = URL(string: horoscopeURLString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return Publishers.Zip(
            networkManager.fetch(url: nasaURL) as AnyPublisher<NasaModel, Error>,
            networkManager.fetch(url: horoscopeURL) as AnyPublisher<HoroscopeModel, Error>
        )
        .eraseToAnyPublisher()
    }
}
