import UIKit
import GoogleMobileAds
import FBAudienceNetwork

class NotificationsView : UIViewController, UITableViewDelegate, UITableViewDataSource,GADBannerViewDelegate,FBAdViewDelegate {
    
    @IBOutlet var tableView: UITableView!

     @IBOutlet weak var bannerView: GADBannerView!
     var adView: FBAdView?
    
    var NotificationList: [Notifications] = []
    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //clear notification badges
               if Apps.badgeCount > 0 {
                   Apps.badgeCount = 0
                   UserDefaults.standard.set(Apps.badgeCount, forKey: "badgeCount")
               }
        
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
            tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.frame.size.height + bannerView.frame.size.height)
            print("Ads Removed !!")
        }
        
        if (UserDefaults.standard.value(forKey: "notification") != nil){
                NotificationList = try! PropertyListDecoder().decode([Notifications].self,from:(UserDefaults.standard.value(forKey: "notification") as? Data)!)
           }        
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
    //MARK:  Apps.ADV_TYPE = ADMOB
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
          print("Banner loaded successfully")
      }
    private func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: NSError) {
          print("Fail to receive ads")
          print(error)
      }
    //MARK:  Apps.ADV_TYPE = ADMOB -
    @IBAction func backButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            self.navigationController?.popToViewController( (self.navigationController?.viewControllers[1]) as! HomeScreenController, animated: true)
        }
    }
        
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         
        if NotificationList.count == 0{
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = Apps.NO_NOTIFICATION
            noDataLabel.textColor     = Apps.BASIC_COLOR
            noDataLabel.textAlignment = .center
            noDataLabel.font = noDataLabel.font?.withSize(deviceStoryBoard == "Ipad" ? 25 : 15)
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        print(NotificationList.count)
        return NotificationList.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cellIdentifier = NotificationList[indexPath.row].img != "" ? "NotifyCell" : "NotifyCellNoImage"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell  else {
            fatalError("The dequeued cell is not an instance.")
        }
        cell.qstn.text = NotificationList[indexPath.row].title

        cell.ansr.text = NotificationList[indexPath.row].msg
        if(NotificationList[indexPath.row].img != "") {
            let url: String =  self.NotificationList[indexPath.row].img
              DispatchQueue.main.async {
                 cell.bookImg.contentMode = .scaleAspectFit
                cell.bookImg.loadImageUsingCache(withUrl: url)
             }
        }
        checkForValues(NotificationList.count)
        
        print("indexpath value - \(indexPath.row) - color value - \(Apps.arrColors1[indexPath.row]!)")
        cell.bookView.layer.cornerRadius = 10
        return cell
    }
    //set height for specific cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = CGFloat()
        if NotificationList[indexPath.row].img != ""{
            height = 130
        }else{
            height = 80
        }
       // print(NotificationList[indexPath.row].msg.count)
        if NotificationList[indexPath.row].msg.count <= 45 {
           height = height + 5
       } else if NotificationList[indexPath.row].msg.count <= 70 {
           height = height + 20
       } else if NotificationList[indexPath.row].msg.count <= 145 {
           height = height + 60
       } else if NotificationList[indexPath.row].msg.count > 145 {
           height = height + 180
       }
        return height
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
}
extension UIImageView{
    func resize(toWidth scaledToWidth: CGFloat) -> UIImage {
            let image = self
            let oldWidth = image.frame.width
            let scaleFactor = scaledToWidth / oldWidth
            let newHeight = image.frame.height * scaleFactor
            let newWidth = oldWidth * scaleFactor
            let scaledSize = CGSize(width:newWidth, height:newHeight)
            image.contentMode = .scaleAspectFit
            UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0)
            image.draw(CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return scaledImage!
        }
}
