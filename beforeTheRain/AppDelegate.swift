//
//  AppDelegate.swift
//  beforeTheRain
//
//  Created by 정하랑 on 3/15/24.
//
import Foundation
import Firebase
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // 파이어베이스 설정
        FirebaseApp.configure()
        
        // 앱 실행 시 사용자에게 알림 허용 권한을 받음
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound] // 필요한 알림 권한을 설정
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        // UNUserNotificationCenterDelegate를 구현한 메서드를 실행시킴
        application.registerForRemoteNotifications()
        
        // 파이어베이스 Meesaging 설정
        Messaging.messaging().delegate = self
        
        return true
    }

    // FCM으로부터 사일런트 푸시 알림을 받는 메소드 구현
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("call silent")
        // 사일런트 푸시 알림에서 요청 유형 확인
        if let requestType = userInfo["requestType"] as? String {
            // UserDefaults에서 위치 정보를 읽고 조건에 따라 서로 다른 서버로 요청
            if let period: String = userInfo["period"] as? String {
                sendLocationToServer(requestType: requestType, period: period)
            } else {
                sendLocationToServer(requestType: requestType)
            }
        }
        
        completionHandler(.newData)
    }

    // 조건에 따라 서로 다른 서버로 위치 정보와 requestType을 보내는 메소드
    func sendLocationToServer(requestType: String, period:String? = nil) {
        let userDefaults = UserDefaults(suiteName: "group.com.btr.shared")

        guard let lat = userDefaults?.value(forKey: "latitude") as? Double,
            let lon = userDefaults?.value(forKey: "longitude") as? Double,
            let fcmToken = userDefaults?.string(forKey: "FCMToken") else {
            print("Error: Couldn't find necessary data in UserDefaults.")
            return
        }
        
        let baseUrl = "https://btr-server.shop/weathers/push"
        
        var components = URLComponents(string: baseUrl)!
        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lat", value: "\(lon)"),
            URLQueryItem(name: "type", value: requestType)
        ]

        if let period = period {
            components.queryItems?.append(URLQueryItem(name: "period", value: period))
        }

        var request = URLRequest(url: components.url!)
        request.httpMethod = "HEAD"

        // FCM 토큰을 Authorization 헤더에 추가
        request.setValue("\(fcmToken)", forHTTPHeaderField: "Authorization")

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            // 여기서 응답 처리
            if let error = error {
                print("Error sending location and requestType to server: \(error)")
                return
            }
            
            print("Location and requestType sent to server successfully.")
        }
        task.resume()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 백그라운드에서 푸시 알림을 탭했을 때 실행
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("Firebase registration token: \(String(describing: fcmToken))")

    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
    )
    let userDefaults = UserDefaults(suiteName: "group.com.btr.shared")
    userDefaults?.set(fcmToken, forKey: "FCMToken")
    userDefaults?.synchronize()
    // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}