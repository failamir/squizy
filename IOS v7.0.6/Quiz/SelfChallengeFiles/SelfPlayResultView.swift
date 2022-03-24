import Foundation
import UIKit
import AVFoundation
import GoogleMobileAds
import FBAudienceNetwork

class SelfPlayResultView: UIViewController,GADFullScreenContentDelegate , FBInterstitialAdDelegate, FBAdViewDelegate { //,GADInterstitialDelegate -10feb- //, UIDocumentInteractionControllerDelegate
    
    @IBOutlet var timerLabel: UILabel!
   // @IBOutlet var lblScore: UILabel!
    @IBOutlet var lblResults: UILabel!
    @IBOutlet var lblTrue: UILabel!
    @IBOutlet var lblFalse: UILabel!
   // @IBOutlet var totalScore: UILabel!
   // @IBOutlet var totalCoin: UILabel!
    @IBOutlet var nxtLvl: UIButton!
    @IBOutlet var reviewAns: UIButton!
    @IBOutlet var yourScore: UIButton!
    @IBOutlet var battleBtn: UIButton! //rateUs
    @IBOutlet var homeBtn: UIButton!
    @IBOutlet var viewProgress: UIView!
   // @IBOutlet var view1: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var titleText: UILabel!
    
   // @IBOutlet var adsView:GADBannerView!
    // @IBOutlet weak var adContainer: UIView!
     var adView: FBAdView?
    
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var parentView: UIView!
    
    var interstitialAd : GADInterstitialAd? //GADInterstitialAdBeta?
    //GADInterstitial! -10feb-
    var interstitialAdFB : FBInterstitialAd?
    
    var count:CGFloat = 0.0
    var progressRing: CircularProgressBar!
    var timer: Timer!
    
    var trueCount = 0
    var falseCount = 0
    var percentage:CGFloat = 0.0
    
    var ReviewQues:[ReQuestionWithE] = []
    var quesCount = 0
    var quesData: [QuestionWithE] = []
    
