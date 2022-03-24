import UIKit
import AVFoundation
import GoogleMobileAds
import FBAudienceNetwork

struct SubCategory {
    let id:String
    let name:String
    let image:String
    let maxlevel:String
    let status:String
    let noOf:String
}
//structure for Data of Learning
struct LearningData: Codable {
    let id:String
    let category:String
    let detail:String
    let lang_id:String
    let noOf:String
    let status:String
    let title:String
}
//structure for Data of Learning
struct MathsData: Codable {
    let id:String
    let name:String
    let image:String
    let lang_id:String
    let noOf:String
    let status:String
    let rowOrder:String
    let mainCatID:String
}
class subCategoryViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,GADBannerViewDelegate,FBAdViewDelegate{
    
    @IBOutlet var subCollectionView: UICollectionView!
    var numberOfItems: Int = 2 //10 //6//
    
    @IBOutlet weak var adBannerView: GADBannerView!
    // @IBOutlet weak var adContainer: UIView!
     var adView: FBAdView?
    
    @IBOutlet weak var titleBarTxt: UILabel!
    
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var catID:String = "48"
    var catName:String = ""
    var subCatData:[SubCategory] = []
    var subCatLData:[LearningData] = []
    var subCatMData:[MathsData] = []
    //var refreshController = UIRefreshControl()
    var type = 1
        
//    var arrColors1 = [UIColor(named: "purple1"),UIColor(named: "sky1"),UIColor(named: "orange1"),UIColor(named: "green1"),UIColor(named: "blue1"),UIColor(named: "pink1")]
//    var arrColors2 = [UIColor(named: "purple2"),UIColor(named: "sky2"),UIColor(named: "orange2"),UIColor(named: "green2"),UIColor(named: "blue2"),UIColor(named: "pink2")]
    
//    var tintArr = ["purple2", "sky2","orange2","green2","blue2","pink2"] //arrColors1 & arrColors2 & tintArr - arrays should have same values/count
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForValues(numberOfItems)
        
