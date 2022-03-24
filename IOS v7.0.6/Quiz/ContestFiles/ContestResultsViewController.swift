import Foundation
import UIKit
import GoogleMobileAds
import FBAudienceNetwork
import StoreKit

class ContestResultsViewController: UIViewController, GADFullScreenContentDelegate, FBInterstitialAdDelegate { //,GADInterstitialDelegate //, UIDocumentInteractionControllerDelegate
    
   // @IBOutlet var lblCoin: UILabel!
    //@IBOutlet var lblScore: UILabel!
    @IBOutlet var lblResults: UILabel!
    @IBOutlet var lblTrue: UILabel!
    @IBOutlet var lblFalse: UILabel!
    @IBOutlet var totalScore: UILabel!
    @IBOutlet var totalCoin: UILabel!
   // @IBOutlet var nxtLvl: UIButton!
   // @IBOutlet var reviewAns: UIButton!
    @IBOutlet var yourScore: UIButton!
    @IBOutlet var leaderboard: UIButton! //rateUs
    @IBOutlet var homeBtn: UIButton!
    @IBOutlet var viewProgress: UIView!
   // @IBOutlet var view1: UIView!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var titleText: UILabel!
        
    @IBOutlet weak var backImg: UIImageView!
    
    @IBOutlet weak var resultImg: UIImageView!
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
    var contestID = 0
    var quesData: [QuestionWithE] = []
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var controllerName:String = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 400)
        
//        let xPosition = viewProgress.center.x - 20
//        let yPosition = viewProgress.center.y-viewProgress.frame.origin.y + 20
//        let position = CGPoint(x: xPosition, y: yPosition)
        
        // set circular progress bar here and pass required parameters
        let xPosition = viewProgress.center.x - 20
        var yPosition = viewProgress.center.y-viewProgress.frame.origin.y + 110//20
        
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
            
           // xPosition = viewProgress.center.x - 20
            yPosition = viewProgress.center.y-viewProgress.frame.origin.y + 90
        }
        
        let position = CGPoint(x: xPosition, y: yPosition)
        
        // set circular progress bar here and pass required parameters
        progressRing = CircularProgressBar(radius: progRadius, position: position, innerTrackColor: Apps.defaultInnerColor, outerTrackColor: Apps.defaultOuterColor, lineWidth: 6, progValue: 100, isAudience: false)
        
        
        //progressRing = CircularProgressBar(radius: 38, position: position, innerTrackColor: Apps.defaultInnerColor, outerTrackColor: Apps.defaultOuterColor, lineWidth: 6, progValue: 100, isAudience: false)
        
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
       // view1.SetShadow()
        viewProgress.SetShadow()
        // Based on the percentage of questions you got right present the user with different message
        if(percentage >= 30 && percentage < 50) {
            earnedCoin = 1
            lblResults.text = Apps.COMPLETE_LEVEL
            resultImg.image = UIImage(named: "trophy")
        } else if(percentage >= 50 && percentage < 70) {
            earnedCoin = 2
            lblResults.text = Apps.COMPLETE_LEVEL
            resultImg.image = UIImage(named: "trophy")
          //  viewProgress.backgroundColor = UIColor.rgb(212, 247, 248, 1.0)
        }else if(percentage >= 70 && percentage < 90) {
            earnedCoin = 3
            lblResults.text = Apps.COMPLETE_LEVEL
            resultImg.image = UIImage(named: "trophy")
           // viewProgress.backgroundColor = UIColor.rgb(212, 247, 248, 1.0)
        }else if(percentage >= 90) {
            earnedCoin = 4
            lblResults.text = Apps.COMPLETE_LEVEL
            resultImg.image = UIImage(named: "trophy")
           // viewProgress.backgroundColor = UIColor.rgb(212, 247, 248, 1.0)
        }else{
            earnedCoin = 0
            lblResults.text = Apps.NOT_COMPLETE_LEVEL
            resultImg.image = UIImage(named: "defeat")
            //set backtop tint to Red
            //backImg.tintColor = UIColor.red
          //  viewProgress.backgroundColor = UIColor.rgb(255, 226, 244, 1.0)
            //chng backcolor of containing view to red-pink & titlebar txt to play again
            titleText.text = Apps.PLAY_AGAIN
//            nxtLvl.setTitle(Apps.PLAY_AGAIN, for: .normal)
        }
        
        //apps has level lock unlock, remove this code if add no need level lock unlock
//        if (percentage >= 30){
//            if scoreLavel + 1 == self.level{
                score.points = score.points + earnedPoints
                score.coins = score.coins + earnedCoin
                
                totalCoin.text = "\(score.coins)"
                totalScore.text = "\(score.points)"
                
                if UserDefaults.standard.bool(forKey: "isLogedin") {
                    let duser =  try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
                    
                    if(Reachability.isConnectedToNetwork()){                                               
                        
//                        let apiURL = "user_id=\(duser.userID)&questions_attended=\(trueCount + falseCount)&correct_answers=\(trueCount)&score=\(earnedPoints)"
                        let apiURL = "user_id=\(duser.userID)&contest_id=\(contestID)&questions_attended=\(trueCount + falseCount)&correct_answers=\(trueCount)&score=\(earnedPoints)"
                        self.getAPIData(apiName: "contest_update_score", apiURL: apiURL,completion: LoadData)
                    }else{
                        ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
                    }
                }