    var completedTime = 0
    var totalTime = 0
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var controllerName:String = ""
    var audioPlayer : AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 430)
        
        var xPosition = viewProgress.center.x - 20
        var yPosition = viewProgress.center.y-viewProgress.frame.origin.y - 15
        
        var progRadius:CGFloat = 35
        var minScale:CGFloat = 0.5
        var fontSize:CGFloat = 20
        // set circular progress bar here and pass required parameters
        if Apps.screenHeight < 750 {
            progRadius = 25
            minScale = 0.3
            fontSize = 12
            
            xPosition = viewProgress.center.x - 20
            yPosition = viewProgress.center.y-viewProgress.frame.origin.y
        }
        
        let position = CGPoint(x: xPosition, y: yPosition)
        
        progressRing = CircularProgressBar(radius: progRadius, position: position, innerTrackColor: Apps.defaultInnerColor, outerTrackColor: Apps.defaultOuterColor, lineWidth: 5,progValue: CGFloat(self.totalTime), isAudience: false)
        viewProgress.layer.addSublayer(progressRing)
        progressRing.progressLabel.numberOfLines = 1;
        progressRing.progressLabel.font = progressRing.progressLabel.font.withSize(fontSize)
        progressRing.progressLabel.minimumScaleFactor = minScale;
        progressRing.progressLabel.textColor = UIColor.white
        progressRing.progressLabel.adjustsFontSizeToFitWidth = true;
        
        self.lblResults.text = "\(Apps.RESULT_TXT) \(self.secondsToHoursMinutesSeconds(seconds: (self.totalTime - self.completedTime))) \(Apps.SECONDS)"
        // Calculate the percentage of questions you got right here
        self.timerLabel.text = "\(Apps.CHLNG_TIME) \(self.secondsToHoursMinutesSeconds(seconds: self.totalTime))"
        
        var attempCount = 0
        for rev in self.ReviewQues{
            let rightStr = self.GetRightAnsString(correctAns: rev.correctAns, quetions: rev)
            if rightStr == rev.userSelect{
                self.trueCount += 1
            }
            
            if rev.userSelect != ""{
                attempCount += 1
            }
        }
        percentage = CGFloat(trueCount) / CGFloat(attempCount)
        percentage *= 100
        // set timer for progress ring and make it active
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
        
        lblTrue.text = "\(trueCount)"
        lblFalse.text = "\(attempCount - trueCount)"
        
      /*  if !UserDefaults.standard.bool(forKey: "adRemoved") { //RemoveAds
            if Apps.ADV_TYPE == "ADMOB" {
                // Google AdMob Banner
                adsView.adUnitID = Apps.BANNER_AD_UNIT_ID
                adsView.rootViewController = self
                let request = GADRequest()
                //request.testDevices = Apps.AD_TEST_DEVICE
                GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
                adsView.load(request)
            }else{
                adView = FBAdView(
                    placementID: Apps.BANNER_AD_UNIT_ID,
                           adSize: kFBAdSize320x50,
                           rootViewController: self)
                adView!.frame = CGRect(x: 0, y: 0, width: self.adsView.frame.width, height: self.adsView.frame.height) //adContainer
                adView!.delegate = self
                adView!.loadAd()
            }
            RequestInterstitialAd()
        }else{
            adsView.isHidden = true
            print("Ads Removed !!")
        } */
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//        RequestInterstitialAd()
//    }
    override func viewDidLayoutSubviews() {
        // call button design button and pass button variable those buttons need to be design
        self.DesignButton(btns: nxtLvl,reviewAns, yourScore,battleBtn,homeBtn)
        viewProgress.SetShadow()
    }
    // make button custom design function
    func DesignButton(btns:UIButton...){
        for btn in btns {
            btn.SetShadow()
            btn.layer.cornerRadius = btn.frame.height / 3//0// 2
          //  btn.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
        }
    }
    
    //load data here
  /*  func LoadData(jsonObj:NSDictionary){
        print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
        }else{
            //success
        }
    } */
    //MARK: - Apps.ADV_TYPE = FB
   /* func adViewDidClick(_ adView: FBAdView) {
         print("Banner ad was clicked.")
     }

    func adViewDidFinishHandlingClick(_ adView: FBAdView) {
         print("Banner ad did finish click handling.")
     }

    func adViewWillLogImpression(_ adView: FBAdView) {
         print("Banner ad impression is being captured.")
     }
     
    func adView(_ adView: FBAdView, didFailWithError error: Error) {
        print("Ad failed to load \(String(describing: error))")
     }

    func adViewDidLoad(_ adView: FBAdView) {
         print("Ad was loaded and ready to be displayed")
         showBanner()
     }

     func showBanner() {
         if (adView != nil) && adView!.isAdValid {
//             adContainer.addSubview(adView!)
             adsView.addSubview(adView!)
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
         //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
         let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
         viewCont.ReviewQues = ReviewQues
         self.navigationController?.pushViewController(viewCont, animated: true)
         RequestInterstitialAd()
     }else if self.controllerName == "home"{
         self.navigationController?.popToRootViewController(animated: true)
//     }else{
//         self.navigationController?.popViewController(animated: true)
     }
    }
    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        if self.controllerName == "review"{
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
            viewCont.ReviewQues = ReviewQues
            self.navigationController?.pushViewController(viewCont, animated: true)
        }else if self.controllerName == "home"{
            self.navigationController?.popToRootViewController(animated: true)
        }
        print("Ad failed to load \(error)")
    }
    //MARK: Apps.ADV_TYPE = FB -
    //MARK: Apps.ADV_TYPE = ADMOB
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
          print("Banner loaded successfully")
      }

    private func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: NSError) {
          print("Fail to receive ads")
          print(error)
      }
    
    //Google AdMob & FB both
    func RequestInterstitialAd() {
       /* self.interstitialAd = GADInterstitial(adUnitID: Apps.INTERSTITIAL_AD_UNIT_ID)
        self.interstitialAd.delegate = self
        let request = GADRequest()
        // request.testDevices = [ kGADSimulatorID ];
        //request.testDevices = Apps.AD_TEST_DEVICE
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
        self.interstitialAd.load(request) -10feb-*/
        if !UserDefaults.standard.bool(forKey: "adRemoved") { //RemoveAds
            if Apps.ADV_TYPE == "ADMOB" {
                let request = GADRequest() //GADInterstitialAdBeta
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
    //func interstitialDidDismissScreen(_ ad: GADInterstitial) { -10feb-
        func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd){
        if self.controllerName == "review"{
            //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
            viewCont.ReviewQues = ReviewQues
            self.navigationController?.pushViewController(viewCont, animated: true)
            RequestInterstitialAd()
        }else if self.controllerName == "home"{
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    } */
    //MARK:  Apps.ADV_TYPE = ADMOB -
    
    // Note only works when time has not been invalidated yet
    @objc func resetProgressCount() {
        count = 0
        timer.fire()
    }
    
    @objc func incrementCount() {
        let comTime = self.totalTime - self.completedTime
        count += 1
        progressRing.progressManual = CGFloat(count)
        progressRing.progressLabel.text = self.secondsToHoursMinutesSeconds(seconds: Int(count))
        if count >= CGFloat(comTime) {
            timer.invalidate()
            return
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
//        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//        let viewCont = storyboard.instantiateViewController(withIdentifier: "LevelView") as! LevelView
//
//        self.navigationController?.popToViewController(viewCont, animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func nxtButton(_ sender: UIButton) {
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        
//        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "categoryview")//CategoryView
        self.addTransition()
        self.navigationController?.pushViewController(viewCont, animated: false)
//        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    
    @IBAction func reviewButton(_ sender: UIButton) {
        self.controllerName = "review"
        /*if interstitialAd.isReady{
            self.interstitialAd.present(fromRootViewController: self)
        }   -10feb-*/
       /* if let ad = interstitialAd {
           ad.present(fromRootViewController: self)
         }else{
//            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
            viewCont.ReviewQues = ReviewQues
            self.navigationController?.pushViewController(viewCont, animated: true)
        } */
        if Apps.ADV_TYPE == "ADMOB"{
            if let ad = interstitialAd {
               ad.present(fromRootViewController: self)
             }else{
                 let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
                 viewCont.ReviewQues = ReviewQues
                 self.addTransition()
                 self.navigationController?.pushViewController(viewCont, animated: false)
//                 self.navigationController?.pushViewController(viewCont, animated: true)
            }
        }else{
            if let ad = interstitialAdFB {
                ad.show(fromRootViewController: self)
             }else{
                 let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
                 viewCont.ReviewQues = ReviewQues
                 self.addTransition()
                 self.navigationController?.pushViewController(viewCont, animated: false)
//                 self.navigationController?.pushViewController(viewCont, animated: true)
            }
        }
    }
    
    @IBAction func homeButton(_ sender: UIButton) {
        self.controllerName = "home"
        /*if interstitialAd.isReady{
            self.interstitialAd.present(fromRootViewController: self)
        }   -10feb-*/
       /* if let ad = interstitialAd {
           ad.present(fromRootViewController: self)
         }else{
            self.navigationController?.popToRootViewController(animated: true)
        } */
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
        let shareUrl = "\(Apps.SELF_CHALLENGE_SHARE1) \(self.secondsToHoursMinutesSeconds(seconds: Int(self.totalTime))) \(Apps.SELF_CHALLENGE_SHARE2) \(self.secondsToHoursMinutesSeconds(seconds: (self.totalTime - self.completedTime))) \(Apps.SELF_CHALLENGE_SHARE3)"
        let textToShare = str + "\n" + shareUrl
        let vc = UIActivityViewController(activityItems: [textToShare], applicationActivities: [])
         vc.popoverPresentationController?.sourceView = sender
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
    
    @IBAction func battleButton(_ sender: UIButton) { //rateButton
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        if UserDefaults.standard.bool(forKey: "isLogedin"){
//            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "BattleViewController")
            self.addTransition()
            self.navigationController?.pushViewController(viewCont, animated: false)
//            self.navigationController?.pushViewController(viewCont, animated: true)
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
//    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
//        return self//or use return self.navigationController for fetching app navigation bar colour
//    }
}