        if !UserDefaults.standard.bool(forKey: "adRemoved") { //RemoveAds
            if Apps.ADV_TYPE == "ADMOB" {
                adBannerView.adUnitID = Apps.BANNER_AD_UNIT_ID
                adBannerView.rootViewController = self
                let request = GADRequest()
                //request.testDevices = Apps.AD_TEST_DEVICE
                GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
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
            subCollectionView.frame = CGRect(x: subCollectionView.frame.origin.x, y: subCollectionView.frame.origin.y, width: subCollectionView.frame.size.width, height: subCollectionView.frame.size.height + adBannerView.frame.size.height)
            print("Ads Removed !!")
        }
        
        print("subcategoryview with id and name - \(catID) - \(catName)")
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            if type == 2 {
                let apiURL = "category=\(catID)"
                self.getAPIData(apiName: "get_learning", apiURL: apiURL,completion: LoadData)
//            }else if type == 3 {
//                let apiURL = "category=\(catID)"
//                self.getAPIData(apiName: "get_maths_questions", apiURL: apiURL,completion: LoadData)
            }else{
                let apiURL = "main_id=\(catID)"
                self.getAPIData(apiName: "get_subcategory_by_maincategory", apiURL: apiURL,completion: LoadData)
            }
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        //refreshController.addTarget(self,action: #selector(self.RefreshDataOnPullDown),for: .valueChanged)
        //tableView.refreshControl = refreshController
        titleBarTxt.text = catName        
    }
//    func checkForValues(){
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
    //load sub category data here
    func LoadData(jsonObj:NSDictionary){
        print("Subcategory Response - ",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
        }else{
            //get data for category
            if type == 2 { //Learning
                subCatLData.removeAll()
                if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                    for val in data{
                        subCatLData.append(LearningData.init(id: "\(val["id"]!)", category: "\(val["category"]!)", detail: "\(val["detail"]!)", lang_id: "\(val["language_id"]!)", noOf: "\(val["no_of"]!)", status: "\(val["status"]!)", title: "\(val["title"]!)"))
                    }
                }
            }else if type == 3 { //Maths
                subCatMData.removeAll()
                if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                    for val in data{
                        subCatMData.append(MathsData.init(id: "\(val["id"]!)", name: "\(val["subcategory_name"]!)", image: "\(val["image"]!)", lang_id: "\(val["language_id"]!)", noOf: "\(val["no_of"]!)", status: "\(val["status"]!)", rowOrder: "\(val["row_order"]!)", mainCatID: "\(val["maincat_id"]!)"))
                                           //init(id: "\(val["id"]!)", category: "\(val["category"]!)", detail: "\(val["detail"]!)", lang_id: "\(val["language_id"]!)", noOf: "\(val["no_of"]!)", status: "\(val["status"]!)", title: "\(val["title"]!)"))
                    }
                }
            }else{ //Quiz
                subCatData.removeAll()
                if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                    for val in data{
                        subCatData.append(SubCategory.init(id: "\(val["id"]!)", name: "\(val["subcategory_name"]!)", image: "\(val["image"]!)", maxlevel: "\(val["maxlevel"]!)", status: "\(val["status"]!)", noOf: "\(val["no_of"]!)"))
                    }
                }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.45, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                self.subCollectionView.reloadData()
                var totalNum = self.subCatData.count
                if (self.type == 2){//Learning
                    totalNum = self.subCatLData.count
                }else if (self.type == 3){ //Maths
                    totalNum = self.subCatMData.count
                }else{ //quiz
                    totalNum = self.subCatData.count
                }
                self.numberOfItems = totalNum //(self.type == 2) ? self.subCatLData.count : self.subCatData.count
                self.checkForValues(self.numberOfItems)
//                self.tableView.reloadData()
//                self.refreshController.endRefreshing()
            }
        });
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
    @IBAction func backButton(_ sender: Any) {
        //check if user entered in this view directly from notification ? if Yes then goTo Home page otherwise just go back from notification view
        if self == UIApplication.shared.windows.first!.rootViewController {
            addPopTransition()
            self.navigationController?.popToRootViewController(animated: false) //true
        }else{
            addPopTransition()
            self.navigationController?.popViewController(animated: false)
//            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func settingButton(_ sender: Any) {
//        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
//        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//        self.present(myAlert, animated: true, completion: nil)
        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier:"SettingsAlert")
        myAlert.modalPresentationStyle = .overCurrentContext
        self.present(myAlert, animated: true, completion: nil)
    }
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if (self.type == 2){ //learning
        numberOfItems = self.subCatLData.count
    }else if (self.type == 3){ //maths
        numberOfItems = self.subCatMData.count
    }else{ //quiz
        numberOfItems = self.subCatData.count
    }
   return numberOfItems
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
    let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! subcatCell
   // print("indexpath row value -- \(indexPath.row) --  total count of array - \(Apps.arrColors1.count) --  total count of tint array - \(Apps.tintArr.count) -- total count of cells - \(numberOfItems)")
    //var strText = "Subcategory"
    if subCatData.count > 0 || subCatLData.count > 0 || subCatMData.count > 0 {
        // gridCell.subCatLabel.text = subCatData[indexPath.row].name//"General knowledge"
        // strText = subCatData[indexPath.row].name
        var nameVal = "" //catData[indexPath.row].name
        var totalQues = "" //"\(Apps.STR_QUE): \(catData[indexPath.row].noOfQues)"
        var imgURL = "" //self.catData[indexPath.row].image
        if (self.type == 2){ //learning
            nameVal = subCatLData[indexPath.row].title
            totalQues = "\(Apps.QSTN): \(subCatLData[indexPath.row].noOf)"
            imgURL = ""
        }else if (self.type == 3){ //maths
            nameVal = subCatMData[indexPath.row].name
            totalQues = "" //"\(Apps.STR_QUE) \(subCatMData[indexPath.row].noOf)"
            imgURL = self.subCatMData[indexPath.row].image
        }else{ //quiz
            nameVal = subCatData[indexPath.row].name
            totalQues = "\(Apps.STR_QUE) \(subCatData[indexPath.row].noOf)"
            imgURL = self.subCatData[indexPath.row].image
        }
        gridCell.subCatLabel.text = "" //nameVal //(self.type == 2) ? subCatLData[indexPath.row].title : subCatData[indexPath.row].name//""
//        gridCell.subCatLabel.textChangeAnimationToRight()//typeOn(string: subCatData[indexPath.row].name, typeInterval: 0.099)
        gridCell.subCatLabel.typeOn(string: nameVal, typeInterval: 0.059)
        gridCell.totalQue.text = totalQues //(self.type == 2) ? "\(Apps.QSTN): \(subCatLData[indexPath.row].noOf)" : "\(Apps.STR_QUE) \(subCatData[indexPath.row].noOf)"
       // print("link of image -- \(self.subCatData[indexPath.row].image)")
        if (imgURL != "") {
            gridCell.logoImg.loadImageUsingCache(withUrl: imgURL)
        }else{
            gridCell.logoImg.image = UIImage(named: "AppIcon")
        }
//        gridCell.logoImg.loadImageUsingCache(withUrl: imgURL)//(self.type == 2) ? "" : self.subCatData[indexPath.row].image)//UIImage(named: "quiz")
    }else{
        gridCell.subCatLabel.text = "Subcategory"
        gridCell.totalQue.text = "10"
        gridCell.logoImg.image = UIImage(named: "AppIcon")
    }
