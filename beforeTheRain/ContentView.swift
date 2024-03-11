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
        userContentController.add(self, name: "notificationPermissionRequest")
        userContentController.add(self, name: "locationPermissionRequest")
        webConfiguration.userContentController = userContentController
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        let myURL = URL(string: "https://enormously-pretty-weevil.ngrok-free.app")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
        requestNotificationPermission()
        requestLocationPermission()
    }
    
    // 푸시 알림 권한을 요청하고, 결과를 웹뷰 내의 자바스크립트 함수 setNotificationPermission으로 전달
    // 권한이 허용되었는지의 여부를 인자로 받는다
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("푸시 알림 권한을 사용자가 허용했습니다.")
                    self?.webView.evaluateJavaScript("setNotificationPermission(true)")
                } else {
                    print("푸시 알림 권한을 사용자가 거부했습니다.")
                    self?.webView.evaluateJavaScript("setNotificationPermission(false)")
                }
            }
        }
    }
    
    // 위치 정보 권한을 요청
    // 권한 상태 변경 시, locationManager(_:didChangeAuthorization:) 메서드를 통해 변경된 권한 상태를 웹뷰에 전달
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    //  웹뷰에서 notificationPermissionRequest 또는 locationPermissionRequest 메시지를 받을 때 해당 권한을 요청하는 로직을 실행
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "notificationPermissionRequest" {
            requestNotificationPermission()
        } else if message.name == "locationPermissionRequest" {
            requestLocationPermission()
        }
    }
    
    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            webView.evaluateJavaScript("setLocationPermission(true)")
        case .authorizedWhenInUse, .denied, .restricted:
            webView.evaluateJavaScript("setLocationPermission(false)")
        default:
            break
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