//            }
//        }
        score.coins = score.coins + earnedCoin
        
//        lblCoin.text = "\(score.coins)"
//        lblScore.text = "\(score.points)"
        
        lblTrue.text = "\(trueCount)"
        lblFalse.text = "\(Apps.TOTAL_PLAY_QS - trueCount)"
                
        totalCoin.text = "\(earnedCoin)"
        totalScore.text = "\(earnedPoints)"
        
       // UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
        
        sysConfig = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        RequestInterstitialAd()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//        RequestInterstitialAd()       
//    }
    
    override func viewDidLayoutSubviews() {
        // call button design button and pass button variable those buttons need to be design
        self.DesignButton(btns: yourScore,leaderboard,homeBtn)// nxtLvl,reviewAns,
    }
    
    // make button custom design function
    func DesignButton(btns:UIButton...){
        for btn in btns {
            btn.SetShadow()
            btn.layer.cornerRadius = btn.frame.height / 3//0//btn.frame.height / 2
          //  btn.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
        }
    }
    
    //load data here
    func LoadData(jsonObj:NSDictionary){
        print("Contest Update Score Response - ",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.ShowAlert(title:Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
        }else{
            //success 
        }
    }
    //MARK: - Apps.ADV_TYPE = FB
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
               // let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
                viewCont.ReviewQues = ReviewQues
                self.addTransition()
                self.navigationController?.pushViewController(viewCont, animated: false)
//                self.navigationController?.pushViewController(viewCont, animated: true)
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
//               self.navigationController?.pushViewController(viewCont, animated: true)
           }else if self.controllerName == "home"{
               self.navigationController?.popToRootViewController(animated: true)
           }
           print("Ad failed to load \(error)")
       }
    //MARK: Apps.ADV_TYPE = FB -
    //MARK: Apps.ADV_TYPE = ADMOB
    //Google AdMob & FB Adv
    func RequestInterstitialAd() {
//        self.interstitialAd = GADInterstitial(adUnitID: Apps.INTERSTITIAL_AD_UNIT_ID)
//        self.interstitialAd.delegate = self
//        let request = GADRequest()
//        // request.testDevices = [ kGADSimulatorID ];
//        //request.testDevices = Apps.AD_TEST_DEVICE
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
//        self.interstitialAd.load(request)
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
    
    // Tells the delegate the interstitial had been animated off the screen.
    //func interstitialDidDismissScreen(_ ad: GADInterstitial) {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd){
        if self.controllerName == "review"{
           // let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
            viewCont.ReviewQues = ReviewQues
            self.addTransition()
            self.navigationController?.pushViewController(viewCont, animated: false)
//            self.navigationController?.pushViewController(viewCont, animated: true)
            RequestInterstitialAd()
        }else if self.controllerName == "home"{
            addPopTransition()
            self.navigationController?.popToRootViewController(animated: false) //true
            
        }else{
            addPopTransition()
            self.navigationController?.popViewController(animated: false)
//            self.navigationController?.popViewController(animated: true)
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
//        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//        let viewCont = storyboard.instantiateViewController(withIdentifier: "LevelView") as! LevelView
//
//        self.navigationController?.popToViewController(viewCont, animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
   /* @IBAction func nxtButton(_ sender: UIButton) {
//
//        let playLavel = percentage < 30 ? self.level : self.level + 1
//        self.quesData.removeAll()
//
//        var apiURL = questionType == "main" ? "level=\(playLavel)&category=\(catID)" : "level=\(playLavel)&subcategory=\(catID)"
//        if sysConfig.LANGUAGE_MODE == 1{
//            apiURL += "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))"
//        }
//
//        self.getAPIData(apiName: "get_questions_by_level", apiURL: apiURL,completion: {jsonObj in
//            let status = jsonObj.value(forKey: "error") as! String
//            if (status == "true") {
//                self.ShowAlert(title: Apps.OOPS, message: Apps.ERROR_MSG )
//            }else{
//                //get data for category
//                if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
//                    for val in data{
//                        self.quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", optionA: "\(val["optiona"]!)", optionB: "\(val["optionb"]!)", optionC: "\(val["optionc"]!)", optionD: "\(val["optiond"]!)", optionE: "\(val["optione"]!)", correctAns: "\(val["answer"]!)", image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType:  "\(val["question_type"]!)"))
//                    }
//                    Apps.TOTAL_PLAY_QS = data.count
//                    //check this level has enough (10) question to play? or not
//                    if self.quesData.count >= Apps.TOTAL_PLAY_QS {
//                        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//                        let viewCont = storyboard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
//
//                        viewCont.catID = self.catID
//                        viewCont.level = playLavel
//                        viewCont.questionType = self.questionType
//                        viewCont.quesData = self.quesData
//                        DispatchQueue.main.async {
//                            self.navigationController?.pushViewController(viewCont, animated: true)
//                        }
//                    }//else{
////                        self.ShowAlert(title: Apps.NOT_ENOUGH_QUESTION_TITLE, message: Apps.NO_ENOUGH_QUESTION_MSG)
////                    }
//                }
//            }
//        })
    } */
    
   /* @IBAction func reviewButton(_ sender: UIButton) {
        self.controllerName = "review"
//        if interstitialAd.isReady{
//            self.interstitialAd.present(fromRootViewController: self)
//        }
        if Apps.ADV_TYPE == "ADMOB"{
             if let ad = interstitialAd {
                ad.present(fromRootViewController: self)
              }else{
                  let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
                  viewCont.ReviewQues = ReviewQues
                  self.navigationController?.pushViewController(viewCont, animated: true)
             }
         }else{
             if let ad = interstitialAdFB {
                 ad.show(fromRootViewController: self)
              }else{
                  let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
                  viewCont.ReviewQues = ReviewQues
                  self.navigationController?.pushViewController(viewCont, animated: true)
             }
         }
    } */
    
    @IBAction func homeButton(_ sender: UIButton) {
        self.controllerName = "home"
//        if interstitialAd.isReady{
//            interstitialAd.present(fromRootViewController: self)
//        }
        if Apps.ADV_TYPE == "ADMOB"{
            if let ad = interstitialAd {
               ad.present(fromRootViewController: self)
             }else{
                 self.navigationController?.popToRootViewController(animated: true)
            }
        }else{
            if let ad = interstitialAdFB {
                ad.show(fromRootViewController: self)
             }else{
                 self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    @IBAction func scoreButton(_ sender: UIButton) {
        let str  = Apps.APP_NAME
        let shareUrl = "\(Apps.SHARE_CONTEST) \(self.earnedPoints)"
        let textToShare = str + "\n" + shareUrl
        //take screenshot
        //UIGraphicsBeginImageContext(parentView.frame.size) //viewProgress
        UIGraphicsBeginImageContextWithOptions(parentView.frame.size, false, 3);
        parentView.layer.render(in: UIGraphicsGetCurrentContext()!) //viewProgress
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let vc = UIActivityViewController(activityItems: [textToShare, image! ], applicationActivities: [])
       // vc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionCentre;
        vc.popoverPresentationController?.sourceView = sender
        //vc.popoverPresentationController?.sourceView = self.view
//        if let popOver = vc.popoverPresentationController {
//            popOver.sourceView = self.view
//        }
        present(vc, animated: true)
    }
    
    func OptionStr(rightAns:String, userAns:String,opt:String,choice:String) ->String {        
        if(rightAns == userAns && userAns == choice){
            return "<font color='green'>\(opt). \(choice) </font><br>"
        }else if(userAns == choice){
            return "<font color='red'>\(opt). \(choice) </font><br>"
        }else if(rightAns == choice){
            return "<font color='green'>\(opt). \(choice) </font><br>"
        }else{
            return "\(opt). \(choice)<br>"
        }
    }
    
    func GetRightAnsString(correctAns:String, quetions:ReQuestionWithE)->String{
        if correctAns == "a"{
            return quetions.optionA
        }else if correctAns == "b"{
            return quetions.optionB
        }else if correctAns == "c"{
            return quetions.optionC
        }else if correctAns == "d"{
            return quetions.optionD
        }else if correctAns == "e"{
            return quetions.optionE
        }else{
            return ""
        }
    }
    
    @IBAction func leaderboardButton(_ sender: UIButton) {
        //gotoLeaderboard
    if UserDefaults.standard.bool(forKey: "isLogedin"){
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ContestLeaderboard") as! ContestLeaderboard
        viewCont.contestID = self.contestID //Int(self.catData[button.tag].id)!
        self.addTransition()
        self.navigationController?.pushViewController(viewCont, animated: false)
//        self.navigationController?.pushViewController(viewCont, animated: true)
    }else{
        //show pop up for login
        ShowAlert(title: Apps.NOT_LOGGED_IN, message: "") //ask to login First to use leaderboard
    }        
//        if #available(iOS 10.3, *) {
//            SKStoreReviewController.requestReview()
//        }else if let url = URL(string: Apps.SHARE_APP) {
//             UIApplication.shared.open(url)
//        }
    }
}

//extension ResultsViewController{
//    
//    func SetUserLevel(){
//        if(Reachability.isConnectedToNetwork()){
//            let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
//            let apiURL = self.questionType == "main" ? "user_id=\(user.userID)&category=\(self.catID)&subcategory=0&level=\(self.level)" : "user_id=\(user.userID)&category=\(mainCatID)&subcategory=\(self.catID)&level=\(self.level)"
//            self.getAPIData(apiName: "set_level_data", apiURL: apiURL,completion: { jsonObj in
//                print("JSON",jsonObj)
//            })
//        }else{
//            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
//        }
//    }
//}
