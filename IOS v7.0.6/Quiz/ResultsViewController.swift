import Foundation
import UIKit
import GoogleMobileAds
import FBAudienceNetwork
import StoreKit

class ResultsViewController: UIViewController,GADFullScreenContentDelegate, FBInterstitialAdDelegate {
    
    @IBOutlet var lblResults: UILabel!
    @IBOutlet var lblTrue: UILabel!
    @IBOutlet var lblFalse: UILabel!
    @IBOutlet var totalScore: UILabel!
    @IBOutlet var totalCoin: UILabel!
    @IBOutlet var nxtLvl: UIButton!
    @IBOutlet var reviewAns: UIButton!
    @IBOutlet var yourScore: UIButton!
    @IBOutlet var leaderboard: UIButton!
    @IBOutlet var homeBtn: UIButton!
    @IBOutlet var viewProgress: UIView!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var resultImg: UIImageView!
    
    @IBOutlet weak var titleText: UILabel!
        
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var parentView: UIView!
    
    var interstitialAd : GADInterstitialAd?
    var interstitialAdFB : FBInterstitialAd?
    
    var count:CGFloat = 0.0
    var progressRing: CircularProgressBar!
    var sysConfig:SystemConfiguration!
    var timer: Timer!
    
    var trueCount = 0
    var falseCount = 0
    var percentage:CGFloat = 0.0
    var earnedCoin = 0
    var earnedPoints = 0
    var ReviewQues:[ReQuestionWithE] = []
    
    var level = 0
    var catID = 0
    var questionType = "sub"
    var quesData: [QuestionWithE] = []
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var controllerName:String = ""
    var playType = ""
    var firstTym = false
    var nameOfChapter = ""
    var isSubCat = false
    var maxlevel = 0
    