//    gridCell.subCatLabel.typeOn(string: strText, typeInterval: 0.325) //textChangeAnimationToRight()
//    gridCell.circleImgView.image = UIImage(named: "circle")
//    gridCell.circleImgView.tintColor = UIColor.init(named: Apps.tintArr[indexPath.row])
   // gridCell.bottomLineView.setGradient(arrColors1[indexPath.row] ?? UIColor.blue,arrColors2[indexPath.row] ?? UIColor.cyan)
//    gridCell.bottomLineView.backgroundColor = arrColors1[indexPath.row]
    
//    gridCell.addBottomBorderWithGradientColor(startColor: Apps.arrColors1[indexPath.row] ?? UIColor.blue , endColor: Apps.arrColors2[indexPath.row] ?? UIColor.cyan, width: 2, cornerRadius: 05) //gridCell.layer.cornerRadius //3
    gridCell.roundCorners(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 15)
//    gridCell.setCellShadow()
    
    return gridCell
}
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
       /* collectionView.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 10)

        let itemSpacing: CGFloat = 35 //15
        let textAreaHeight: CGFloat = 65

        let width: CGFloat = ((collectionView.bounds.width) - itemSpacing)/2  //- 20
        let height: CGFloat = width * 10/13 + textAreaHeight //10/7
        return CGSize(width: width, height: height)
        
        //return CGSize(width: (collectionView.bounds.width-32), height: 150) */
        let itemSpacing: CGFloat = (deviceStoryBoard == "Ipad") ? 64 : 32 //55 //35
        //let textAreaHeight: CGFloat = 65
        let width: CGFloat = ((collectionView.bounds.width) - itemSpacing)
        let height: CGFloat = width * 10/40 //33 //+ textAreaHeight
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // print("clicked cell number \(indexPath.row)")
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        if type == 2 { //Learning
            if self.subCatLData[indexPath.row].noOf != "0" {
                 let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "LearningView") as! LearningView
                 viewCont.learning_id = Int(self.subCatLData[indexPath.row].category)!
                 viewCont.selected_ch = indexPath.row //as index starts with 0 there
                 viewCont.learningData = self.subCatLData
                 self.addTransition()
                 self.navigationController?.pushViewController(viewCont, animated: false)
//                self.navigationController?.pushViewController(viewCont, animated: true)
             }else{
                 ShowAlertOnly(title: "", message: Apps.NO_DATA)
             }
        }else if type == 3 { //Maths
            if self.subCatMData[indexPath.row].noOf != "0" {
                 let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "PlayMathQuizView") as! PlayMathQuizView
                 viewCont.catID = Int(self.subCatMData[indexPath.row].id) ?? 0
                 viewCont.catName = self.subCatMData[indexPath.row].name
                 viewCont.isSubCat = true
                 self.addTransition()
                 self.navigationController?.pushViewController(viewCont, animated: false)
//                self.navigationController?.pushViewController(viewCont, animated: true)
             }else{
                 ShowAlertOnly(title: "", message: Apps.NO_DATA)
             }
        }else{ //Quiz
            // let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
             let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "LevelView") as! LevelView
             print(subCatData[indexPath.row].maxlevel)
             if self.subCatData[indexPath.row].maxlevel != "0" {
                 if self.subCatData[indexPath.row].maxlevel.isInt{
                     viewCont.maxLevel = Int(self.subCatData[indexPath.row].maxlevel)!
                 }
                 viewCont.mainCatid = Int(self.catID)!
                 viewCont.catID = Int(self.subCatData[indexPath.row].id)!
                 viewCont.questionType = "sub"
                 self.addTransition()
                 self.navigationController?.pushViewController(viewCont, animated: false)
//                 self.navigationController?.pushViewController(viewCont, animated: true)
             }else{
                 ShowAlertOnly(title: "", message: Apps.NOT_ENOUGH_QUESTION_TITLE)
             }
        }
    }
}

class subcatCell: UICollectionViewCell {
    
    @IBOutlet var subCatLabel: UILabel!
    @IBOutlet var totalQue: UILabel!
//    @IBOutlet var circleImgView: UIImageView!
    @IBOutlet weak var logoImg: UIImageView!
   // @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var gotoButton: UIButton!
}
