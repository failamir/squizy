import UIKit
import Foundation

class SystemConfig: UIViewController {
    
    var isInitial = true
    var NotificationList: [Notifications] = []
    
    var apiExPeraforLang = ""
    var apiName = ""
    static var config = SystemConfiguration.init(LANGUAGE_MODE:0)
    var catData:[Category] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.LoadLanguages(completion: {})
    }
    func getDeviceInterfaceStyle(){
        //check Appearance / Theme of respected device
        if traitCollection.userInterfaceStyle == .light {
            //print("Light Mode")
            Apps.APPEARANCE = "light"
        }else{
            //print("Dark Mode")
            Apps.APPEARANCE = "dark"
        }
    }
    
    func updtFCMToServer(){
        //update fcm id
        if UserDefaults.standard.bool(forKey: "isLogedin") {
            let duser =  try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
           // print(duser)
            if duser.userID != ""{
                if(Reachability.isConnectedToNetwork()){
                    let apiURL = "user_id=\(duser.userID)&fcm_id=\(Apps.FCM_ID)"
                    self.getAPIData(apiName: "update_fcm_id", apiURL: apiURL,completion: LoadResponse)
                }
            }else{
                print("user ID not available. Try again Later !")
            }
        }
    }
    //load response of updtFCMid data here
    func LoadResponse(jsonObj:NSDictionary){
        print("FCM ID update Response - ",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
            
        }else{
            // on success response do code here
            let msg = jsonObj.value(forKey: "message") as! String
            print(msg)
        }
    }
    func loadCategories(){
        //  call and get API response for categories
        if(Reachability.isConnectedToNetwork()){
            apiName = "get_categories"
            print("value of config @ categories - \(SystemConfig.config)")
            if SystemConfig.config.LANGUAGE_MODE == 1{ //config?
                apiExPeraforLang = "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))"
                apiName = "get_categories_by_language"
            }
            let apiURL = apiExPeraforLang + "&type=1"
            self.getAPIData(apiName: apiName, apiURL: apiURL,completion: {jsonObj in
                print("JSON",jsonObj)
            let status = jsonObj.value(forKey: "error") as! String
            if (status == "true"){
            }else{
                //get data for category
                self.catData.removeAll()
                if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                    for val in data{
                        self.catData.append(Category.init(id: "\(val["id"]!)", name: "\(val["category_name"]!)", image: "\(val["image"]!)", maxlvl: "\(val["maxlevel"]!)", noOf: "\(val["no_of"]!)", noOfQues: "\(val["no_of_que"]!)"))
                    }
                }
                print("categoryData loaded - \(self.catData)")
                UserDefaults.standard.set(try? PropertyListEncoder().encode(self.catData), forKey: "categories")
            }
          })
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    
    func ConfigureSystem() {
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            let apiURL = ""
            self.getAPIData(apiName: Apps.SYSTEM_CONFIG, apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    //load data here
    func LoadData(jsonObj:NSDictionary){
        print("System Config Response - ",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            DispatchQueue.main.async {
                    self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
            }
        }else{
            //get data for category
            if let data = jsonObj.value(forKey: "data") {
                guard let DATA = data as? [String:Any] else{
                    return
                }
                print(DATA)
                let state = DATA["option_e_mode"]  as! String
                if state == "1" {
                    Apps.opt_E = true
                }else{
                    Apps.opt_E = false
                }
                
                let langMode:String =  "\(DATA["language_mode"] ?? 0)"
                SystemConfig.config = SystemConfiguration.init(LANGUAGE_MODE: Int(langMode) ?? 0)
                print("value of config @ systemConfig data - \(SystemConfig.config)")
                UserDefaults.standard.set(try? PropertyListEncoder().encode(SystemConfig.config),forKey: DEFAULT_SYS_CONFIG)
                if langMode == "0" { //clear default lang. if language mode is disabled
                    UserDefaults.standard.removeObject(forKey: DEFAULT_USER_LANG)
                }
                
                let more_apps = DATA["ios_more_apps"]  as! String
                Apps.MORE_APP = more_apps
               // print("more apps link from server -- \(more_apps)")
                
                let share_apps = DATA["ios_app_link"]  as! String
                Apps.SHARE_APP = share_apps
                //print("share apps link from server -- \(share_apps)")
                
                let share_txt = DATA["shareapp_text"]  as! String
                Apps.SHARE_APP_TXT = share_txt
              //  print("share apps text from server -- \(share_txt)")
                
                let ans_mode = DATA["answer_mode"]  as! String
                Apps.ANS_MODE = ans_mode
                
                let refer_coin = DATA["refer_coin"] as! String
                Apps.REFER_COIN = refer_coin
                //print("refer coin value -- \(refer_coin)")
                
                let earn_coin = DATA["earn_coin"]  as! String
                Apps.EARN_COIN = earn_coin
               // print("earn coin value -- \(earn_coin)")
                
                let reward_coin = DATA["reward_coin"] as! String
                Apps.REWARD_COIN = reward_coin
               // print("reward coin value -- \(reward_coin)")
                
                let force_updt_mode = DATA["force_update"]  as! String
                Apps.FORCE_UPDT_MODE = force_updt_mode
                
                let contest_mode = DATA["contest_mode"]  as! String
                Apps.CONTEST_MODE = contest_mode
                
                let daily_quiz_mode = DATA["daily_quiz_mode"]  as! String
                Apps.DAILY_QUIZ_MODE = daily_quiz_mode
                
                let fix_num_ofQue = DATA["fix_question"]  as! String
                Apps.FIX_QUE_LVL = fix_num_ofQue
                //if fix_num_ofQue is true/1, then set total question per level as set in admin panel
                if Apps.FIX_QUE_LVL == "1" {
                    let ttl_que = DATA["total_question"] as! String
                    Apps.FIXED_QS = Int(ttl_que) ?? 10
                }
                
                let group_btl = DATA["battle_group_category_mode"]  as! String
                Apps.GROUP_BATTLE_WITH_CATEGORY = group_btl
                
                let rndm_btl = DATA["battle_random_category_mode"]  as! String
                Apps.RANDOM_BATTLE_WITH_CATEGORY = rndm_btl
                
                let inAppPurchase_Mode = DATA["in_app_purchase_mode"] as! String
                Apps.IN_APP_PURCHASE = inAppPurchase_Mode
                
                let inAppAds_Mode = DATA["ios_in_app_ads_mode"] as! String
                if inAppAds_Mode == "0" { //removeAds
                    removeAdsFromProject()
                }else{ //keep Ads in project
                    UserDefaults.standard.set(false, forKey: "adRemoved")
                                        
                    let chkAdType = DATA["ios_ads_type"]  as! String
                    //if ads_type = 1 -> Google Ads & if ads_type = 2 -> FB Ads
                    if chkAdType == "1" {
                        //show admob ads
                        Apps.ADV_TYPE = "ADMOB"
                                            
                        let adID_banner = DATA["ios_admob_banner_id"]  as! String
                        Apps.BANNER_AD_UNIT_ID = adID_banner
                        
                        let adID_reward = DATA["ios_admob_Rewarded_Video_Ads"]  as! String
                        Apps.REWARD_AD_UNIT_ID = adID_reward
                        
                        let adID_interstitial = DATA["ios_admob_interstitial_id"] as! String
                        Apps.INTERSTITIAL_AD_UNIT_ID = adID_interstitial
                        
                        let adID_OpenApp = DATA["ios_admob_openads_id"] as! String
                        Apps.APP_OPEN_UNIT_ID = adID_OpenApp
                    }else{
                        //show fb ads
                        Apps.ADV_TYPE = "FB"
                        
                        let fbAdID_banner = DATA["ios_fb_banner_id"]  as! String
                        Apps.BANNER_AD_UNIT_ID = fbAdID_banner//"IMG_16_9_APP_INSTALL#2730369673887525_2730627390528420"
                        
                        let fbAdID_reward = DATA["ios_fb_rewarded_video_ads"]  as! String
                        Apps.REWARD_AD_UNIT_ID = fbAdID_reward//"VID_HD_16_9_15S_LINK#2730369673887525_2730633910527768"
                        
                        let fbAdID_interstitial = DATA["ios_fb_interstitial_id"] as! String
                        Apps.INTERSTITIAL_AD_UNIT_ID = fbAdID_interstitial//"CAROUSEL_IMG_SQUARE_LINK#2730369673887525_2730640560527103"
                    }
                }                
                print("Ads type = \(Apps.ADV_TYPE)")
                let socialMedia_yt = DATA["youtube_link"] as! String
                Apps.SOCIAL_YT = socialMedia_yt
                
                let socialMedia_fb = DATA["facebook_link"] as! String
                Apps.SOCIAL_FB = socialMedia_fb
                
                let socialMedia_instagram = DATA["instagram_link"] as! String
                Apps.SOCIAL_IG = socialMedia_instagram
                
                let learningMode:String =  "\(DATA["learning_zone_mode"] ?? 0)"
                Apps.LEARNING_MODE = learningMode
                
                let mathsMode:String =  "\(DATA["maths_quiz_mode"] ?? 0)"
                Apps.MATHS_MODE = mathsMode
                
                let trueFalseMode:String =  "\(DATA["true_false_mode"] ?? 0)"
                Apps.TRUE_FALSE_MODE = trueFalseMode
                
                let maintenanceMode:String =  "\(DATA["app_maintenance"] ?? 0)"
                Apps.APP_MAINTENANCE = maintenanceMode //"0" //"1"
                // if maintenance status is 1 - then show a dialougue above all without close or any button - just close it after status chng
                let appMaintenance_Msg:String = "\(DATA["app_maintenance_message"] ?? Apps.MAINTENANCE_MSG)"
                Apps.MAINTENANCE_MSG = appMaintenance_Msg
                if Apps.APP_MAINTENANCE == "1" {
                    print("under maintenance !!")
                    //present maintenance Pop up alert
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.2, execute: {
                    DispatchQueue.main.async {
                        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier:"Maintenance")
                        myAlert.modalPresentationStyle = .overCurrentContext
                        UIApplication.shared.keyWindow?.rootViewController?.present(myAlert, animated: true, completion: self.completionDone)
                        }
                    });
                }
            }
        }
    }
    
    func completionDone(){
        print("alert done")
    }
    func removeAdsFromProject(){ //removeAds
        print("Ads removal selected")
        let adRemovalPurchased = UserDefaults.standard
        adRemovalPurchased.set(true, forKey: "adRemoved")
        adRemovalPurchased.synchronize()
        print (adRemovalPurchased.bool(forKey: "adRemoved"))
    }
    
    //get notifications from API
    func getNotifications() {
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            let apiURL = ""
            self.getAPIData(apiName: Apps.NOTIFICATIONS, apiURL: apiURL,completion: LoadNotifications)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    //load data here
    func LoadNotifications(jsonObj:NSDictionary){
        print("Notifications Response - ",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
        }else{
            //get data for category
            self.NotificationList.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    NotificationList.append(Notifications.init(title: "\(val["title"]!)", msg: "\(val["message"]!)", img: "\(val["image"]!)"))
                }
                UserDefaults.standard.set(try? PropertyListEncoder().encode(NotificationList), forKey: "notification")
            }
        }
    }
    
    func LoadLanguages(completion:@escaping ()->Void){
        if(Reachability.isConnectedToNetwork()){
            let apiURL = ""
            self.getAPIData(apiName: API_LANGUAGE_LIST, apiURL: apiURL,completion: { jsonObj in
                print(jsonObj)
                let status = jsonObj.value(forKey: "error") as! String
                if (status == "true") {
                }else{
                    var lang_id = 0
                    //get data for category
                    var lang:[Language] = []
                    if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                        for val in data{
                            lang.append(Language.init(id: Int("\(val["id"]!)")!, name: "\(val["language"]!)", status: Int("\(val["status"]!)")!))
                            lang_id = Int("\(val["id"]!)")!
                        }
                        if data.count == 1 { // if only one language is present in admin panel, then select it by default
                            UserDefaults.standard.set(lang_id , forKey: DEFAULT_USER_LANG)
                        }
                    }
                    UserDefaults.standard.set(try? PropertyListEncoder().encode(lang),forKey: DEFAULT_LANGUAGE)
                
                    completion()
                }
            })
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    
    func getUserDetails(){
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            if UserDefaults.standard.value(forKey:"user") != nil{
                let userD:User = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
                print(userD)
                let apiURL = "id=\(userD.userID)"
                print(apiURL)
               self.getAPIData(apiName: Apps.USERS_DATA, apiURL: apiURL,completion: getData)
            }
          }           
    }
    
    func getData(jsonObj:NSDictionary){
        print("Users Data Response - ",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
        }else{
            if let data = jsonObj.value(forKey: "data") as? [String:Any] {
                print(data)
                DispatchQueue.main.async {
                    if let data = jsonObj.value(forKey: "data") {
                        guard let DATA = data as? [String:Any] else{
                            return
                        }
                        print(DATA)
                        
                        let stts = DATA["status"]
                        if UserDefaults.standard.value(forKey:"user") != nil{
                            var userD:User = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
                            userD.status = stts as! String
                            UserDefaults.standard.set(try? PropertyListEncoder().encode(userD), forKey: "user")
                        }
                        let rank = DATA["all_time_rank"]
                        Apps.ALL_TIME_RANK = rank ?? 0
                        
                        let Coinsss = DATA["coins"]  as! String
                        Apps.COINS = Coinsss
                        
                        let all_time_score = DATA["all_time_score"]
                        Apps.SCORE = all_time_score ?? 0
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(UserScore.init(coins: (Int(Apps.COINS) ?? 0), points: Int(Apps.SCORE as? String ?? "0") ?? 0)), forKey: "UserScore")
                }
            }
        }
    }
  }
}
