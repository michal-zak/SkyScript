//
//  Dashboardview.swift
//  SkyScript
//
//  Created by michal-zak on 1/19/26.
//

import SwiftUI

struct DashboardView: View {
    
    @StateObject private var viewModel = DashboardViewModel()
    
    // מיפוי שמות המזלות לעברית
    let zodiacMap: [(key: String, name: String)] = [
        ("aries", "טלה ♈️"),
        ("taurus", "שור ♉️"),
        ("gemini", "תאומים ♊️"),
        ("cancer", "סרטן ♋️"),
        ("leo", "אריה ♌️"),
        ("virgo", "בתולה ♍️"),
        ("libra", "מאזניים ♎️"),
        ("scorpio", "עקרב ♏️"),
        ("sagittarius", "קשת ♐️"),
        ("capricorn", "גדי ♑️"),
        ("aquarius", "דלי ♒️"),
        ("pisces", "דגים ♓️")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // רקע
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // --- Header Section ---
                        VStack(spacing: 15) {
                            Text("SkyScript")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            // בחירת תאריך (הפיצ'ר החדש!)
                            HStack {
                                Text("תאריך:")
                                    .foregroundColor(.gray)
                                Spacer()
                                DatePicker(
                                    "",
                                    selection: $viewModel.selectedDate,
                                    in: ...Date(), // חוסם בחירה של תאריכים עתידיים
                                    displayedComponents: .date
                                )
                                .labelsHidden()
                                .colorScheme(.dark) // טקסט לבן בפיקר
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)

                            // בחירת מזל
                            Menu {
                                Picker("Select Sign", selection: $viewModel.selectedSign) {
                                    ForEach(zodiacMap, id: \.key) { sign in
                                        Text(sign.name).tag(sign.key)
                                    }
                                }
                            } label: {
                                HStack {
                                    Spacer()
                                    Text(zodiacMap.first(where: { $0.key == viewModel.selectedSign })?.name ?? "בחר מזל")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.purple)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        
                        // --- Content Section ---
                        if viewModel.isLoading {
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                                    .scaleEffect(1.5)
                                Text("מיישר כוכבים...")
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.top, 12)
                            }
                            .padding(.top, 50)
                            
                        } else if let data = viewModel.dailyData {
                            contentCard(data: data)
                                .transition(.opacity.combined(with: .move(edge: .bottom))) // אנימציה קטנה ונעימה
                        } else {
                            // מצב התחלתי או שגיאה
                            VStack {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("בחר תאריך ומזל כדי לגלות את העתיד (או העבר)")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                            .padding(.top, 30)
                        }
                    }
                }
            }
            .environment(\.layoutDirection, .rightToLeft) // תמיכה בעברית לכל המסך
            .navigationBarHidden(true)
            .alert(item: Binding<AlertItem?>(
                get: { viewModel.errorMessage.map { AlertItem(message: $0) } },
                set: { _ in viewModel.errorMessage = nil }
            )) { item in
                Alert(
                    title: Text("תקלה קוסמית"),
                    message: Text(item.message),
                    dismissButton: .default(Text("אישור"))
                )
            }
        }
        // ה-onAppear הוסר, כי ה-ViewModel מאזין לערכים ההתחלתיים אוטומטית ב-init
    }
    
    // --- רכיב כרטיס המידע ---
    @ViewBuilder
    private func contentCard(data: DailyDashboardData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // תמונת היום
            AsyncImage(url: data.imageUrl) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Rectangle().fill(Color.gray.opacity(0.2))
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                case .failure:
                    ZStack {
                        Rectangle().fill(Color.gray.opacity(0.2))
                        Image(systemName: "photo.fill")
                            .foregroundColor(.gray)
                    }
                @unknown default: EmptyView()
                }
            }
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            
            Text(data.imageTitle)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Divider().background(Color.white.opacity(0.5))
            
            // כותרת הורוסקופ
            Text("תחזית יומית")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0)) // סגול בהיר
            
            // טקסט ההורוסקופ
            Text(data.horoscopeText)
                .font(.body)
                .foregroundColor(.white.opacity(0.95))
                .lineSpacing(6) // מרווח שורות לקריאות טובה
                .environment(\.layoutDirection, .leftToRight) // אנגלית משמאל לימין
                .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .padding()
        .background(Color(red: 0.12, green: 0.12, blue: 0.18))
        .cornerRadius(20)
        .padding(.horizontal)
        .shadow(color: .purple.opacity(0.25), radius: 15, x: 0, y: 10)
    }
}

// Helper struct for alerts
struct AlertItem: Identifiable {
    var id = UUID()
    var message: String
}
