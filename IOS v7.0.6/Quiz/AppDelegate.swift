import UIKit
import CoreData
import GoogleSignIn
import Firebase
import UserNotifications
import FirebaseMessaging
import FBSDKCoreKit
import GoogleMobileAds
import FBAudienceNetwork
import AppTrackingTransparency

var deviceStoryBoard = "Main"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GADFullScreenContentDelegate {
    
    var window: UIWindow?
    let varSys = SystemConfig()
    let gcmMessageIDKey = "test.demo"
    var imgURL = URL(string: "")
    var isImgAttached = false
    var subtitle : String = ""
    var title : String = ""
    var body : String = ""
    var type : String = ""
    var category : [String] = []
    let screenBounds = UIScreen.main.bounds
    var appOpenAd: GADAppOpenAd?
    var loadTime = Date()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        FBAdSettings.setAdvertiserTrackingEnabled(true)
        ApplicationDelegate.shared.application(application,didFinishLaunchingWithOptions: launchOptions) //for Fb login
        
        //firebase configuration
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //get screen height & width to use it further for diff iphone screens
        Apps.screenWidth = screenBounds.width
        Apps.screenHeight = screenBounds.height
        
        //to get system configurations parameters as per requirement
       varSys.ConfigureSystem()
        if UserDefaults.standard.bool(forKey: "isLogedin") {
            varSys.getUserDetails()
        }
       varSys.LoadLanguages(completion: {})
       varSys.loadCategories()
       varSys.getNotifications()
       varSys.getDeviceInterfaceStyle()
             
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })

        application.registerForRemoteNotifications()
        
        //set badge
        if Apps.badgeCount > 0 {
            application.applicationIconBadgeNumber = Apps.badgeCount
        }else{ //clear badge
            application.applicationIconBadgeNumber = 0
        }
        Messaging.messaging().delegate = self
        
        let token = Messaging.messaging().fcmToken ?? "none"
        Apps.FCM_ID = token
        print("FCM TOKEN", token)
        
        
        //check app is log in or not if not then navigate to login view controller
        if UIDevice.current.userInterfaceIdiom == .pad{
            deviceStoryBoard = "Ipad"
        }else{
            deviceStoryBoard = "Main"
        }
        if UserDefaults.standard.bool(forKey: "isLogedin") {
            let initialViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "ViewController")
            let navigationcontroller = UINavigationController(rootViewController: initialViewController)
            navigationcontroller.setNavigationBarHidden(true, animated: false)
            navigationcontroller.isNavigationBarHidden = true
            navigationcontroller.modalPresentationCapturesStatusBarAppearance = true
            
            self.window?.rootViewController = navigationcontroller
            self.window?.makeKeyAndVisible()
        }else{
            let initialViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "LoginView")
            let navigationcontroller = UINavigationController(rootViewController: initialViewController)
            navigationcontroller.setNavigationBarHidden(true, animated: false)
            navigationcontroller.isNavigationBarHidden = true
            navigationcontroller.modalPresentationCapturesStatusBarAppearance = true
        
            self.window?.rootViewController = navigationcontroller
            self.window?.makeKeyAndVisible()
        }
        return true
    }
    //to redirect back to app from google login in ios 10
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:],annotation: Any) -> Bool {
        return (GIDSignIn.sharedInstance.handle((url as URL?)!)) || ApplicationDelegate.shared.application( app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
        
    // Google Sign In
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        //battle modes
        NotificationCenter.default.post(name: Notification.Name("MakeUserOffline"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("ResetBattle"), object: nil)
        print("called resignActive")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // call function when app is gone to background to quit battle
        NotificationCenter.default.post(name: Notification.Name("QuitBattle"), object: nil)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        //call function when app is live again to check opponent again
        NotificationCenter.default.post(name: Notification.Name("CheckBattle"), object: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        //battle modes
        NotificationCenter.default.post(name: Notification.Name("MakeUserOnline"), object: nil)
        if #available(iOS 15.0, *) {
           ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
           })
        }
        if !UserDefaults.standard.bool(forKey: "adRemoved") { //RemoveAds
            if Apps.ADV_TYPE == "ADMOB"{
                self.tryToPresentAd()
            }
        }else{
            print("Ads Removed !!")
        }
        NotificationCenter.default.addObserver(self, selector:#selector(tokenRefreshNotification), name:NSNotification.Name.MessagingRegistrationTokenRefreshed, object: nil)
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    @objc func tokenRefreshNotification(notification: NSNotification) {

        if let refreshedToken = Messaging.messaging().fcmToken  {
            print("InstanceID token: \(refreshedToken)")
            UserDefaults.standard.set(refreshedToken, forKey: "deviceToken")
            varSys.updtFCMToServer()
        }
        
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        NotificationCenter.default.post(name: Notification.Name("QuitBattle"), object: nil)
        application.applicationIconBadgeNumber = Apps.badgeCount
    }
    
    //test
    func requestAppOpenAd() {
        let request = GADRequest()
        GADAppOpenAd.load(withAdUnitID: Apps.APP_OPEN_UNIT_ID,
                          request: request,
                          orientation: UIInterfaceOrientation.portrait,
                          completionHandler: { (appOpenAdIn, _) in
                            self.appOpenAd = appOpenAdIn
                            self.appOpenAd?.fullScreenContentDelegate = self
                            self.loadTime = Date()
                            print("Open App Ad is ready")
                          })
    }

    func tryToPresentAd() {
        if let gOpenAd = self.appOpenAd, let rwc = self.window?.rootViewController, wasLoadTimeLessThanNHoursAgo(thresholdN: 4) {
            gOpenAd.present(fromRootViewController: rwc)
        } else {
            self.requestAppOpenAd()
        }
    }

    func wasLoadTimeLessThanNHoursAgo(thresholdN: Int) -> Bool {
        let now = Date()
        let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(self.loadTime)
        let secondsPerHour = 3600.0
        let intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour
        return intervalInHours < Double(thresholdN)
    }
    
    func fragmentRemoteData(_  str:String){
        //separate parameters of response by using ","
        let displayname = str.components(separatedBy: ",")
        //print(displayname)
        let len = displayname.count
        print(len)
        let img0 = displayname[0] //img url
        let img1 = img0.dropFirst()
        let img2 = img1.components(separatedBy: "\"")
        if img2.count > 3 { // img2[0] & img2[2] = "" and img2[1] = image according to separation applied above, so if img is attached it will depend on img2[3] if img url is attched
            if img2[3] != "" && img2[3] != "null" {
                let img: String = img2[3]
                imgURL = setAttachment(img)
                isImgAttached = true
            }else{
                print("image url is blank !!!")
            }
        }
        let a = displayname[4] //title
        
        let b = displayname[5] //body or message
        
        let c = a.components(separatedBy: ":")
        let title1: String = c[1]
        
        let d = b.components(separatedBy: ":")
        let body1: String = d[1]
        
        let e: String = title1
        let f = e.components(separatedBy: "\"")
        
        let g: String = body1
        let h = g.components(separatedBy: "\"")
        print("title - \(f[1])")
        print("message - \(h[1])")
        
        let max_level0 = displayname[1] //max level
        let max_level1 = max_level0.components(separatedBy: ":")
        let max_level2 : String = max_level1[1]
        let max_level = max_level2.components(separatedBy:  "\"")
        print("max level - \(max_level[1])")
        
        let category0 = displayname[2] //type id
        let category1 = category0.components(separatedBy: ":")
        let category2 : String = category1[1]
        if category2.contains("\""){
            category = category2.components(separatedBy:  "\"")
            print("category - \(category[1])")
        }else{
            category  = ["0","0"]
        }
        
        let numOf0 = displayname[3] //numberOf
        let numOf1 = numOf0.components(separatedBy: ":")
        let numOf2: String = numOf1[1]
        
        let numOf = numOf2.components(separatedBy:  "\"")
        print("number of - \(numOf[1])")
        
        let temp = displayname[6]
        let temp0 = temp.components(separatedBy: ":")
        let temp1 = temp0[1].components(separatedBy: "}") //type
        let temp2: String = temp1[0]
        let temp3 = temp2.components(separatedBy:  "\"")
        type = temp3[1]
        print("type - \(type)")
        
        title = f[1]
        body = h[1]
        //pass variable values to global variables
        Apps.nTitle = title
        Apps.nMsg = body
        Apps.nMaxLvl = Int(max_level[1]) ?? 0
        Apps.nMainCat = category[1]
        Apps.nSubCat = numOf[1]
        Apps.nType = type
    }
    
    func showNotification(_ title:String,_ body:String){
        //show notification alert with received title & body
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "testIdentifier", content: content, trigger: trigger)
        
        Apps.badgeCount += 1
        UserDefaults.standard.set(Apps.badgeCount, forKey: "badgeCount")
        print(Apps.badgeCount)
        UNUserNotificationCenter.current().add(request,withCompletionHandler: nil)
    }
    
    func showNotificationWithAttachment(_ title:String,_ body:String,_ img:URL){
        //show notification pop up with received title & body
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = UNNotificationSound.default
        print("data \(img)")
        if img.path.contains("jpg"){
            print("file is present @ \(img.path)")
            let attachment = try! UNNotificationAttachment(identifier : "image", url: img, options: nil)
            content.attachments = [attachment]
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "testIdentifier", content: content, trigger: trigger)
            if content.title != "" && content.body != "" {
                Apps.badgeCount += 1
                UserDefaults.standard.set(Apps.badgeCount, forKey: "badgeCount")
                print(Apps.badgeCount)
                UNUserNotificationCenter.current().add(request,withCompletionHandler: nil)
            }
        }else{
            print("file is not present at given path")
        }
    }
    
    func setAttachment(_ tempImg : String) -> URL {
        // Create destination URL
        let  documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsUrl)
        //add downloaded image as specified name below
        let destinationFileUrl = documentsUrl.appendingPathComponent("tempImg.jpg")
        //Create URL to the source file you want to download
        let iimage =  tempImg.replacingOccurrences(of: "\\", with: "")
        //print("passing url - \(iimage)")
        let fileURL = URL(string: iimage) //https://api.androidhive.info//images//minion.jpg  https://www.arenaflowers.co.in/blog/wp-content/uploads/2017/09/Summer_Flowers_Lotus.jpg
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    self.removeTempImg() //to avoid overrriding, just delete existing file & then copy file here
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
                
            } else {
                // print("Error took place while downloading a file. Error description: %@", error?.localizedDescription as Any);
            }
        }
        task.resume()
        return destinationFileUrl
    }
    //func called when user click on notification as received
    func actionAccordingToData(){
        if Apps.nType == "default" {
            //goTo homepage
        }else if Apps.nType == "category" {
            if Apps.nSubCat != "0" {
                let subCatView:subCategoryViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "SubCategoryView") as! subCategoryViewController
                subCatView.catID = Apps.nMainCat //pass main category id to show subcategories regarding to main category there
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = subCatView
                self.window?.makeKeyAndVisible()
            }else if Apps.nMainCat != "0"{
                //open level 1 of category id given
                let levelScreen:LevelView = Apps.storyBoard.instantiateViewController(withIdentifier: "LevelView") as! LevelView
                levelScreen.maxLevel = Apps.nMaxLvl
                levelScreen.catID = Int(Apps.nMainCat) ?? 0
                levelScreen.questionType = "main"
                // print(levelScreen.questionType)
                // print(levelScreen.catID)
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = levelScreen
                self.window?.makeKeyAndVisible()
            }
        }
    }
    
    func removeTempImg(){ //remove Img before copying new image downloaded from url given with notification data
        let  documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationFileUrl = documentsUrl.appendingPathComponent("tempImg.jpg")
        if FileManager.default.fileExists(atPath: destinationFileUrl.path){
            try? FileManager.default.removeItem(at: destinationFileUrl)
        }
    }
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Quiz")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate{
    //to preview notification in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(Apps.badgeCount)
        completionHandler([.alert,.badge,.sound])
    }
    
    //func called when user tap on notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse,withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        //deduct 1 from badgeCount As user opens notification
        if Apps.badgeCount > 0 {
            Apps.badgeCount -= 1
            UserDefaults.standard.set(Apps.badgeCount, forKey: "badgeCount")
        }
        actionAccordingToData()
        print(" user info - \(userInfo)")
        completionHandler()
    }
     func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) { //private
        // The token is not currently available.
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
          }
        Messaging.messaging().appDidReceiveMessage(userInfo)
        switch application.applicationState {
            
        case .inactive:
            print("Inactive")
            //Show the view with the content of the push
            completionHandler(.newData)
            
        case .background:
            print("Background")
            //Refresh the local model
            completionHandler(.newData)
            
        case .active:
            print("Active")
            //Show an in-app banner Notification
           // completionHandler(.newData)
        @unknown default:
            print("default case")
        }
        
       // print("USER INFO ",userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
     func application(application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) { //private
        Messaging.messaging().apnsToken = deviceToken as Data
         print(MessagingMessageInfo.self)
        print("token \(deviceToken)")
    }
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print(fcmToken)
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken!)")
        
        let dataDict:[String: String?] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict as [AnyHashable : Any])
        //NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        //send token to application server.
        Apps.FCM_ID = fcmToken!
        varSys.updtFCMToServer()
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("notification content - \(userInfo)")
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingMessageInfo){
        let xx = MessagingMessageInfo.description()
        print(xx)
    }
}
