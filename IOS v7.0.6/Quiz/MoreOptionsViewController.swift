import Foundation
import UIKit
import AVFoundation
import GoogleMobileAds
import FBAudienceNetwork
import Firebase

class MoreOptionsViewController: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var showUserStatistics: UIButton!
    @IBOutlet weak var showBookmarks: UIButton!
    @IBOutlet weak var showNotifications: UIButton!
    @IBOutlet weak var showInviteFrnd: UIButton!
    @IBOutlet weak var showInstructions: UIButton!
    @IBOutlet weak var showAboutUs: UIButton!
    @IBOutlet weak var showTermsOfService: UIButton!
    @IBOutlet weak var showPrivacyPolicy: UIButton!
    @IBOutlet weak var chngDeviceLanguage: UIButton!
    @IBOutlet weak var logOutbtn: UIButton!

    var audioPlayer : AVAudioPlayer!
    var backgroundMusicPlayer: AVAudioPlayer!
    
    var interstitialAd : GADInterstitialAd?
    var interstitialAdFB : FBInterstitialAd?
    
    var controllerName:String = ""
    
    var dUser:User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            print("user details \(dUser!) ")
            logOutbtn.alpha = 1
        }else{
            logOutbtn.alpha = 0
        }
                
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 600)
        RequestInterstitialAd()
    }
    
    override func viewDidLayoutSubviews() {
        // calll button design button and pass button varaible those buttons nedd to be design
        self.DesignButton(btns: showUserStatistics,showBookmarks,showInstructions,showNotifications,showInviteFrnd,showAboutUs,showPrivacyPolicy,showTermsOfService,logOutbtn,chngDeviceLanguage)
    }
    // make button custom design function
    func DesignButton(btns:UIButton...){
        for btn in btns {
            btn.layer.cornerRadius = 10
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        addTransitionAndPopViewController(.fromRight)
    }
    @IBAction func userStatistics(_ sender: Any) {
        self.controllerName = "UserStatistics"
        
        let myNewView=UIView(frame: CGRect(x: 10, y: 100, width: 300, height: 200))
                // Add UIView as a Subview
                self.view.addSubview(myNewView)
        
        if Apps.ADV_TYPE == "ADMOB"{
            if let ad = interstitialAd {
               ad.present(fromRootViewController: self)
             }else{
                presentViewController("UserStatistics")
            }
        }else{
            if let ad = interstitialAdFB {
                ad.show(fromRootViewController: self)
             }else{
                presentViewController("UserStatistics")
            }
        }
    }
    
    @IBAction func bookmarks(_ sender: Any) {
        self.controllerName = "BookmarkView"
      
        if Apps.ADV_TYPE == "ADMOB"{
            if let ad = interstitialAd {
               ad.present(fromRootViewController: self)
             }else{
                 presentViewController( "BookmarkView")
            }
        }else{
            if let ad = interstitialAdFB {
                ad.show(fromRootViewController: self)
             }else{
                 presentViewController( "BookmarkView")
            }
        }
    }
    
    @IBAction func notifications(_ sender: Any) {
        self.controllerName = "NotificationsView"
     
        if Apps.ADV_TYPE == "ADMOB"{
            if let ad = interstitialAd {
               ad.present(fromRootViewController: self)
             }else{
                 presentViewController( "NotificationsView")
            }
        }else{
            if let ad = interstitialAdFB {
                ad.show(fromRootViewController: self)
             }else{
                 presentViewController( "NotificationsView")
            }
        }
    }
    
    @IBAction func inviteFriends(_ sender: Any) {
        presentViewController("ReferAndEarn")
    }
    
    @IBAction func instructions(_ sender: Any) {
        presentViewController("instructions")
    }
    
    @IBAction func aboutUs(_ sender: Any) {
        self.modalTransitionStyle = .flipHorizontal
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "AboutUsView")
        self.addTransition()
        self.navigationController?.pushViewController(viewCont, animated: false)
    }
    
    @IBAction func termsOfService(_ sender: Any) {
        self.modalTransitionStyle = .flipHorizontal
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "TermsView")
        self.addTransition()
        self.navigationController?.pushViewController(viewCont, animated: false)
    }
    
    @IBAction func privacyPolicy(_ sender: Any) {
        self.modalTransitionStyle = .flipHorizontal
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "PrivacyView")
        self.addTransition()
        self.navigationController?.pushViewController(viewCont, animated: false)
    }
    
    @IBAction func changeDeviceLanguage(_ sender: Any) {
    }
    
    @IBAction func logOutButton(_ sender: Any){
        logOutUserAlert(self.dUser!)
    }
    
    //social media Links
    @IBAction func connectOnYT(_ sender: Any) {
        let url = NSURL(string: Apps.SOCIAL_YT)
        UIApplication.shared.open(url! as URL)
    }
    
    @IBAction func connectOnIG(_ sender: Any) {
        let url = NSURL(string: Apps.SOCIAL_IG)
        UIApplication.shared.open(url! as URL)
    }
    
    @IBAction func connectOnFB(_ sender: Any) {
        let url = NSURL(string: Apps.SOCIAL_FB)//to open in app directly -  "fb://profile/wrteam.developers")
        UIApplication.shared.open(url! as URL)
    }
        
    //Google AdMob - FB
    func RequestInterstitialAd() {
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
    func presentViewController (_ identifier : String) {
        //click sound
        self.PlaySound(player: &audioPlayer, file: "click")
        self.Vibrate() // make device vibrate
        if (identifier == "UserStatistics") || (identifier == "UpdateProfileView") || (identifier == "ReferAndEarn") || (identifier == "BookmarkView") {
            //print("it worked for login user")
            if UserDefaults.standard.bool(forKey: "isLogedin"){
                let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: identifier)
                self.addTransition()
                self.navigationController?.pushViewController(viewCont, animated: false)
            }else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else {
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: identifier)
            self.addTransition()
            self.navigationController?.pushViewController(viewCont, animated: false)
        }
    }
}
extension MoreOptionsViewController : GADFullScreenContentDelegate{

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd){
    if self.controllerName == "UserStatistics"{
        presentViewController("UserStatistics")
        RequestInterstitialAd()
    }else if self.controllerName == "BookmarkView"{
        presentViewController("BookmarkView")
        RequestInterstitialAd()
    }else if self.controllerName == "NotificationsView"{
        presentViewController("NotificationsView")
        RequestInterstitialAd()
    }else{
        addPopTransition()
        self.navigationController?.popViewController(animated: false)
    }
}
    override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
    }
}

extension MoreOptionsViewController : FBInterstitialAdDelegate{
    internal func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        print("Ad is loaded and ready to be displayed")
        if interstitialAd != nil && interstitialAd.isAdValid {
            // You can now display the full screen ad using this code:
            interstitialAd.show(fromRootViewController: self)
        }
    }
 func interstitialAdWillLogImpression(_ interstitialAd: FBInterstitialAd) {
        print("The user sees the adv")
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
     if self.controllerName == "UserStatistics"{
         presentViewController("UserStatistics")
         RequestInterstitialAd()
     }else if self.controllerName == "BookmarkView"{
         presentViewController("BookmarkView")
         RequestInterstitialAd()
     }else if self.controllerName == "NotificationsView"{
         presentViewController("NotificationsView")
         RequestInterstitialAd()
     }
    }
    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
       //Present respected View controller if ad fails
        if self.controllerName == "UserStatistics"{
            presentViewController("UserStatistics")
        }else if self.controllerName == "BookmarkView"{
            presentViewController("BookmarkView")
        }else if self.controllerName == "NotificationsView"{
            presentViewController("NotificationsView")
        }
        print("Ad failed to load \(error)")
    }
}
