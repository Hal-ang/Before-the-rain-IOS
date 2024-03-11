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
        userContentController.add(self, name: "setLocationServicesEnabled")
        userContentController.add(self, name: "setNotificationPermissionEnabled")
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
        checkPermissiionEnabled()
    }
    
    // 푸시 알림 권한을 요청하고, 결과를 웹뷰 내의 자바스크립트 함수 setNotificationPermission으로 전달
    // 권한이 허용되었는지의 여부를 인자로 받는다
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                    print("푸시 알림 권한을 사용자가 허용했습니다.")
                        let jsCode = """
                            window.notificationPermissionEnabled = '\(granted)';
                        """

                    self?.webView.evaluateJavaScript(jsCode)
            }
        }
    }
    
    // 위치 정보 권한을 요청
    // 권한 상태 변경 시, locationManager(_:didChangeAuthorization:) 메서드를 통해 변경된 권한 상태를 웹뷰에 전달
    func requestLocationPermission() {
        locationManager.requestAlwaysAuthorization()
        // locationManager.requestWhenInUseAuthorization()
    }

    func checkLocationPermissionEnabled() {
            let enabled = CLLocationManager.locationServicesEnabled()
            let jsCode = """
                window.locationPermissionEnabled = '\(enabled)';
            """
            self.webView.evaluateJavaScript(jsCode)
    }

    func checkNotificationPErmissionEnabled() {
            let current = UNUserNotificationCenter.current()

            current.getNotificationSettings(completionHandler: { (settings) in
                if settings.authorizationStatus == .authorized {
                    let jsCode = """
                        window.notificationPermissionEnabled = '\(true)';
                    """
                    print(jsCode)
                    self.webView.evaluateJavaScript(jsCode)
                } else {
                    let jsCode = """
                        window.notificationPermissionEnabled = '\(false)';
                    """
                    print(jsCode)
                    self.webView.evaluateJavaScript(jsCode)
                }
            })
    }
    func checkPermissiionEnabled() {
        checkLocationPermissionEnabled()
        checkNotificationPErmissionEnabled()
    }
    
    //  웹뷰에서 notificationPermissionRequest 또는 locationPermissionRequest 메시지를 받을 때 해당 권한을 요청하는 로직을 실행
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "notificationPermissionRequest" {
            requestNotificationPermission()
        } else if message.name == "locationPermissionRequest" {
            requestLocationPermission()
        } else if message.name == "setLocationServicesEnabled" {
            let enabled = CLLocationManager.locationServicesEnabled()
            let jsCode = """
                window.locationPermissionEnabled = '\(enabled)';
            """
            self.webView.evaluateJavaScript(jsCode)
        } else if message.name == "setNotificationPermissionEnabled" {
            let current = UNUserNotificationCenter.current()

            current.getNotificationSettings(completionHandler: { (settings) in
                if settings.authorizationStatus == .authorized {
                    let jsCode = """
                        window.notificationPermissionEnabled = '\(true)';
                    """
                    print(jsCode)
                    self.webView.evaluateJavaScript(jsCode)
                } else {
                    let jsCode = """
                        window.notificationPermissionEnabled = '\(false)';
                    """
                    print(jsCode)
                    self.webView.evaluateJavaScript(jsCode)
                }
            })
        }
    }
    
    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("call")
        var granted = false

        switch status {
        case .authorizedAlways:
            granted = true
        print("위치 정보 권한이 항상 허용되었습니다.")
        case .authorizedWhenInUse, .denied, .restricted:
            granted = false;
        default:
            break
        }
        
        let jsCode = """
            window.LocationServicesEnabled = '\(granted)';
        """

        self.webView.evaluateJavaScript(jsCode)
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
