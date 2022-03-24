import UIKit
import GoogleMobileAds
import FBAudienceNetwork

class UserStatisticsView: UIViewController, GADBannerViewDelegate, FBAdViewDelegate {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var attendQuesLabel: UILabel!
    @IBOutlet weak var correctQuesLabel: UILabel!
    @IBOutlet weak var inCorrectQuesLabel: UILabel!
    @IBOutlet weak var circleProgView: UIView!
    @IBOutlet weak var rightPerLabel: UILabel!
    @IBOutlet weak var wrongPerLabel: UILabel!
    
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var viewChart: UIView!
    
    @IBOutlet weak var bannerView: GADBannerView!
     var adView: FBAdView?
    
    var userDefault:User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !UserDefaults.standard.bool(forKey: "adRemoved") { //RemoveAds
            if Apps.ADV_TYPE == "ADMOB" {
                // Google AdMob Banner
                bannerView.adUnitID = Apps.BANNER_AD_UNIT_ID
                bannerView.rootViewController = self
                let request = GADRequest()
                GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
                bannerView.load(request)                
            }else{
                adView = FBAdView(
                    placementID: Apps.BANNER_AD_UNIT_ID,
                           adSize: kFBAdSize320x50,
                           rootViewController: self)
                adView!.frame = CGRect(x: 0, y: 0, width: self.bannerView.frame.width, height: self.bannerView.frame.height)
                adView!.delegate = self
                adView!.loadAd()
            }
        }else{
            bannerView.isHidden = true
            // no need to increase frame size here
            print("Ads Removed !!")
        }
        
        userDefault = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        print("user data-\(String(describing: userDefault))")
        userName.text = "\(userDefault!.name)"
       
        self.userImage.contentMode = .scaleAspectFill
        userImage.clipsToBounds = true
       
        userImage.layer.masksToBounds = true
        userImage.layer.borderWidth = 1
        userImage.layer.borderColor = UIColor.white.cgColor
        
        DispatchQueue.main.async {
            if(self.userDefault!.image != ""){
                self.userImage.loadImageUsingCache(withUrl: self.userDefault!.image)
            }
        }
        
        //get score & coins from server
              if(Reachability.isConnectedToNetwork()){
                let apiURL = "id=\(userDefault!.userID)"
                  self.getAPIData(apiName: "get_user_by_id", apiURL: apiURL,completion: getUserData)
              }else{
                  ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
              }
        
        //get data from server
              if(Reachability.isConnectedToNetwork()){
                  let apiURL = "user_id=\(userDefault!.userID)"
                  self.getAPIData(apiName: "get_users_statistics", apiURL: apiURL,completion: LoadData)
                  
              }else{
                  ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
              }
        
        viewProfile.SetShadow()
    }
    override func viewDidLayoutSubviews() {
        userImage.layer.cornerRadius = userImage.frame.height / 2
        viewChart.layer.cornerRadius = 10
    }
    //MARK: - Apps.ADV_TYPE = FB
    func adViewDidClick(_ adView: FBAdView) {
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
             bannerView.addSubview(adView!)
         }
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
    //MARK:  Apps.ADV_TYPE = ADMOB -
    //load user data here
    func getUserData(jsonObj:NSDictionary){
        print(jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            DispatchQueue.main.async {
                    self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
            }
        }else{
            if let data = jsonObj.value(forKey: "data") as? [String:Any] {
                print(data)
                DispatchQueue.main.async {
                    let score = Int("\(data["all_time_score"]!)")
                    self.scoreLabel.text = "\(score!)"
                    let coins = Int("\(data["coins"]!)")
                    self.coinsLabel.text = "\(coins!)"
                    UserDefaults.standard.set(try? PropertyListEncoder().encode(UserScore.init(coins: coins!, points: score!)), forKey: "UserScore")
                    let rank = Int("\(data["all_time_rank"]!)")
                   self.rankLabel.text = "\(rank!)"
                }
            }
        }
    }
    //load data here
    func LoadData(jsonObj:NSDictionary){
        print("User stats Response - ",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            DispatchQueue.main.async {
                    self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )

            }
        }else{
            //get data for category
            if let data = jsonObj.value(forKey: "data") as? [String:Any] {
                print(data)
                DispatchQueue.main.async {
                    let ques = Int("\(data["questions_answered"]!)")
                    let corr = Int("\(data["correct_answers"]!)")
                    
                    self.attendQuesLabel.text = "\(ques!)"
                    self.correctQuesLabel.text = "\(corr!)"
                    self.inCorrectQuesLabel.text = "\(ques! - corr!)"
                               
                    let xPosition = self.circleProgView.frame.width / 2
                    let yPosition = self.circleProgView.frame.height / 2
                    let position = CGPoint(x: xPosition, y: yPosition - 15)
                    
                    var prog_radius: CGFloat = 35
                    if deviceStoryBoard == "Ipad" {
                        prog_radius = 55
                    }
                    let progressRing = CircularProgressBar(radius: prog_radius, position: position, innerTrackColor: .green, outerTrackColor: .systemPink, fillColor: .white, lineWidth: 24)
                    self.circleProgView.layer.addSublayer(progressRing)
                    progressRing.progressValue = CGFloat(Float(corr! * 100) / Float(ques!))
                    
                    self.rightPerLabel.text = "\(Int(CGFloat(Float(corr! * 100) / Float(ques!))))%"
                    self.wrongPerLabel.text = "\(Int(100 - (CGFloat(Float(corr! * 100) / Float(ques!)))))%"
                    let rightPer = roundf(Float(corr! * 100) / Float(ques!))
                    let wrongPer = floorf(Float(100 - (CGFloat(Float(corr! * 100) / Float(ques!)))))
                    self.rightPerLabel.text = "\(Int(rightPer))%"
                    self.wrongPerLabel.text = "\(Int(wrongPer))%"
                }
            }
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        addPopTransition()
        self.navigationController?.popToRootViewController(animated: false)
    }
}
