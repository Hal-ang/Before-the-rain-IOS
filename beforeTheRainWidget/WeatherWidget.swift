//
//  WeatherWidget.swift
//  beforeTheRain
//
//  Created by 정하랑 on 3/14/24.
//

// import Foundation

import WidgetKit
import SwiftUI
import Intents

struct WeatherProvider: TimelineProvider {
    static var sampleClothes: [Clothes] {
        return [
            Clothes(id: 22, name: "니트"),
            Clothes(id: 31, name: "울코트"),
            Clothes(id: 32, name: "가죽 재킷"),
            Clothes(id: 33, name: "스카프"),
            Clothes(id: 34, name: "두꺼운 바지"),
            Clothes(id: 35, name: "가죽 옷"),
            Clothes(id: 36, name: "히트텍"),
            Clothes(id: 37, name: "캐시미어 코트"),
            Clothes(id: 38, name: "플리스 재킷"),
            Clothes(id: 39, name: "경량패딩"),
            Clothes(id: 40, name: "목폴라")
        ]
    }
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), temperature: 0.0, weatherDescription: "맑음", pop: 0.0, clothes: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ()) {
        let entry = WeatherEntry(date: Date(), temperature: 7.73, weatherDescription: "맑음", pop: 0.0, clothes: WeatherProvider.sampleClothes)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> ()) {
        var entries: [WeatherEntry] = []
        
        // 현재 시간으로부터 한 시간 간격으로 데이터를 갱신합니다.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = WeatherEntry(date: entryDate, temperature: 7.73, weatherDescription: "맑음", pop: 0.0, clothes: WeatherProvider.sampleClothes)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}


struct WeatherEntry: TimelineEntry {
    let date: Date
    let temperature: Double
    let weatherDescription: String
    let pop: Double // 강수 확률
    let clothes: [Clothes]
}

struct Clothes: Identifiable {
    let id: Int
    let name: String
}

// 데이터 모델에 해당하는 부분입니다.
struct WeatherModel {
    let dt: Int
    let temp: Double
    let weather: [WeatherDetail]
    let pop: Double
    let clothes: [Clothes]
}

struct WeatherDetail {
    let id: Int
    let main: String
    let description: String
    let icon: String
}
struct WeatherWidgetEntryView : View {
    var entry: WeatherEntry

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "cloud")
                        .foregroundColor(.white)
                    Text("\(Int(entry.temperature))°")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }

                Text("강수 확률 \(Int(entry.pop * 100))%")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                VStack {
                    HStack(spacing: 8) {
                        ForEach(Array(entry.clothes.prefix(5)), id: \.id) { clothes in
                            Text(clothes.name)
                                .font(.system(size: 12))
                                .padding(.all, 5)
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(5)
                                .foregroundColor(.white)
                        }
                    }

                    if entry.clothes.count > 4 {
                        HStack(spacing: 8) {
                            ForEach(Array(entry.clothes[5..<min(entry.clothes.count, 8)]), id: \.id) { clothes in
                                Text(clothes.name)
                                    .font(.system(size: 12))
                                    .padding(.all, 5)
                                    .background(Color.gray.opacity(0.5))
                                    .cornerRadius(5)
                                    .foregroundColor(.white)
                            }
                            if entry.clothes.count > 8 {
                                Text("+\(entry.clothes.count - 8)")
                                    .font(.system(size: 12))
                                    .padding(.all, 5)
                                    .background(Color.gray.opacity(0.5))
                                    .cornerRadius(5)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}


// Array를 지정된 크기의 청크로 나누는 확장 기능
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: self.count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, self.count)])
        }
    }
}



struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            WeatherWidgetEntryView(entry: entry).containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("오늘의 날씨")
        .description("당신의 하루를 위한 날씨와 옷차림 정보를 제공합니다.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
