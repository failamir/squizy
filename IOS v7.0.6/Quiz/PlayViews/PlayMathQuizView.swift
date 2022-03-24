import Foundation
import UIKit
import AVFoundation
import GoogleMobileAds
import FBAudienceNetwork
import WebKit

class PlayMathQuizView: UIViewController, UIScrollViewDelegate,UIWebViewDelegate ,GADFullScreenContentDelegate, FBRewardedVideoAdDelegate, WKUIDelegate { //, WKNavigationDelegate
    
    @IBOutlet weak var titleBar: UILabel!
    @IBOutlet var lblQuestion: UIView!
    
    @IBOutlet var btnA: UIButton!
    @IBOutlet var btnB: UIButton!
    @IBOutlet var btnC: UIButton!
    @IBOutlet var btnD: UIButton!
    @IBOutlet var btnE: UIButton!
        
    @IBOutlet weak var bookmarkBtn: UIButton!
    @IBOutlet var secondChildView: UIView!
    
    @IBOutlet weak var lifeLineView: UIView!
        
    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet var mainQuestionView: UIView!
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var zoomScroll: UIScrollView!
    
   // @IBOutlet var scoreLbl: UILabel!
    @IBOutlet var view1: UIView!
    @IBOutlet weak var questionView: UIView!
        
    var count: CGFloat = 0.0
    var score: Int = 0
    
    var progressRing: CircularProgressBar!
    var timer: Timer!
    var player: AVAudioPlayer?
        
    // The reward-based video ad.
    var rewardedAd: GADRewardedAd?
    var rewardedVideoAd: FBRewardedVideoAd?
    
    var falseCount = 0
    var trueCount = 0
    
    @IBOutlet weak var mainQuesCount: UILabel!
    @IBOutlet weak var mainScoreCount: UILabel!
    @IBOutlet weak var mainCoinCount: UILabel!
    
    @IBOutlet var verticalView: UIView!
    
    var jsonObj : NSDictionary = NSDictionary()
    var quesData: [QuestionMath] = []
    var reviewQues:[QuestionMath] = []
    var BookQuesList:[QuestionMath] = []
    
    var currentQuestionPos = 0
   
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var catID = 0
    var catName = "Maths"
    //var questionType = "sub"
    var titlebartext = ""
    var nameOfChapter = ""
    //var zoomScale:CGFloat = 1
    
    var opt_ft = false
    var opt_sk = false
    var opt_au = false
    var opt_re = false
    
    var correctAnswer = "a"
    
    var callLifeLine = ""
    //let speechSynthesizer = AVSpeechSynthesizer()
    
    var playType = "maths"
    
    var webView: WKWebView!
    var webViewA: WKWebView!
    var webViewB: WKWebView!
    var webViewC: WKWebView!
    var webViewD: WKWebView!
    var webViewE: WKWebView!
    let webConfiguration = WKWebViewConfiguration()
    
    var config:SystemConfiguration?
    var apiExPeraforLang = ""
    var isSubCat = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Apps.opt_E == true {
            btnE.isHidden = false
            buttons = [btnA,btnB,btnC,btnD,btnE]
            DesignOptionButton(buttons: btnA,btnB,btnC,btnD,btnE)
        }else{
            btnE.isHidden = true
            buttons = [btnA,btnB,btnC,btnD]
            DesignOptionButton(buttons: btnA,btnB,btnC,btnD)
        }
    
        //font
        resizeTextview()
      
