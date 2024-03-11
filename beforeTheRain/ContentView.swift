import SwiftUI
import UIKit
import WebKit
import UserNotifications
import CoreLocation

class MyViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler, CLLocationManagerDelegate {
    var webView: WKWebView!
    let locationManager = CLLocationManager()
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "nativeApp")
        webConfiguration.userContentController = userContentController
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization() // 백그라운드에서도 위치 정보 사용 권한 요청
        let myURL = URL(string: "https://enormously-pretty-weevil.ngrok-free.app")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 웹뷰 로딩이 완료된 후 필요한 JavaScript 코드 실행
        // 예: 초기 위치 권한 상태 전달
    }

    func updateLocationPermissionEnabled() {
        let enabled = CLLocationManager.locationServicesEnabled()
        print("Location permission enabled: \(enabled)")

        let jsCode = "if (window.updateLocationPermissionEnabled) { window.updateLocationPermissionEnabled('\(enabled)'); }"
            webView.evaluateJavaScript(jsCode) { (result, error) in
                if let error = error {
                    print("Error updating location in webview: \(error)")
                }
            }
            
        webView.evaluateJavaScript(jsCode, completionHandler: nil)
    }

    // 위치 정보 업데이트 콜백
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let jsCode = "window.updateLocation(\(location.coordinate.latitude), \(location.coordinate.longitude));"
            print(location.coordinate.latitude, location.coordinate.longitude)
            webView.evaluateJavaScript(jsCode) { (result, error) in
                if let error = error {
                    print("Error updating location in webview: \(error)")
                }
            }
        }
    }
    // JavaScript로부터 메시지를 받는 메서드
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "nativeApp" {
            if message.body as! String == "updateLocationPermissionEnabled" {
                updateLocationPermissionEnabled()
            } else if message.body as! String == "startUpdatingLocation" {
                locationManager.startUpdatingLocation()
            } else if message.body as! String == "stopUpdatingLocation" {
                locationManager.stopUpdatingLocation()
            } else if message.body as! String == "requestLocationPermission" {
                locationManager.requestAlwaysAuthorization() // 백그라운드에서도 위치 정보 사용 권한 요청
            } else if message.body as! String == "requestNotificationPermission" {
                requestNotificationPermission()
            } else if message.body as! String == "updateNotificationPermissionEnabled" {
                updateNotificationPermissionEnabled()
            }
        }
    }
    func updateNotificationPermissionEnabled() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {settings in
            let enabled = settings.authorizationStatus == .authorized
            let jsCode = "if (window.updateNotificationPermissionEnabled) { window.updateNotificationPermissionEnabled('\(enabled)'); }"
            self.webView.evaluateJavaScript(jsCode, completionHandler: nil)
        })
    }

    func requestNotificationPermission(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {didAllow,Error in
            updateNotificationPermissionEnabled()
        })
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let enabled = CLLocationManager.locationServicesEnabled()

        // 권한이 부여되었는지 확인하고 위치 업데이트 시작
        if enabled == true {
            locationManager.startUpdatingLocation()
        }
    }
}

struct MyView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> MyViewController {
        return MyViewController()
    }
    
    func updateUIViewController(_ uiViewController: MyViewController, context: Context) {
    }
}

struct ContentView: View {
    var body: some View {
        MyView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
