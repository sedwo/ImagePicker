import UIKit
import CocoaLumberjack



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  lazy var controller: UIViewController = ViewController()

  var window: UIWindow?

  override init() {
    super.init()

    // Enable 'XcodeColors' plugin for CocoaLumberjack  (unsigned Xcode only)
    setenv("XcodeColors", "YES", 0);    // https://github.com/robbiehanson/XcodeColors
    setupLoggingFramework()
    DDLogInfo("")
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow()
    window?.rootViewController = controller
    window?.makeKeyAndVisible()

    return true
  }


  // MARK: - Private

  private func setupLoggingFramework() {
    // console
    DDLog.add(DDTTYLogger.sharedInstance) // TTY = Xcode console
    DDTTYLogger.sharedInstance.logFormatter = MyCustomFormatter()

    DDTTYLogger.sharedInstance.colorsEnabled = true
    let pinkColour = UIColor(red: 255/255.0, green: 58/255.0, blue: 159/255.0, alpha: 1.0)
    DDTTYLogger.sharedInstance.setForegroundColor(pinkColour, backgroundColor: nil, for: DDLogFlag.error)
    DDTTYLogger.sharedInstance.setForegroundColor(UIColor.yellow, backgroundColor: nil, for: DDLogFlag.warning)
    DDTTYLogger.sharedInstance.setForegroundColor(UIColor.cyan, backgroundColor: nil, for: DDLogFlag.debug)
    DDTTYLogger.sharedInstance.setForegroundColor(UIColor.orange, backgroundColor: nil, for: DDLogFlag.verbose)

    // file
    let fileLogger: DDFileLogger = DDFileLogger() // File Logger
    fileLogger.maximumFileSize = (1 * 1048576);   // ~1MB
    fileLogger.logFileManager.maximumNumberOfLogFiles = 50
    fileLogger.logFormatter = MyCustomFormatter()
    DDLog.add(fileLogger)
  }

}
