import UIKit
import AVFoundation
import GoogleMobileAds
import FBAudienceNetwork

//var scoreLevel = 0
var mainCatID = 0

var numberOfItems: Int = 10 //6//
    
//var arrColors1 = [UIColor(named: "purple1"),UIColor(named: "sky1"),UIColor(named: "orange1"),UIColor(named: "green1"),UIColor(named: "pink1"),UIColor(named: "blue1")]
//var arrColors2 = [UIColor(named: "purple2"),UIColor(named: "sky2"),UIColor(named: "orange2"),UIColor(named: "green2"),UIColor(named: "pink2"),UIColor(named: "blue2")]

//var tintArr = ["purple2", "sky2","orange2","green2","blue2","pink2"] //NOTE: arrColors1 & arrColors2 & tintArr - arrays should have same values/count

class LevelView: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout ,GADBannerViewDelegate ,FBAdViewDelegate { //UITableViewDelegate, UITableViewDataSource
    
//    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var adBannerView: GADBannerView!
   // @IBOutlet weak var adContainer: UIView!
    var adView: FBAdView?
    
    var maxLevel = 0
    var catID = 0
    var mainCatid = 0
    var questionType = "sub"
    var unLockLevel =  0
    var quesData: [QuestionWithE] = []
    
    var numberOfLevels = 10
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var audioPlayer : AVAudioPlayer!
    var sysConfig:SystemConfiguration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForValues(maxLevel) //numberOfItems
        
//        tableView.delegate = self
//        tableView.dataSource = self
        
        if !UserDefaults.standard.bool(forKey: "adRemoved") { //RemoveAds
            if Apps.ADV_TYPE == "ADMOB" {
                adBannerView.adUnitID = Apps.BANNER_AD_UNIT_ID
                adBannerView.rootViewController = self
                let request = GADRequest()
                // request.testDevices = Apps.AD_TEST_DEVICE
                //        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
                adBannerView.load(request)
            }else{
                adView = FBAdView(
                    placementID: Apps.BANNER_AD_UNIT_ID,
                           adSize: kFBAdSize320x50,
                           rootViewController: self)
                adView!.frame = CGRect(x: 0, y: 0, width: self.adBannerView.frame.width, height: self.adBannerView.frame.height) //adContainer
                adView!.delegate = self
                adView!.loadAd()
            }            
        }else{
            adBannerView.isHidden = true
            collectionView.frame = CGRect(x: collectionView.frame.origin.x, y: collectionView.frame.origin.y, width: collectionView.frame.size.width, height: collectionView.frame.size.height + adBannerView.frame.size.height)
            print("Ads Removed !!")
        }
        
        // apps level lock unlock, no need level lock unlock remove this code
        print(UserDefaults.standard.value(forKey:"\(questionType)\(catID)") ?? "no data")
        if UserDefaults.standard.value(forKey:"\(questionType)\(catID)") != nil {
            unLockLevel = Int(truncating: UserDefaults.standard.value(forKey:"\(questionType)\(catID)") as! NSNumber)
            print("unlocklevel value is - \(unLockLevel)")
        }else{
            print("userdefaults value is nil - unlocklevel value is - \(unLockLevel)")
        }
        
        if UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) != nil {
            sysConfig = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        }
         
//        self.tableView.isHidden = true
        self.collectionView.isHidden = true
        if UserDefaults.standard.bool(forKey: "isLogedin"){
                 self.GetUserLevel()
        }else{
//            self.tableView.isHidden = false
//            self.tableView.reloadData()
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
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
//             adContainer.addSubview(adView!)
             adBannerView.addSubview(adView!)
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
         
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
//        if !isInitial{
//            self.tableView.reloadData()
//        }
    }
    