        self.RegisterNotification(notificationName: "PlayView")
        self.CallNotification(notificationName: "ResultView")
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayQuizView.ReloadFont), name: NSNotification.Name(rawValue: "ReloadFont"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayQuizView.ResumeTimer), name: NSNotification.Name(rawValue: "ResumeTimer"), object: nil)
        
        let mScore = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
        mainScoreCount.text = "\(mScore.points)"
        mainCoinCount.text = "\(mScore.coins)"

        zoomScroll.minimumZoomScale = 1.0
        zoomScroll.maximumZoomScale = 6.0
        
        self.questionView.DesignViewWithShadow()
        
        let xPosition = view1.center.x - 10
        let yPosition = view1.center.y - 5
        let position = CGPoint(x: xPosition, y: yPosition)
        progressRing = CircularProgressBar(radius: (view1.frame.size.height - 20) / 2, position: position, innerTrackColor: Apps.defaultInnerColor, outerTrackColor: Apps.defaultOuterColor, lineWidth: 6)
        view1.layer.addSublayer(progressRing)
        
        quesData.shuffle()
        
        if !UserDefaults.standard.bool(forKey: "adRemoved") { //RemoveAds
            RequestForRewardAds()
        }
        self.titleBar.text = self.catName//Apps.MATHS_PLAY
        setWebViewsLayout()
        getMathQuestions()
        //self.loadQuestion()
    }
    func setWebViewsLayout(){
        DispatchQueue.main.async {
            if self.webViewA != nil {
                self.webViewA.removeFromSuperview()
            }
            self.webViewA = nil
            let customFrameA = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.btnA.frame.size.width, height: self.btnA.frame.size.height))
            self.webViewA = WKWebView (frame: customFrameA , configuration: self.webConfiguration)
            self.webViewA.isOpaque = false
            self.btnA.addSubview(self.webViewA)
            self.webViewA.translatesAutoresizingMaskIntoConstraints = false
            self.webViewA.topAnchor.constraint(equalTo: self.btnA.topAnchor).isActive = true
            self.webViewA.rightAnchor.constraint(equalTo: self.btnA.rightAnchor).isActive = true
            self.webViewA.leftAnchor.constraint(equalTo: self.btnA.leftAnchor).isActive = true
            self.webViewA.bottomAnchor.constraint(equalTo: self.btnA.bottomAnchor).isActive = true
            self.webViewA.heightAnchor.constraint(equalTo: self.btnA.heightAnchor).isActive = true
            self.webViewA.uiDelegate = self
            self.webViewA.sizeToFit()
            self.webViewA.isUserInteractionEnabled = false
            
            if self.webViewB != nil {
                self.webViewB.removeFromSuperview()
            }
            self.webViewB = nil
            let customFrameB = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.btnB.frame.size.width, height: self.btnB.frame.size.height))
            self.webViewB = WKWebView (frame: customFrameB , configuration: self.webConfiguration)
            self.webViewB.isOpaque = false
            self.btnB.addSubview(self.webViewB)
            self.webViewB.translatesAutoresizingMaskIntoConstraints = false
            self.webViewB.topAnchor.constraint(equalTo: self.btnB.topAnchor).isActive = true
            self.webViewB.rightAnchor.constraint(equalTo: self.btnB.rightAnchor).isActive = true
            self.webViewB.leftAnchor.constraint(equalTo: self.btnB.leftAnchor).isActive = true
            self.webViewB.bottomAnchor.constraint(equalTo: self.btnB.bottomAnchor).isActive = true
            self.webViewB.heightAnchor.constraint(equalTo: self.btnB.heightAnchor).isActive = true
            self.webViewB.uiDelegate = self
            self.webViewB.sizeToFit()
            self.webViewB.isUserInteractionEnabled = false
        
            if self.webViewC != nil {
                self.webViewC.removeFromSuperview()
            }
            self.webViewC = nil
            let customFrameC = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.btnC.frame.size.width, height: self.btnC.frame.size.height))
            self.webViewC = WKWebView (frame: customFrameC , configuration: self.webConfiguration)
            self.webViewC.isOpaque = false
            self.btnC.addSubview(self.webViewC)
            self.webViewC.translatesAutoresizingMaskIntoConstraints = false
            self.webViewC.topAnchor.constraint(equalTo: self.btnC.topAnchor).isActive = true
            self.webViewC.rightAnchor.constraint(equalTo: self.btnC.rightAnchor).isActive = true
            self.webViewC.leftAnchor.constraint(equalTo: self.btnC.leftAnchor).isActive = true
            self.webViewC.bottomAnchor.constraint(equalTo: self.btnC.bottomAnchor).isActive = true
            self.webViewC.heightAnchor.constraint(equalTo: self.btnC.heightAnchor).isActive = true
            self.webViewC.uiDelegate = self
            self.webViewC.sizeToFit()
            self.webViewC.isUserInteractionEnabled = false
        
            if self.webViewD != nil {
                self.webViewD.removeFromSuperview()
            }
            self.webViewD = nil
            let customFrameD = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.btnD.frame.size.width, height: self.btnD.frame.size.height))
            self.webViewD = WKWebView (frame: customFrameD , configuration: self.webConfiguration)
            self.webViewD.isOpaque = false
            self.btnD.addSubview(self.webViewD)
            self.webViewD.translatesAutoresizingMaskIntoConstraints = false
            self.webViewD.topAnchor.constraint(equalTo: self.btnD.topAnchor).isActive = true
            self.webViewD.rightAnchor.constraint(equalTo: self.btnD.rightAnchor).isActive = true
            self.webViewD.leftAnchor.constraint(equalTo: self.btnD.leftAnchor).isActive = true
            self.webViewD.bottomAnchor.constraint(equalTo: self.btnD.bottomAnchor).isActive = true
            self.webViewD.heightAnchor.constraint(equalTo: self.btnD.heightAnchor).isActive = true
            self.webViewD.uiDelegate = self
            self.webViewD.sizeToFit()
            self.webViewD.isUserInteractionEnabled = false
            
            if self.webViewE != nil {
                self.webViewE.removeFromSuperview()
            }
            self.webViewE = nil
            let customFrameE = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.btnE.frame.size.width, height: self.btnE.frame.size.height))
            self.webViewE = WKWebView (frame: customFrameE , configuration: self.webConfiguration)
            self.webViewE.isOpaque = false
            self.btnE.addSubview(self.webViewE)
            self.webViewE.translatesAutoresizingMaskIntoConstraints = false
            self.webViewE.topAnchor.constraint(equalTo: self.btnE.topAnchor).isActive = true
            self.webViewE.rightAnchor.constraint(equalTo: self.btnE.rightAnchor).isActive = true
            self.webViewE.leftAnchor.constraint(equalTo: self.btnE.leftAnchor).isActive = true
            self.webViewE.bottomAnchor.constraint(equalTo: self.btnE.bottomAnchor).isActive = true
            self.webViewE.heightAnchor.constraint(equalTo: self.btnE.heightAnchor).isActive = true
            self.webViewE.uiDelegate = self
            self.webViewE.sizeToFit()
            self.webViewE.isUserInteractionEnabled = false
        }
    }