    func setResultLabel(){
        if (self.playType == "daily") {
            lblResults.text = Apps.DAILY_QUIZ_MSG_SUCCESS
        }else if (self.playType == "RandomQuiz") {
            lblResults.text = Apps.RANDOM_QUIZ_MSG_SUCCESS
        }else if (self.playType == "true/false"){
            lblResults.text = Apps.TF_QUIZ_MSG_SUCCESS
        }else if (self.playType == "learning"){
            lblResults.text = Apps.LEARNING_QUIZ_MSG_SUCCESS
        }else if (self.playType == "maths"){
            lblResults.text = Apps.MATHS_QUIZ_MSG_SUCCESS
        }else{
            lblResults.text = Apps.COMPLETE_LEVEL
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 400)
        
        let xPosition = viewProgress.center.x - 20
        var yPosition = viewProgress.center.y-viewProgress.frame.origin.y + 120
        
        var progRadius:CGFloat = 38
        var minScale:CGFloat = 0.6
        var fontSize:CGFloat = 20
        
        if deviceStoryBoard == "Ipad"{
            yPosition = viewProgress.center.y-viewProgress.frame.origin.y + 150
        }
        
        if Apps.screenHeight < 750 {
            progRadius = 25
            minScale = 0.3
            fontSize = 12
            
            yPosition = viewProgress.center.y-viewProgress.frame.origin.y + 90
        }
        
        let position = CGPoint(x: xPosition, y: yPosition)
        
        // set circular progress bar here and pass required parameters
        progressRing = CircularProgressBar(radius: progRadius, position: position, innerTrackColor: Apps.defaultInnerColor, outerTrackColor: Apps.defaultOuterColor, lineWidth: 6, progValue: 100, isAudience: false)
        viewProgress.layer.addSublayer(progressRing)
        progressRing.progressLabel.numberOfLines = 1;
        progressRing.progressLabel.font = progressRing.progressLabel.font.withSize(fontSize)
        progressRing.progressLabel.minimumScaleFactor = minScale;
        progressRing.progressLabel.textColor = UIColor.white
        progressRing.progressLabel.adjustsFontSizeToFitWidth = true;
        
        self.RegisterNotification(notificationName: "ResultView")
        self.CallNotification(notificationName: "PlayView")
        
        // Calculate the percentage of quesitons you got right
        percentage = CGFloat(trueCount) / CGFloat(Apps.TOTAL_PLAY_QS)
        percentage *= 100
        
        // set timer for progress ring and make it active
        timer = Timer.scheduledTimer(timeInterval: 0.06, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
        
        var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
        
        //User/Player should get coins for 1st time play Only - not in any of next plays for same level
        if UserDefaults.standard.value(forKey:"\(questionType)\(catID)") != nil {
            var lvl = 0
            lvl = Int(truncating: UserDefaults.standard.value(forKey:"\(questionType)\(catID)") as! NSNumber)
            print("\(lvl) - \(firstTym)")
            if self.level > lvl { //!=
                firstTym = true
            }else{
                firstTym = false
            }
        }else{
            firstTym = true
        }
        
        if (self.playType == "daily") || (self.playType == "RandomQuiz") || (self.playType == "true/false") || (self.playType == "learning") || (self.playType == "maths") {
            titleText.text = Apps.DAILY_QUIZ_TITLE
            nxtLvl.setTitle( Apps.DAILY_QUIZ_TITLE, for: .normal)
        }else{
            if (level == maxlevel){ //if current level is last one.
                titleText.text = Apps.PLAY_AGAIN
                nxtLvl.setTitle(Apps.PLAY_AGAIN, for: .normal)
            }
        }
      
        // Based on the percentage of questions you got right present the user with different message
        if(percentage >= 30 && percentage < 50) {
            earnedCoin = 1
            setResultLabel()
            resultImg.image = UIImage(named: "trophy")
        } else if(percentage >= 50 && percentage < 70) {
            earnedCoin = 2
            setResultLabel()
            resultImg.image = UIImage(named: "trophy")
        }else if(percentage >= 70 && percentage < 90) {
            earnedCoin = 3
            setResultLabel()
            resultImg.image = UIImage(named: "trophy")
        }else if(percentage >= 90) {
            earnedCoin = 4
            setResultLabel()
            resultImg.image = UIImage(named: "trophy")
        }else{
            earnedCoin = 0
            if (self.playType == "daily") {
                lblResults.text = Apps.DAILY_QUIZ_MSG_FAIL
            }else if (self.playType == "RandomQuiz") {
                lblResults.text = Apps.RANDOM_QUIZ_MSG_FAIL
            }else if (self.playType == "true/false"){
                lblResults.text = Apps.TF_QUIZ_MSG_FAIL
            }else if (self.playType == "learning"){
                lblResults.text = Apps.LEARNING_QUIZ_MSG_FAIL
            }else if (self.playType == "maths"){
                lblResults.text = Apps.MATHS_QUIZ_MSG_FAIL
            }else{
                lblResults.text = Apps.NOT_COMPLETE_LEVEL
            }
            resultImg.image = UIImage(named: "defeat")
            titleText.text = Apps.PLAY_AGAIN
            nxtLvl.setTitle(Apps.PLAY_AGAIN, for: .normal)
        }
        
        //apps has level lock unlock, remove this code if add no need level lock unlock
        if (percentage >= 30){
                if playType != "learning"{
                     if firstTym == true { //update coins for 1st tym play level only
                         score.coins = score.coins + earnedCoin
                         if UserDefaults.standard.bool(forKey: "isLogedin") {
                             let duser =  try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
                             
                             if(Reachability.isConnectedToNetwork()){
                                 self.SetUserLevel()
                                 var apiURL = "user_id=\(duser.userID)&score=\(earnedPoints)"
                                 self.getAPIData(apiName: "set_monthly_leaderboard", apiURL: apiURL,completion: LoadData)
                                 
                                 apiURL = "user_id=\(duser.userID)&questions_answered=\(trueCount + falseCount)&correct_answers=\(trueCount)&category_id=\(catID)&ratio=\(percentage)&coins=\(score.coins)"
                                 self.getAPIData(apiName: "set_users_statistics", apiURL: apiURL,completion: LoadData)
                                 print("you have played this level - coins added !!!")
                             }else{
                                 ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
                             }
                         }
                     }else{
                         print("you have played this level many times - so no coins will be added !  Unlock new levels !!!")
                     }
                }else{
                    //no stats to be set in learning
                }
        }
        
        lblTrue.text = "\(trueCount)"
        lblFalse.text = "\(Apps.TOTAL_PLAY_QS - trueCount)"
                
        totalCoin.text = "\(earnedCoin)"
        totalScore.text = "\(earnedPoints)"
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
        
        sysConfig = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
       // RequestInterstitialAd()
    }
    override func viewDidLayoutSubviews() {
        // call button design button and pass button variable those buttons need to be design
        self.DesignButton(btns: nxtLvl,reviewAns, yourScore,leaderboard,homeBtn)
        if (self.playType == "maths"){
            reviewAns.alpha = 0
            nxtLvl.translatesAutoresizingMaskIntoConstraints = false
            nxtLvl.widthAnchor.constraint(equalTo: homeBtn.widthAnchor).isActive = true
            nxtLvl.heightAnchor.constraint(equalTo: homeBtn.heightAnchor).isActive = true
            nxtLvl.leftAnchor.constraint(equalTo: homeBtn.leftAnchor).isActive = true
        }else{
            reviewAns.alpha = 1
        }
         viewProgress.SetShadow()
    }
    // make button custom design function
    func DesignButton(btns:UIButton...){
        for btn in btns {
            btn.SetShadow()
            btn.layer.cornerRadius = btn.frame.height / 3
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //load data here
    func LoadData(jsonObj:NSDictionary){
        print("ResultView - stats Response",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.ShowAlert(title:Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
        }else{
            // success !!!
        }
    }
    //MARK: - Apps.ADV_TYPE = FB
    //Google AdMob - FB
    func RequestInterstitialAd() {
              
        if !UserDefaults.standard.bool(forKey: "adRemoved") { //RemoveAds
            if Apps.ADV_TYPE == "ADMOB" {
                let request = GADRequest()
                GADInterstitialAd.load(withAdUnitID:Apps.INTERSTITIAL_AD_UNIT_ID,
                        request: request,
                        completionHandler: { (ad, error) in
                         if let error = error {
                           print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                           return
                         }
                         self.interstitialAd = ad
                         self.interstitialAd!.fullScreenContentDelegate = self
                 })                
            }else{
                print(FBAdSettings.testDeviceHash())
                FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash()) //commemnt this line when app is live
                interstitialAdFB = FBInterstitialAd(placementID: Apps.INTERSTITIAL_AD_UNIT_ID)
                interstitialAdFB!.delegate = self
                interstitialAdFB!.load()
            }
        }else{
            print("Ads Removed !!")
        }
    }
    
    internal func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
           print("Ad is loaded and ready to be displayed")
           if interstitialAd != nil && interstitialAd.isAdValid {
               // You can now display the full screen ad using this code:
               interstitialAd.show(fromRootViewController: self)
           }
       }
    func interstitialAdWillLogImpression(_ interstitialAd: FBInterstitialAd) {
           print("The user sees the add")
           // Use this function as indication for a user's impression on the ad.
       }

    func interstitialAdDidClick(_ interstitialAd: FBInterstitialAd) {
           print("The user clicked on the ad and will be taken to its destination")
           // Use this function as indication for a user's click on the ad.
       }

    func interstitialAdWillClose(_ interstitialAd: FBInterstitialAd) {
           print("The user clicked on the close button, the ad is just about to close")
           // Consider to add code here to resume your app's flow
       }

    func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
           print("Interstitial had been closed")
           // Consider to add code here to resume your app's flow
            if self.controllerName == "review"{
                let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
                viewCont.ReviewQues = ReviewQues
                self.addTransition()
                self.navigationController?.pushViewController(viewCont, animated: false)
                RequestInterstitialAd()
            }else if self.controllerName == "home"{
                self.navigationController?.popToRootViewController(animated: true)
            }
       }
       func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
           if self.controllerName == "review"{
               let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
               viewCont.ReviewQues = ReviewQues
               self.addTransition()
               self.navigationController?.pushViewController(viewCont, animated: false)
           }else if self.controllerName == "home"{
               self.navigationController?.popToRootViewController(animated: true)
           }
           print("Ad failed to load \(error)")
       }
    //MARK: Apps.ADV_TYPE = FB -
    //MARK: Apps.ADV_TYPE = ADMOB
    // Tells the delegate the interstitial had been animated off the screen.
        func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd){
        if self.controllerName == "review"{
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
            viewCont.ReviewQues = ReviewQues
            self.addTransition()
            self.navigationController?.pushViewController(viewCont, animated: false)
            RequestInterstitialAd()
        }else if self.controllerName == "home"{
            addPopTransition()
            self.navigationController?.popToRootViewController(animated: false) //true
        }else{
            addPopTransition()
            self.navigationController?.popViewController(animated: false)
        }
    }
    //MARK: Apps.ADV_TYPE = ADMOB -
  
    // Note only works when time has not been invalidated yet
    @objc func resetProgressCount() {
        count = 0
        timer.fire()
    }
    
    @objc func incrementCount() {
        count += 2
        progressRing.progressManual = CGFloat(count)
        if count >= CGFloat(percentage) {
            timer.invalidate()
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func nxtButton(_ sender: UIButton) {
        //check if quiz is daily,true false or regular one first
        if self.playType == "daily" {
            DispatchQueue.main.async {
                self.ShowAlert(title: Apps.PLAYED_ALREADY, message: Apps.PLAYED_MSG)
//                return
            }
        }else if self.playType == "true/false" || self.playType == "RandomQuiz" {
            //getQuestions(self.playType)
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
                       
            var quesData: [QuestionWithE] = []
            var apiURL = ""
            var apiName = "get_daily_quiz"
            
            if sysConfig.LANGUAGE_MODE == 1{
                let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
                apiURL += "language_id=\(langID)"
            }
            
            Loader = LoadLoader(loader: Loader)
            if self.playType == "RandomQuiz"{
                apiName = "get_questions_by_type"
                apiURL += "&type=1&limit=\(Apps.TOTAL_PLAY_QS)&"  //1=normal ,2 = true/false
                viewCont.titlebartext = "Random Quiz"
                viewCont.playType = "RandomQuiz"
            }else if self.playType == "true/false"{
                apiName = "get_questions_by_type"
                apiURL += "&type=2&limit=\(Apps.TOTAL_PLAY_QS)"
                viewCont.titlebartext = "True/False"
                viewCont.playType = "true/false"
            }
            self.getAPIData(apiName: "\(apiName)", apiURL: apiURL,completion: {jsonObj in
                print("api name and url - \(apiName) - \(apiURL)")
                print("JSON",jsonObj)
                //close loader here
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                    DispatchQueue.main.async {
                        self.DismissLoader(loader: self.Loader)
                    }
                });
                let status = jsonObj.value(forKey: "error") as! String
                if (status == "true") {
                    print(jsonObj.value(forKey: "message"))
                }else{
                    //error false
                    //get data for category
                    quesData.removeAll()
                    if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                        for val in data{
                            quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", optionA: "\(val["optiona"]!)", optionB: "\(val["optionb"]!)", optionC: "\(val["optionc"]!)", optionD: "\(val["optiond"]!)", optionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType: "\(val["question_type"]!)"))
                        }
                        Apps.TOTAL_PLAY_QS = data.count
                        
                        //check this level has enough (10) question to play? or not
                        if quesData.count >= Apps.TOTAL_PLAY_QS {
                            viewCont.quesData = quesData
                            DispatchQueue.global().asyncAfter(deadline: .now() + 0.6, execute: {
                                DispatchQueue.main.async {
                                    self.addTransition()
                                    self.navigationController?.pushViewController(viewCont, animated: false)
                                }
                            })
                        }
                    }
                }
            })
        }else if self.playType == "maths"{
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "PlayMathQuizView") as! PlayMathQuizView
            viewCont.catID = self.catID
            viewCont.isSubCat = self.isSubCat
            print("maths Quiz -- \(self.questionType) - \(self.playType)")
            viewCont.playType = self.playType
            DispatchQueue.main.async {
                self.addTransition()
                self.navigationController?.pushViewController(viewCont, animated: false)
            }
        }else{
            var playLevel = 1
            if (self.level == maxlevel){ //last level of respected category/subcategory
                playLevel = 1 //start from first level
            }else if percentage < 30 {
                playLevel = self.level
            }else{
                playLevel = self.level + 1
            }
            self.quesData.removeAll()
            var urlVal = ""
            if questionType == "main"
            {
                urlVal = "level=\(playLevel)&category=\(catID)"
            }else if questionType == "learning"{
                  urlVal = "learning_id=\(catID)"
            }else{ //sub
                urlVal = "level=\(playLevel)&subcategory=\(catID)"
            }
            var apiURL = urlVal
            if sysConfig.LANGUAGE_MODE == 1{
                apiURL += "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))"
            }
            let nameOfAPI = (questionType == "learning") ? "get_questions_by_learning" : "get_questions_by_level"
            self.getAPIData(apiName: nameOfAPI , apiURL: apiURL,completion: {jsonObj in
                let status = jsonObj.value(forKey: "error") as! String
                if (status == "true") {
                    self.ShowAlert(title: Apps.OOPS, message: Apps.ERROR_MSG )
                }else{
                    //get data for category
                    if self.questionType == "learning"{
                        if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                            for val in data{
                                self.quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", optionA: "\(val["optiona"]!)", optionB: "\(val["optionb"]!)", optionC: "\(val["optionc"]!)", optionD: "\(val["optiond"]!)", optionE: "\(val["optione"]!)", correctAns: "\(val["answer"]!)", image: "", level: "", note: "", quesType:  "\(val["question_type"]!)"))
                            }
                            if Apps.FIX_QUE_LVL == "0" {  //fixed number of Questions set to False
                                Apps.TOTAL_PLAY_QS = data.count
                            }else{
                                Apps.TOTAL_PLAY_QS = Apps.FIXED_QS
                            }
                            //check this level has enough (10) question to play? or not
                            if self.quesData.count >= Apps.TOTAL_PLAY_QS {
                                let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
                                viewCont.catID = self.catID
                                print("\(self.questionType) - \(self.playType)")
                                viewCont.playType = self.playType
                                viewCont.questionType = self.questionType
                                viewCont.quesData = self.quesData
                                DispatchQueue.main.async {
                                    self.addTransition()
                                    self.navigationController?.pushViewController(viewCont, animated: false)
                                }
                            }
                        }
                    }else{
                        if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                            for val in data{
                                self.quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", optionA: "\(val["optiona"]!)", optionB: "\(val["optionb"]!)", optionC: "\(val["optionc"]!)", optionD: "\(val["optiond"]!)", optionE: "\(val["optione"]!)", correctAns: "\(val["answer"]!)", image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType:  "\(val["question_type"]!)"))
                            }
                            if Apps.FIX_QUE_LVL != "1" {
                                Apps.TOTAL_PLAY_QS = data.count
                            }
                            //check this level has enough (10) question to play? or not
                            if self.quesData.count >= Apps.TOTAL_PLAY_QS {
                                let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
                                
                                viewCont.catID = self.catID
                                viewCont.level = playLevel
                                print("\(self.questionType) - \(self.playType)")
                                viewCont.playType = self.playType
                                viewCont.questionType = self.questionType
                                viewCont.quesData = self.quesData
                                DispatchQueue.main.async {
                                    self.addTransition()
                                    self.navigationController?.pushViewController(viewCont, animated: false)
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func reviewButton(_ sender: UIButton) {
        self.controllerName = "review"
       if Apps.ADV_TYPE == "ADMOB"{
            if let ad = interstitialAd {
                RequestInterstitialAd()
               ad.present(fromRootViewController: self)
             }else{
                 let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
                 viewCont.ReviewQues = ReviewQues
                 self.addTransition()
                 self.navigationController?.pushViewController(viewCont, animated: false)
            }
        }else{
            if let ad = interstitialAdFB {
                RequestInterstitialAd()
                ad.show(fromRootViewController: self)
             }else{
                 let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
                 viewCont.ReviewQues = ReviewQues
                 self.addTransition()
                 self.navigationController?.pushViewController(viewCont, animated: false)
            }
        }
    }
    
    @IBAction func homeButton(_ sender: UIButton) {
        self.controllerName = "home"
       
        if Apps.ADV_TYPE == "ADMOB"{
            RequestInterstitialAd()
            if let ad = interstitialAd {
               ad.present(fromRootViewController: self)
             }else{
                 self.navigationController?.popToRootViewController(animated: true)
            }
        }else{
            if let ad = interstitialAdFB {
                RequestInterstitialAd()
                ad.show(fromRootViewController: self)
             }else{
                 self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    @IBAction func scoreButton(_ sender: UIButton) { //share score
        let str  = Apps.APP_NAME
        var shareUrl = ""
        
        if self.playType == "main"{
            shareUrl = "\(Apps.SHARE1) \(self.level) \(Apps.SHARE2) \(self.earnedPoints)"
        } else if self.playType == "true/false"{
            shareUrl = "\(Apps.TF_QUIZ_SHARE_MSG) \(self.earnedPoints)"
        } else if self.playType == "RandomQuiz" {
            shareUrl = "\(Apps.RANDOM_QUIZ_SHARE_MSG) \(self.earnedPoints)"
        } else if self.playType == "learning" {
            shareUrl = "\(Apps.LEARNING_QUIZ_SHARE_MSG) \(self.earnedPoints)"
        } else if self.playType == "maths" {
            shareUrl = "\(Apps.MATHS_QUIZ_SHARE_MSG) \(self.earnedPoints)"
        }else{
            shareUrl = "\(Apps.DAILY_QUIZ_SHARE_MSG) \(self.earnedPoints)"
        }
       
        let textToShare = str + "\n" + shareUrl
        //take screenshot
        UIGraphicsBeginImageContextWithOptions(parentView.frame.size, false, 3);
        parentView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        image?.withRenderingMode(.alwaysOriginal)
        UIGraphicsEndImageContext()
        
        let vc = UIActivityViewController(activityItems: [textToShare, image! ], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = sender
        present(vc, animated: true)
    }
    
    
    @IBAction func leaderboardButton(_ sender: UIButton) {
        //gotoLeaderboard if user loggedIn
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "Leaderboard")
            self.addTransition()
            self.navigationController?.pushViewController(viewCont, animated: false)
        }else{
            //show pop up for login
            ShowAlert(title: Apps.NOT_LOGGED_IN, message: "") //ask to login First to use leaderboard
        }      
    }
}

extension ResultsViewController{
    
    func SetUserLevel(){
        if(Reachability.isConnectedToNetwork()){
            let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            let apiURL = self.questionType == "main" ? "user_id=\(user.userID)&category=\(self.catID)&subcategory=0&level=\(self.level)" : "user_id=\(user.userID)&category=\(mainCatID)&subcategory=\(self.catID)&level=\(self.level)"
            UserDefaults.standard.set(self.level, forKey:"\(questionType)\(catID)")
            self.getAPIData(apiName: "set_level_data", apiURL: apiURL,completion: { jsonObj in
                print("JSON",jsonObj)
            })
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
}