//    func checkForValues(_ diff : Int){
//        if Apps.arrColors1.count < numberOfItems{
//            let dif = numberOfItems - (Apps.arrColors1.count - 1)
//            print(dif)
//            for i in 0...dif{
//                Apps.arrColors1.append(Apps.arrColors1[i])
//                Apps.arrColors2.append(Apps.arrColors2[i])
//                Apps.tintArr.append(Apps.tintArr[i])
//            }
//        }
//    }
    
    @IBAction func backButton(_ sender: Any) {
        //check if user entered in this view directly from appdelegate ? if Yes then goTo Home page otherwise just go back from notification view
        if self == UIApplication.shared.windows.first!.rootViewController { //keyWindow?
            addPopTransition()
            self.navigationController?.popToRootViewController(animated: false) //true
        }else{
            addPopTransition()
            self.navigationController?.popViewController(animated: false)
//            self.navigationController?.popViewController(animated: true)
        }
    }
    
     
    @IBAction func settingButton(_ sender: Any) {
       // let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
//        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//        self.present(myAlert, animated: true, completion: nil)
        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier:"SettingsAlert")
        myAlert.modalPresentationStyle = .overCurrentContext
        self.present(myAlert, animated: true, completion: nil)
    }
     
    
    @IBAction func unwindLevel(for unwindSegue: UIStoryboardSegue) {}
    // number of rows in table view
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if maxLevel == 0{
//            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
//            noDataLabel.text          = Apps.LEVET_NOT_AVAILABEL
//            noDataLabel.textColor     = Apps.BASIC_COLOR //(Apps.APPEARANCE == "dark") ? UIColor.white : UIColor.black
//            noDataLabel.textAlignment = .center
//            tableView.backgroundView  = noDataLabel
//            tableView.separatorStyle  = .none
//        }
//        return maxLevel
//    }
    
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        maxLevel//numberOfLevels //10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! levelCell
       // print("indexpath row value -- \(indexPath.row) --  total count of array - \(Apps.arrColors1.count) -- total count of cells - \(maxLevel)")
        gridCell.levelNumber.text = "\(indexPath.row + 1)"
        gridCell.levelNumber.textColor = UIColor.black
        gridCell.levelTxt.textColor = UIColor.black
//        gridCell.circleImgView.image = UIImage(named: "circle")
//        gridCell.circleImgView.tintColor = UIColor.init(named: Apps.tintArr[indexPath.row])
        if (self.unLockLevel > indexPath.row){ //unlocked & played
//            if deviceStoryBoard == "Ipad"{
               // gridCell.lockButton.setBackgroundImage(UIImage(named: "unlock"), for: .normal)
//            }else{
//                gridCell.lockButton.setImage(UIImage(named: "unlock"), for: .normal)
                gridCell.lockButton.alpha = 0
//            }
            gridCell.lockButton.tintColor = UIColor.gray
        }else if (self.unLockLevel >= indexPath.row){ //unlocked but not played/Finished yet
//            if deviceStoryBoard == "Ipad"{
               // gridCell.lockButton.setBackgroundImage(UIImage(named: "unlock"), for: .normal)
//            }else{
//                gridCell.lockButton.setImage(UIImage(named: "unlock"), for: .normal)
                gridCell.lockButton.alpha = 0
//            }
            gridCell.lockButton.tintColor = Apps.BASIC_COLOR
        }else{
//            if deviceStoryBoard == "Ipad"{
//                gridCell.lockButton.setBackgroundImage(UIImage(named: "lock"), for: .normal)
//                gridCell.lockButton.alpha = 1
//            }else{
                gridCell.lockButton.setImage(UIImage(named: "lock"), for: .normal)
                gridCell.lockButton.alpha = 1
//            }
            gridCell.lockButton.tintColor = Apps.BASIC_COLOR
        }
        //if level is completed successfully - set it's text and image to grey To mark that levels as done
        if (unLockLevel >= 0 && indexPath.row < unLockLevel) { //<=
            //print("if values - \(unLockLevel) - \(indexPath.row) - \(gridCell.levelNumber.text!)")
            gridCell.levelNumber.textColor = Apps.LEVEL_TEXTCOLOR
            gridCell.levelTxt.textColor = Apps.LEVEL_TEXTCOLOR
//            if deviceStoryBoard == "Ipad"{
                //gridCell.lockButton.setBackgroundImage(UIImage(named: "unlock"), for: .normal)
//            }else{
//                gridCell.lockButton.setImage(UIImage(named: "unlock"), for: .normal)
                gridCell.lockButton.alpha = 0
//            }
            gridCell.lockButton.tintColor = UIColor.gray
//        }else{
//            print("else values - \(unLockLevel) - \(indexPath.row) - \(String(describing: gridCell.levelNumber.text))")
        }
        
        //gridCell.lockButton.setImage(UIImage(named: "lock"), for: .normal)
        gridCell.layer.cornerRadius = 25//(gridCell.bgView.frame.width * 0.6 * 0.8) / 2 //0.67
        gridCell.layer.masksToBounds = true
        gridCell.bgView.alpha = 0
        
//        gridCell.backgroundColor = .clear
//        gridCell.bgView.layer.cornerRadius = 25//(gridCell.bgView.frame.width * 0.6 * 0.8) / 2 //0.67
//        gridCell.bgView.layer.masksToBounds = true
//        gridCell.bgView.layer.borderColor = UIColor.lightGray.cgColor
//        gridCell.bgView.layer.borderWidth = 1
//        gridCell.setCellShadow()
        
        gridCell.lockButton.frame = gridCell.bgView.frame
        gridCell.lockButton.layer.cornerRadius = 25 //set it same as value of gridCell.bgView.layer.cornerRadius
//        gridCell.lockButton.layer.masksToBounds = true

        
        return gridCell
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//            return 5 //horizontal spacing / diff btwn 2 rows
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 5 //vertical spacing / diff btwn 2 columns //No effect //depend on width mostly
//    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                               
            let noOfCellsInRow = 3

            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

            let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1)

            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
            return CGSize(width: size, height: size)
        //return CGSize(width: 130, height: 130) //138//130//124
    }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print("clicked cell number \(indexPath.row)")
            
            if (self.unLockLevel >= indexPath.row){ //>
                
               // let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
                viewCont.playType = "main"
                viewCont.maxLevel = self.maxLevel
                viewCont.catID = self.catID
                viewCont.level = indexPath.row + 1
                viewCont.questionType = self.questionType
                
                self.isInitial = false
                self.PlaySound(player: &audioPlayer, file: "click") // play sound
                self.Vibrate() // make device vibrate
                self.quesData.removeAll()
                var apiURL = ""
                if(questionType == "main"){
                    apiURL = "level=\(indexPath.row + 1)&category=\(catID)"
                }else{
                    apiURL = "level=\(indexPath.row + 1)&subcategory=\(catID)"
                }
                if sysConfig.LANGUAGE_MODE == 1 { //sysConfig.LANGUAGE_MODE != nil && 
                    let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
                    apiURL += "&language_id=\(langID)"
                }
                self.getAPIData(apiName: "get_questions_by_level", apiURL: apiURL,completion: {jsonObj in
                    print("JSON",jsonObj)
                    let status = jsonObj.value(forKey: "error") as! String
                    if (status == "true") {
                        DispatchQueue.main.async {
                            self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                        }                        
                    }else{
                        //get data for category
                        self.quesData.removeAll()
                        if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                            for val in data{
                                self.quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", optionA: "\(val["optiona"]!)", optionB: "\(val["optionb"]!)", optionC: "\(val["optionc"]!)", optionD: "\(val["optiond"]!)", optionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType: "\(val["question_type"]!)"))
                                //check if admin have added questions with 5 options? if not, then hide option E btn by setting boolean variable to false even if option E mode is Enabled.
                                //                            if let e = val["optione"] as? String {
                                //                                if e == ""{
                                //                                    Apps.opt_E = false
                                //                                }else{
                                //                                    Apps.opt_E = true
                                //                                }
                                //                            }
                            }
//                            if Apps.FIX_QUE_LVL != "1" {
//                                Apps.TOTAL_PLAY_QS = data.count
//                            }
                            if Apps.FIX_QUE_LVL == "0" { //fixed number of Questions set to False
                                Apps.TOTAL_PLAY_QS = data.count
                            }else{
                                Apps.TOTAL_PLAY_QS = Apps.FIXED_QS
                            }
                            print(Apps.TOTAL_PLAY_QS)
                            
                            //check this level has enough (10) question to play? or not
                            if self.quesData.count >= Apps.TOTAL_PLAY_QS {
                                viewCont.quesData = self.quesData
                                DispatchQueue.main.async {
                                    self.addTransition()
                                    self.navigationController?.pushViewController(viewCont, animated: false)
//                                    self.navigationController?.pushViewController(viewCont, animated: true)
                                }
                            }//else{
                            //                            DispatchQueue.main.async {
                            //                                print("This level does not have enough question",self.quesData.count)
                            //                                self.ShowAlert(title: Apps.NOT_ENOUGH_QUESTION_TITLE, message: Apps.NO_ENOUGH_QUESTION_MSG)
                            //                            }
                            //                        }
                        }else{
                        }
                    }
                })
            }else{
                self.ShowAlert(title: Apps.OOPS, message: Apps.LEVEL_LOCK)
            }
        }
}
extension LevelView{
    