//    override func viewDidDisappear(_ animated: Bool) {
//            super.viewDidDisappear(true)
//            //self.removeFromParentViewController()
//            self.dismiss(animated: true, completion: nil)
//    }
    func getMathQuestions(){
        
        if config?.LANGUAGE_MODE == 1{
            apiExPeraforLang += "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))"
        }
        let selection = (isSubCat == true) ? "subcategory=\(catID)" : "category=\(catID)" //is it from subcategory OR direct category selection?
        let apiURL = selection + apiExPeraforLang //"category=525&language_id=15"
        self.getAPIData(apiName: "get_maths_questions", apiURL: apiURL,completion: {jsonObj in
            print("JSON",jsonObj)
            let status = jsonObj.value(forKey: "error") as! String
            if (status == "true") {
            }else{
                self.quesData.removeAll()
                if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                    for val in data{
                        self.quesData.append(QuestionMath.init(id: "\(val["id"]!)", question: "\(val["question"]!)", optionA: "\(val["optiona"]!)", optionB: "\(val["optionb"]!)", optionC: "\(val["optionc"]!)", optionD: "\(val["optiond"]!)", optionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "\(val["image"]!)", note: "\(val["note"]!)", quesType: "\(val["question_type"]!)"))
                    }                    
                    Apps.TOTAL_PLAY_QS = data.count
                    self.loadQuestion()
                }
            }
        })
    }
    //MARK: - Apps.ADV_TYPE = FB
    func rewardedVideoAd(_ rewardedVideoAd: FBRewardedVideoAd, didFailWithError error: Error) {
          print("Rewarded video ad failed to load \(error)")
      }

      func rewardedVideoAdDidLoad(_ rewardedVideoAd: FBRewardedVideoAd) {
          print("Video ad is loaded and ready to be displayed")
      }

      func rewardedVideoAdDidClick(_ rewardedVideoAd: FBRewardedVideoAd) {
          print("Video ad clicked")
      }

      func rewardedVideoAdVideoComplete(_ rewardedVideoAd: FBRewardedVideoAd) {
            var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
            score.coins = score.coins + Int(Apps.REWARD_COIN)!//4
            UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
            mainCoinCount.text = "\(score.coins)"
          
           timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
           timer.fire()
      }
      func showRewardedVideoAd() {
        if (rewardedVideoAd != nil) && rewardedVideoAd!.isAdValid {
            rewardedVideoAd!.show(fromRootViewController: self)
          }
      }
      func rewardedVideoAdWillClose(_ rewardedVideoAd: FBRewardedVideoAd) {
          print("The user clicked on the close button, the ad is just about to close")
      }

      func rewardedVideoAdWillLogImpression(_ rewardedVideoAd: FBRewardedVideoAd) {
          print("Rewarded Video impression is being captured")
      }
      func rewardedVideoAdServerRewardDidSucceed(_ rewardedVideoAd: FBRewardedVideoAd) {
          print("Rewarded video ad validated by server")
      }

      func rewardedVideoAdServerRewardDidFail(_ rewardedVideoAd: FBRewardedVideoAd) {
          print("Rewarded video ad not validated, or no response from server")
      }
    //MARK: Apps.ADV_TYPE = FB -
    //MARK: Apps.ADV_TYPE = ADMOB
    //Google AdMob & FB Adv
    func RequestForRewardAds(){
        if Apps.ADV_TYPE == "ADMOB" {
            GADRewardedAd.load(withAdUnitID: Apps.REWARD_AD_UNIT_ID, request: GADRequest()) { (ad, error) in
                  if let error = error {
                    print("Rewarded ad failed to load with error: \(error.localizedDescription)")
                    return
                  }
                  print("Loading Succeeded")
                  self.rewardedAd = ad
                  self.rewardedAd?.fullScreenContentDelegate = self
                }
        }else{
            rewardedVideoAd = FBRewardedVideoAd(placementID: Apps.REWARD_AD_UNIT_ID)
            rewardedVideoAd!.delegate = self
            rewardedVideoAd!.load()
        }
    }
    
    func watchAd() {
        if Apps.ADV_TYPE == "ADMOB" {
            if let ad = rewardedAd {
                 ad.present(fromRootViewController: self) {
                   let reward = ad.adReward
                   // TODO: Reward the user.
                    print("Reward received with currency: \(reward.type), amount \(reward.amount).")
                             var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
                            score.coins = score.coins + Int(Apps.REWARD_COIN)! //4
                            UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
                    self.mainCoinCount.text = "\(score.coins)"
                 }
            }else{
                let alert = UIAlertController(title: Apps.REWARD_AD_NOT_PRESENT_TITLE ,message: Apps.REWARD_AD_NOT_PRESENT_MSG,preferredStyle: .alert)
                let alertAction = UIAlertAction(title: Apps.OK,style: .cancel,handler: { _ in
                })
                alert.addAction(alertAction)
                self.present(alert, animated: false, completion: nil)//true
            }
        }else{
            if (rewardedVideoAd != nil) && rewardedVideoAd!.isAdValid {
                rewardedVideoAd!.show(fromRootViewController: self) //.showAd(fromRootViewController: self)
              }else{
                  let alert = UIAlertController(title: Apps.REWARD_AD_NOT_PRESENT_TITLE ,message: Apps.REWARD_AD_NOT_PRESENT_MSG ,preferredStyle: .alert)
                  let alertAction = UIAlertAction(title: Apps.OK,style: .cancel,handler: { _ in
                  })
                  alert.addAction(alertAction)
                  self.present(alert, animated: false, completion: nil)//true
              }
        }
    }

         // MARK: GADFullScreenContentDelegate
         func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
           print("Rewarded ad presented.")
         }

         func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
           print("Rewarded ad dismissed.")
         }

         func ad(_ ad: GADFullScreenPresentingAd,didFailToPresentFullScreenContentWithError error: Error) {
           print("Rewarded ad failed to present with error: \(error.localizedDescription).")
             let alert = UIAlertController(title: Apps.REWARD_AD_NOT_PRESENT_TITLE ,message: Apps.REWARD_AD_NOT_PRESENT_MSG ,preferredStyle: .alert)
             let alertAction = UIAlertAction(title: Apps.OK,style: .cancel,handler: { _ in
             })
             alert.addAction(alertAction)
             self.present(alert, animated: false, completion: nil)//true
         }
    //MARK: Apps.ADV_TYPE = ADMOB -
    
    @objc func ReloadFont(noti: NSNotification){
        resizeTextview()
    }
    
    func resizeTextview(){
        
        var getFont = UserDefaults.standard.float(forKey: "fontSize")
        if (getFont == 0){
            getFont = (deviceStoryBoard == "Ipad") ? 26 : 16
        }
//        lblQuestion.font = lblQuestion.font?.withSize(CGFloat(getFont))
//
//        lblQuestion.centerVertically()
        
        btnA.titleLabel?.font = btnA.titleLabel?.font?.withSize(CGFloat(getFont))
        btnB.titleLabel?.font = btnB.titleLabel?.font?.withSize(CGFloat(getFont))
        btnC.titleLabel?.font = btnC.titleLabel?.font?.withSize(CGFloat(getFont))
        btnD.titleLabel?.font = btnD.titleLabel?.font?.withSize(CGFloat(getFont))
        btnE.titleLabel?.font = btnE.titleLabel?.font?.withSize(CGFloat(getFont))
        
        btnA.resizeButton()
        btnB.resizeButton()
        btnC.resizeButton()
        btnD.resizeButton()
        btnE.resizeButton()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return questionImage
    }

    // resume timer when setting alert closed
    @objc func ResumeTimer(){
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    // Note only works when time has not been invalidated yet
    @objc func resetProgressCount() {
        DispatchQueue.main.async {
            self.buttons.forEach{$0.isUserInteractionEnabled = true}
             if self.timer != nil && self.timer.isValid{
                 self.timer.invalidate()
             }
            self.progressRing.innerTrackShapeLayer.strokeColor = Apps.defaultInnerColor.cgColor
            self.progressRing.progressLabel.textColor = Apps.BASIC_COLOR
           // self.zoomScale = 1
            self.zoomScroll.zoomScale = 1
            self.count = 0
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.incrementCount), userInfo: nil, repeats: true)
            self.timer.fire()
       }
    }
    
    @objc func incrementCount() {
        count += 0.1
        progressRing.progress = CGFloat(Apps.QUIZ_PLAY_TIME - count)
        if count >= 20{
              progressRing.innerTrackShapeLayer.strokeColor = Apps.WRONG_ANS_COLOR.cgColor
              progressRing.progressLabel.textColor = Apps.WRONG_ANS_COLOR
        }
        if (currentQuestionPos  < quesData.count && currentQuestionPos + 1 <= Apps.TOTAL_PLAY_QS ){
            if count >= Apps.QUIZ_PLAY_TIME { // set timer here
                print("val of count -- \(count) - total play quiz time - \(Apps.QUIZ_PLAY_TIME)")
                timer.invalidate()
                currentQuestionPos += 1
                   //mark it as wrong answer if user haven't selected any option from given 4/5 or 2 option
                falseCount += 1
                var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
                score.points = score.points - Apps.QUIZ_W_Q_POINTS
                UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
                self.PlaySound(player: &audioPlayer, file: "wrong")
                  loadQuestion()
          }
        }
    }
    
    @IBAction func settingButton(_ sender: Any) {
//        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
//        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier:"SettingsAlert") as! SettingsAlert
        myAlert.modalPresentationStyle = .overCurrentContext
        myAlert.isPlayView = true
        myAlert.isMathsQuiz = true
        self.present(myAlert, animated: true, completion: {
             self.timer.invalidate()
        })
    }
    
    @IBAction func backButton(_ sender: Any) {
        let alert = UIAlertController(title: Apps.EXIT_PLAY,message: "",preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))

        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            self.timer.invalidate()
          //  self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!)
            self.addPopTransition()
            self.navigationController?.popViewController(animated: false)
