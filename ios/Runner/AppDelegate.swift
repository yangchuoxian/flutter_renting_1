import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  var wxChannel: FlutterMethodChannel?
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    signal(SIGPIPE, SIG_IGN)

    // flutter call native code method
    let wechatChannelName = "com.onezu.rentingEverything/wechat"
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    self.wxChannel = FlutterMethodChannel(name: wechatChannelName, binaryMessenger: controller.binaryMessenger)

    if (self.wxChannel != nil) {
      self.wxChannel!.setMethodCallHandler({
        [weak self](call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        // Note: this method is invoked on the UI thread
        guard call.method == "wxLogin" else {
          result(FlutterMethodNotImplemented)
          return
        }
        self?.wxLogin(result: result)
      })
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    signal(SIGPIPE, SIG_IGN)
  }
    
  override func applicationWillEnterForeground(_ application: UIApplication) {
    signal(SIGPIPE, SIG_IGN)
  }

  private func wxLogin(result: FlutterResult) {
    // 测试在iOS的native code中写入的数据在flutter中是否可以读到，注意：flutter的SharedPreferences在写入的key前面加了个'flutter.'前缀
    /*
    let defaults = UserDefaults.standard
    let result = defaults.string(forKey: "flutter.wxLoginResult")
    print(result!)
    defaults.set("Well Well", forKey: "flutter.greetingsFromiOS")
    */

    // native code call flutter method
    if (self.wxChannel != nil) {
      self.wxChannel!.invokeMethod("onWXLoginResp", arguments: "I guess received wx login resp")
      result(Int(0))
    }
  }
}