    func GetUserLevel(){
        if(Reachability.isConnectedToNetwork()){
            let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            Loader = LoadLoader(loader: Loader)
            mainCatID = self.mainCatid
            let apiURL = self.questionType == "main" ? "user_id=\(user.userID)&category=\(self.catID)&subcategory=0" : "user_id=\(user.userID)&category=\(self.mainCatid)&subcategory=\(self.catID)"
            self.getAPIData(apiName: "get_level_data", apiURL: apiURL,completion: { jsonObj in
                 print("JSON - Level",jsonObj)
                let status = jsonObj.value(forKey: "error") as! String
                if (status == "true") {
                    DispatchQueue.main.async {
                        self.Loader.dismiss(animated: true, completion: {
                            self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                        })
                    }
                }else{
                    //close loader here
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                        DispatchQueue.main.async {
                            self.DismissLoader(loader: self.Loader)
                            let data = jsonObj.value(forKey: "data") as? [String:Any]
                            print("level data \(String(describing: data))")
                            self.unLockLevel = Int("\(data!["level"]!)")!
                           // scoreLevel = self.unLockLevel
                            self.collectionView.isHidden = false
//                            self.tableView.isHidden = false
//                            self.tableView.delegate = self
//                            self.tableView.dataSource = self
                            self.collectionView.reloadData()
                           // self.tableView.reloadData()
                        }
                    });
                }
            })
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
}

class levelCell: UICollectionViewCell { 
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet var levelNumber: UILabel!
    @IBOutlet var levelTxt: UILabel!
//    @IBOutlet var circleImgView: UIImageView!
    @IBOutlet weak var lockButton: UIButton!
}
