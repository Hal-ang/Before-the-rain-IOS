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
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), temperature: 0.0, pop: 0.0, symbol: "sun.max.fill", clothes: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ()) {
        fetchWeatherData() { weatherData in
            let entry = WeatherEntry(date: Date(), temperature: weatherData?.temp ?? 0.0, pop: weatherData?.pop ?? 0.0, symbol: weatherData?.symbol ?? "sun.max.fill", clothes: weatherData?.clothes ?? [])
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> ()) {
        fetchWeatherData() { weatherData in
            let currentDate = Date()
            let entry = WeatherEntry(date: currentDate, temperature: weatherData?.temp ?? 0.0, pop: weatherData?.pop ?? 0.0, symbol: weatherData?.symbol ?? "sun.max.fill", clothes: weatherData?.clothes ?? [])
            let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }

  func fetchWeatherData(completion: @escaping (WeatherData?) -> Void) {
    let userDefaults = UserDefaults(suiteName: "group.com.btr.shared")
    guard let lat = userDefaults?.double(forKey: "latitude"),
          let lon = userDefaults?.double(forKey: "longitude") else {
        completion(nil)
        return
    }
    let urlString = "http://192.168.35.173:4000/weathers/widget?lat=\(lat)&lon=\(lon)"
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Network request error: \(error!)")
            completion(nil)
            return
        }

        do {
            let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
            print("Decoded Weather Data: \(weatherData)")
            completion(weatherData)
        } catch {
            print("JSON decoding error: \(error)")
            completion(nil)
        }
    }
    task.resume()
  }
}


struct WeatherEntry: TimelineEntry {
    let date: Date
    let temperature: Double
    let pop: Double
    let symbol: String
    let clothes: [Clothes]
}

struct Clothes: Codable, Identifiable {
    let id: Int
    let name: String
}

// 데이터 모델에 해당하는 부분입니다.
struct WeatherData : Codable{
    let dt: Int
    let temp: Double
    let pop: Double
    let symbol: String
    let clothes: [Clothes]
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