//            self.navigationController?.popViewController(animated: true)
        }))
        
        alert.view.tintColor = (Apps.APPEARANCE == "dark") ? UIColor.white : UIColor.black// change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //50 50 option select
    @IBAction func fiftyButton(_ sender: Any) {
        if(!opt_ft){
             var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
            
            if(score.coins < Apps.OPT_FT_COIN){
                // user does not have enough coins
                self.ShowAlertForNotEnoughCoins(requiredCoins: Apps.OPT_FT_COIN, lifelineName: "fifty")
            }else{
                // if user have coins
                var index = 0
                for button in buttons{
                          if button.tag == 0 && index < 2 { //To remove 3 options from 5, use 3 instead of 2 here
                          button.isHidden = true
                          index += 1
                      }
                }
                opt_ft = true
                //deduct coin for use lifeline and store it
                 score.coins = score.coins - Apps.OPT_FT_COIN
                 UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
                 mainCoinCount.text = "\(score.coins)"
            }
        }else{
            self.ShowAlert(title: Apps.LIFELINE_ALREDY_USED_TITLE, message: Apps.LIFELINE_ALREDY_USED)
        }
    }
    
    //skip option select
    @IBAction func SkipBtn(_ sender: Any) {
        if(!opt_sk){
            var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
            
            if(score.coins < Apps.OPT_SK_COIN){
                // user dose not have enough coins
                self.ShowAlertForNotEnoughCoins(requiredCoins: Apps.OPT_SK_COIN, lifelineName: "skip")
            }else{
                // if user have coins
                timer.invalidate()
                currentQuestionPos += 1
                loadQuestion()
                
                opt_sk = true
                //deduct coin for use lifeline and store it
                score.coins = score.coins - Apps.OPT_SK_COIN
                UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
                 mainCoinCount.text = "\(score.coins)"
            }
        }else{
            self.ShowAlert(title: Apps.LIFELINE_ALREDY_USED_TITLE, message: Apps.LIFELINE_ALREDY_USED)
        }
    }
    
    //Audios poll option select
    @IBAction func AudionsBtn(_ sender: Any) {
        if(!opt_au){
            var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
            
            if(score.coins < Apps.OPT_SK_COIN){
                // user dose not have enough coins
                self.ShowAlertForNotEnoughCoins(requiredCoins: Apps.OPT_AU_COIN, lifelineName: "audions")
            }else{
                // if user have coins
                var r1:Int,r2:Int,r3:Int,r4:Int,r5:Int
                
//                r1 = Int.random(in: 1 ... 96)
//                r2 = Int.random(in: 1 ... 97 - r1)
//                r3 = Int.random(in: 1 ... 98 - r1 - r2)
//                r5 = Int.random(in: 1 ... 98 - r1 - r2 - r3)
//                r4 = 100 - r1 - r2 - r3 - r5
                r1 = Int.random(in: 1 ... 96)
                r2 = Int.random(in: 1 ... 97 - r1)
                r3 = Int.random(in: 1 ... 98 - r1 - r2)
                r5 = Int.random(in: 1 ... 99 - r1 - r2 - r3)
                
                if Apps.opt_E == true {
                    r4 = 100 - r1 - r2 - r3 - r5
                }else{
                    r4 = 100 - r1 - r2 - r3 //- r5
                    r5 = 0
                }
                
                var randoms = [r1,r2,r3,r5,r4]
                randoms.sort(){$0 > $1}
                
                var index = 0
                for button in buttons{
                    if button.tag == 1{
                        drawCircle(btn: button, proVal: randoms[0])
                    }else{
                        index += 1
                        drawCircle(btn: button, proVal: randoms[index])
                    }
                }
                opt_au = true
        
                //deduct coin for use lifeline and store it
                score.coins = score.coins - Apps.OPT_AU_COIN
                UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
                mainCoinCount.text = "\(score.coins)"
            }
        }else{
            self.ShowAlert(title: Apps.LIFELINE_ALREDY_USED_TITLE, message: Apps.LIFELINE_ALREDY_USED)
        }
    }
    
    //reset timer option select
    @IBAction func ResetBtn(_ sender: Any) {
        if(!opt_re){
            var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
            
            if(score.coins < Apps.OPT_RES_COIN){
                // user dose not have enough coins
                self.ShowAlertForNotEnoughCoins(requiredCoins: Apps.OPT_RES_COIN, lifelineName: "reset")
            }else{
                // if user have coins
                timer.invalidate()
                resetProgressCount()
                opt_re = true
                //deduct coin for use lifeline and store it
                score.coins = score.coins - Apps.OPT_RES_COIN
                UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
                mainCoinCount.text = "\(score.coins)"
            }
        }else{
            self.ShowAlert(title: Apps.LIFELINE_ALREDY_USED_TITLE, message: Apps.LIFELINE_ALREDY_USED)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        clearColor()
    }
    
    @IBAction func BookMark(_ sender: Any) {
        
        if(self.bookmarkBtn.tag == 0){
//            let reQues = quesData[currentQuestionPos]
//            self.BookQuesList.append(QuestionWithE.init(id: reQues.id, question: reQues.question, optionA: reQues.optionA, optionB: reQues.optionB, optionC: reQues.optionC, optionD: reQues.optionD, optionE: reQues.optionE, correctAns: reQues.correctAns, image: reQues.image, level: "0", note: reQues.note, quesType: reQues.quesType))
//            bookmarkBtn.setBackgroundImage(UIImage(named: "book-on"), for: .normal)
//            bookmarkBtn.tag = 1
//            self.SetBookmark(quesID: reQues.id, status: "1", completion: {})
        }else{
            BookQuesList.removeAll(where: {$0.id == quesData[currentQuestionPos].id && $0.correctAns == quesData[currentQuestionPos].correctAns})
            bookmarkBtn.setBackgroundImage(UIImage(named: "book-off"), for: .normal)
            bookmarkBtn.tag = 0
            let reQues = quesData[currentQuestionPos]
            self.SetBookmark(quesID: reQues.id, status: "0", completion: {})
        }
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(BookQuesList), forKey: "booklist")
        
    }
    // right answer operation function
    func rightAnswer(btn:UIView){
        
        //make timer invalidate
        timer.invalidate()
        
        //score count
        trueCount += 1
       // trueLbl.text = "\(trueCount)"
       // progressBar.setProgress(Float(trueCount) / Float(Apps.TOTAL_PLAY_QS), animated: false)//true
        
        var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
        score.points = score.points + Apps.QUIZ_R_Q_POINTS
        UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
        
        btn.backgroundColor = Apps.RIGHT_ANS_COLOR
        btn.tintColor = UIColor.white
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.3
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: btn.center.x, y: btn.center.y - 5))
        animation.toValue = NSValue(cgPoint: CGPoint(x: btn.center.x, y: btn.center.y + 5))
        btn.layer.add(animation, forKey: "position")
        
        // sound
        self.PlaySound(player: &audioPlayer, file: "right")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // load next question after 1 second
            self.currentQuestionPos += 1 //increment for next question
            self.loadQuestion()
        })
    }
    
    // wrong answer operation function
    func wrongAnswer(btn:UIView?){
        //make timer invalidate
        timer.invalidate()
        
        //score count
        falseCount += 1
       // falseLbl.text = "\(falseCount)"
       // progressFalseBar.setProgress(Float(falseCount) / Float(Apps.TOTAL_PLAY_QS), animated: false) //true
        
        var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
        score.points = score.points - Apps.QUIZ_W_Q_POINTS
        UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
        
        btn?.backgroundColor = Apps.WRONG_ANS_COLOR
        btn?.tintColor = UIColor.white
        
        if Apps.ANS_MODE == "1"{
            //show correct answer
            for button in buttons{
                if button.titleLabel?.text == correctAnswer{
                     button.tag = 1
                }
                for button in buttons {
                    if button.tag == 1{
                        button.backgroundColor = Apps.RIGHT_ANS_COLOR
                        button.tintColor = UIColor.white
                        break
                    }
                }
            }
        }
        
        // sound
        self.PlaySound(player: &audioPlayer, file: "wrong")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // load next question after 1 second
            self.currentQuestionPos += 1 //increment for next question
            self.loadQuestion()
        })
    }
    
    func clearColor(views:UIView...){
        for view in views{
            DispatchQueue.main.async{
                view.isHidden = false
                view.backgroundColor = UIColor.white.withAlphaComponent(0.8)//UIColor.white // Apps.BASIC_COLOR
                view.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
            }
        }
    }
    
    // set question vcalue and its answer here
    @objc func loadQuestion() {
        // Show next question
        
        //speechSynthesizer.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!) //textToSpeech is not in use
        resetProgressCount() // reset timer
            
        if(currentQuestionPos  < quesData.count && currentQuestionPos + 1 <= Apps.TOTAL_PLAY_QS ) {
           
            let path = Bundle.main.bundlePath
            let baseURL = URL.init(fileURLWithPath: path)
            
            let fontColor: UIColor = .black
            let fontSize:Int = 30
           
            let endTags = "</div></body></html>"
            
            let startTags = "<!DOCTYPE html><html><head><script id=\"MathJax-script\" type=\"text/javascript\"  async src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js\"></script></head><body><div style='height:100%;display:flex;align-items:center;justify-content:center;font-size: \(fontSize)pt; color: \(fontColor);'>"
           
            if(quesData[currentQuestionPos].image == ""){
                self.setWebQuesViewLayout(self.mainQuestionView)
                sleep(2)
                let strJS = "\(startTags)\(self.quesData[self.currentQuestionPos].question)\(endTags)"
                DispatchQueue.main.async {
                    self.webView.loadHTMLString(strJS, baseURL: baseURL)
                    //hide some components
                    self.lblQuestion.isHidden = true
                    self.questionImage.isHidden = true
                }
            }else{
                self.setWebQuesViewLayout(self.lblQuestion)
                sleep(2)
                // if question has image
                let strJS = "\(startTags)\(self.quesData[self.currentQuestionPos].question)\(endTags)"
                DispatchQueue.main.async {
                    self.webView.loadHTMLString(strJS, baseURL: baseURL)
                    self.questionImage.loadImageUsingCache(withUrl: self.quesData[self.currentQuestionPos].image)
                    self.questionImage.layer.cornerRadius = 11
                    //show some components
                    self.lblQuestion.isHidden = false
                    self.questionImage.isHidden = false
                }
            }
            if(quesData[currentQuestionPos].optionE == "")
               {
                   Apps.opt_E = false
               }else{
                   Apps.opt_E = true
               }
               if Apps.opt_E == true {
                   clearColor(views: btnA,btnB,btnC,btnD,btnE)
                   DispatchQueue.main.async {
                       self.btnE.isHidden = false
                   }
                   buttons = [btnA,btnB,btnC,btnD,btnE]
                   DesignOptionButton(buttons: btnA,btnB,btnC,btnD,btnE)
                   self.SetViewWithoutShadow(views: btnA,btnB, btnC, btnD, btnE)
                   // enabled options button
                   MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD,btnE)
               }else{
                   clearColor(views: btnA,btnB,btnC,btnD)
                   DispatchQueue.main.async {
                       self.btnE.isHidden = true
                   }
                   buttons = [btnA,btnB,btnC,btnD]
                   DesignOptionButton(buttons: btnA,btnB,btnC,btnD)
                   self.SetViewWithoutShadow(views: btnA,btnB, btnC, btnD)
                   // enabled options button
                   MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD)
               }
            DispatchQueue.main.async {
                
                self.SetButtonOption(options: self.quesData[self.currentQuestionPos].optionA,self.quesData[self.currentQuestionPos].optionB,self.quesData[self.currentQuestionPos].optionC,self.quesData[self.currentQuestionPos].optionD,self.quesData[self.currentQuestionPos].optionE,self.quesData[self.currentQuestionPos].correctAns)
                
                let strOptionA = "\(startTags)\(self.btnA.currentTitle!)\(endTags)"//"\(startTags)\(self.quesData[self.currentQuestionPos].optionA)\(endTags)"
                self.webViewA.loadHTMLString(strOptionA, baseURL: baseURL)
                let strOptionB = "\(startTags)\(self.btnB.currentTitle!)\(endTags)"
                self.webViewB.loadHTMLString(strOptionB, baseURL: baseURL)
                let strOptionC = "\(startTags)\(self.btnC.currentTitle!)\(endTags)"
                self.webViewC.loadHTMLString(strOptionC, baseURL: baseURL)
                let strOptionD = "\(startTags)\(self.btnD.currentTitle!)\(endTags)"
                self.webViewD.loadHTMLString(strOptionD, baseURL: baseURL)
                let strOptionE = "\(startTags)\(self.btnE.currentTitle!)\(endTags)"
                self.webViewE.loadHTMLString(strOptionE, baseURL: baseURL)
            
                self.mainQuesCount.roundCorners(corners: [.topLeft,.topRight,.bottomRight,.bottomLeft], radius: 5)
                self.mainQuesCount.text = "\(self.currentQuestionPos + 1) / \(Apps.TOTAL_PLAY_QS)"
                self.mainScoreCount.text = "\((self.trueCount * Apps.QUIZ_R_Q_POINTS) - (self.falseCount * Apps.QUIZ_W_Q_POINTS))"
            }
        } else {
            self.ShowResultView()
        }
    }
    
    func setWebQuesViewLayout(_ container: UIView){
        DispatchQueue.main.async {
            if self.webView != nil {
                self.webView.removeFromSuperview()
            }
            self.webView = nil
            let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: container.frame.size.width, height: container.frame.size.height))
            self.webView = WKWebView (frame: customFrame , configuration: self.webConfiguration)
            self.webView.isOpaque = false
            container.addSubview(self.webView)
            self.webView.translatesAutoresizingMaskIntoConstraints = false
            if container == self.lblQuestion { //&& deviceStoryBoard != "Ipad"
                self.webView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
            }else{
                self.webView.topAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
            }
            self.webView.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
            self.webView.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
            self.webView.heightAnchor.constraint(equalTo: container.heightAnchor).isActive = true
          //  self.webView.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
            self.webView.uiDelegate = self
            self.webView.sizeToFit()
        }
    }
    func ShowResultView(){
        timer.invalidate()
        // If there are no more questions show the results
        let storyBoard:UIStoryboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let resultView:ResultsViewController = storyBoard.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
        resultView.playType = self.playType
        resultView.trueCount = trueCount
        resultView.falseCount = falseCount
        resultView.earnedPoints = (trueCount * Apps.QUIZ_R_Q_POINTS) - (falseCount * Apps.QUIZ_W_Q_POINTS)
        resultView.level = 0
        resultView.catID = self.catID
        resultView.isSubCat = self.isSubCat
        self.addTransition()
        self.navigationController?.pushViewController(resultView, animated: false)
//        self.navigationController?.pushViewController(resultView, animated: true)
    }
    var btnY = 0
      func SetButtonHeight(buttons:UIButton...){
          
          var minHeight = 50
          if deviceStoryBoard == "Ipad" { //UIDevice.current.userInterfaceIdiom
              minHeight = 110//90
          }else{
              minHeight = 50
          }
          self.scroll.setContentOffset(.zero, animated: false)
          
          let perButtonChar = (deviceStoryBoard == "Ipad") ? 45 : 25 //35
          let extraSpace: CGFloat = (deviceStoryBoard == "Ipad") ? 40 : 10
          btnY = Int(self.secondChildView.frame.height + self.secondChildView.frame.origin.y + extraSpace)
          
          for button in buttons{
              let btnWidth = button.frame.width
              let charCount = button.title(for: .normal)?.count
              
              let btnX = button.frame.origin.x
              
              let charLine = Int(charCount! / perButtonChar) + 1
              
              let extraHeight = (deviceStoryBoard == "Ipad") ? 40 : 20
              let btnHeight = charLine * extraHeight < minHeight ? minHeight : charLine * extraHeight
              
              let newFram = CGRect(x: Int(btnX), y: btnY, width: Int(btnWidth), height: btnHeight)
              btnY += btnHeight + 8
              
              button.frame = newFram
              
              button.titleLabel?.lineBreakMode = .byWordWrapping
              button.titleLabel?.numberOfLines = 0
          }
          let with = self.scroll.frame.width
          self.scroll.contentSize = CGSize(width: Int(with), height: Int(btnY))
      }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // set button option's
    var buttons:[UIButton] = []
    func SetButtonOption(options:String...){
        clickedButton.removeAll()
        var temp : [String]        
        if options.contains("") {
           print("true - \(options)")
           temp = ["a","b","c","d"]
           self.buttons = [btnA,btnB,btnC,btnD]
       }else{
             print("false - \(options)")
             temp = ["a","b","c","d","e"]
             self.buttons = [btnA,btnB,btnC,btnD,btnE]
       }
        var i = 0
        for button in buttons{
            button.setTitleColor(UIColor.clear, for: .normal) //to not show on screen - bcz already showing in Webview subview
           // button.setImage(SetClickedOptionView(otpStr: temp[i]).createImage(), for: .normal)
            i += 1
        }  
        let singleQues = quesData[currentQuestionPos]
        if singleQues.quesType == "2"{
            
            clearColor(views: btnA,btnB)
            MakeChoiceBtnDefault(btns: btnA,btnB)
            
            btnC.isHidden = true
            btnD.isHidden = true

            self.buttons = [btnA,btnB]
             temp = ["a","b"]
            //lifelines are not applicable for true/ false
            lifeLineView.alpha = 0
        }else{
            btnC.isHidden = false
            btnD.isHidden = false
            
            buttons.shuffle()
            // show lifelines incase were hidden in previous questions
            lifeLineView.alpha = 1
            lifeLineView.SetShadow()
        }
        
       let ans = temp
        var rightAns = ""
        if ans.contains("\(options.last!.lowercased())") { //last is answer here
            rightAns = options[ans.firstIndex(of: options.last!.lowercased())!]
        }else{
            rightAnswer(btn: btnA)
        }
       
        var index = 0
        for button in buttons{
            button.setTitle(options[index], for: .normal)
            if options[index] == rightAns{
                button.tag = 1
                let ans = button.currentTitle
                correctAnswer = ans!
                print(correctAnswer)
            }else{
                button.tag = 0
            }
            button.addTarget(self, action: #selector(ClickButton), for: .touchUpInside)
            button.addTarget(self, action: #selector(ButtonDown), for: .touchDown)
            index += 1
        }
       self.SetButtonHeight(buttons: btnA,btnB,btnC,btnD,btnE) //SetButtonHeight(buttons: btnA,btnB,btnC,btnD,btnE,view: secondChildView, scroll: scroll) //
    }
    // option buttons click action
    @objc func ClickButton(button:UIButton){
        buttons.forEach{$0.isUserInteractionEnabled = false}
        if clickedButton.first?.title(for: .normal) == button.title(for: .normal){
            if button.tag == 1{
                rightAnswer(btn: button)
            }else{
                wrongAnswer(btn: button)
            }
        }
    }
    
    var clickedButton:[UIButton] = []
    @objc func ButtonDown(button:UIButton){
        clickedButton.append(button)
    }
    
    // set default to four choice button
    func MakeChoiceBtnDefault(btns:UIButton...){
        for btn in btns {
            DispatchQueue.main.async {
                btn.isEnabled = true
                btn.resizeButton()
                btn.subviews.forEach({
                    if($0.tag == 11){
                        $0.removeFromSuperview()
                    }
                    //find if there is any circular progress on option button and remove it
                    for calayer in (btn.layer.sublayers)!{
                        if calayer.name == "circle" {
                            calayer.removeFromSuperlayer()
                        }
                    }
                })
            }
        }
    }
        
    // draw circle for audions poll lifeline
    func drawCircle(btn: UIButton, proVal: Int){
        DispatchQueue.main.async {
            let progRing = CircularProgressBar(radius: 20, position: CGPoint(x: btn.frame.size.width - 25, y: (btn.frame.size.height )/2), innerTrackColor: Apps.defaultInnerColor, outerTrackColor: Apps.defaultOuterColor, lineWidth: 5,progValue: 100, isAudience: true)
            progRing.name = "circle"
            progRing.progressLabel.numberOfLines = 1;
            progRing.progressLabel.minimumScaleFactor = 0.6;
            progRing.progressLabel.adjustsFontSizeToFitWidth = true;
            
            btn.layer.addSublayer(progRing)
            var count:CGFloat = 0
            Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
                count += 1
                progRing.progressManual = count
                if count >= CGFloat(proVal){
                   timer.invalidate()
                }
            }
        }
    }
    
    //show alert for not enough coins
    func ShowAlertForNotEnoughCoins(requiredCoins:Int, lifelineName:String){
        self.timer.invalidate()
        let msgTxt = !UserDefaults.standard.bool(forKey: "adRemoved") ? "\(Apps.NEED_COIN_MSG1) \(requiredCoins) \(Apps.NEED_COIN_MSG2)\n \(Apps.NEED_COIN_MSG3)" : "\(Apps.NEED_COIN_MSG1) \(requiredCoins) \(Apps.NEED_COIN_MSG2)" //RemoveAds
        let alert = UIAlertController(title: Apps.MSG_ENOUGH_COIN, message: msgTxt, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: Apps.SKIP, style: UIAlertAction.Style.cancel, handler: {action in
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.incrementCount), userInfo: nil, repeats: true)
            self.timer.fire()
        }))
        if !UserDefaults.standard.bool(forKey: "adRemoved") { //RemoveAds
            alert.addAction(UIAlertAction(title: Apps.WATCH_VIDEO, style: .default, handler: { action in
                self.watchAd()
                self.callLifeLine = lifelineName
            }))
        }
        self.present(alert, animated: false)
    }
}
