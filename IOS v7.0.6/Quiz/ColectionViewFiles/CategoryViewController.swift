import UIKit
import AVFoundation
import QuartzCore
import GoogleMobileAds
import FBAudienceNetwork

//structure for category
struct Category: Codable {
    let id:String
    let name:String
    let image:String
    let maxlvl:String
    let noOf:String
    let noOfQues:String
}
//structure for category of Learning
struct CategoryLearning: Codable {
    let id:String
    let name:String
    let image:String
    let language:String
    let lang_id:String
    let noOf:String
    let rowOrder:String
    let type:String
}
//structure for category of Maths
struct CategoryMaths: Codable {
    let id:String
    let name:String
    let image:String
    let language:String
    let lang_id:String
    let noOf:String
    let noOfQues:String
    let rowOrder:String
    let type:String
}

class CategoryViewController: UIViewController, GADBannerViewDelegate,FBAdViewDelegate, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet var collectionView: UICollectionView! //ASCollectionView!
    @IBOutlet var bannerView: GADBannerView!
    
//    @IBOutlet weak var adContainer: UIView!
    var adView: FBAdView?
        
    @IBOutlet weak var sBtn: UIButton!
    
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
//    var Loader: UIAlertController = UIAlertController()
    
    var isCategoryBattle = false
    var isGroupCategoryBattle = false
    var selection = Apps.GRP_BTL
    
    var catData:[Category] = []
    var catLData:[CategoryLearning] = []
    var catMData:[CategoryMaths] = []
    var langList:[Language] = []
//    var refreshController = UIRefreshControl()
    var config:SystemConfiguration?
    var apiName = "get_categories"
    var type = 1
    var apiExPeraforLang = ""
    var numberOfItems: Int = 2//7 //10
    let collectionElementKindHeader = "Header"
            
    override func viewDidLoad() {
        super.viewDidLoad()
        apiExPeraforLang = "&type=\(type)"
        
//        refreshController.addTarget(self,action: #selector(self.RefreshDataOnPullDown),for: .valueChanged)
//        collectionView.refreshControl = refreshController
        //catetableView.refreshControl = refreshController
        //collectionView.delegate = self
       // collectionView.asDataSource = self
        
       // languageButton.isHidden = true
        if isKeyPresentInUserDefaults(key: DEFAULT_SYS_CONFIG){
             config = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        }
//        if config?.LANGUAGE_MODE == 1{
//            apiName = "get_categories_by_language"
//            apiExPeraforLang = "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))"
//            languageButton.isHidden = false
//        }
        //get data from server
        if(Reachability.isConnectedToNetwork()){
//            Loader = LoadLoader(loader: Loader)
            if config?.LANGUAGE_MODE == 1{
                apiName = "get_categories_by_language"
                apiExPeraforLang = "&type=\(type)&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))" //+=
            }
            let apiURL = "" + apiExPeraforLang //+ "&type=1"
            self.getAPIData(apiName: apiName, apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        //RemoveAds
        
        if !UserDefaults.standard.bool(forKey: "adRemoved") { //Apps.adRemovalPurchased //RemoveAds
            if Apps.ADV_TYPE == "ADMOB" {
                // Google AdMob Banner
                bannerView.adUnitID = Apps.BANNER_AD_UNIT_ID
                bannerView.rootViewController = self
                let request = GADRequest()
                //request.testDevices = Apps.AD_TEST_DEVICE
                GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
                bannerView.load(request)
                print("There is a banner!")
            }else{
                adView = FBAdView(
                           placementID: Apps.BANNER_AD_UNIT_ID,
                           adSize: kFBAdSize320x50,
                           rootViewController: self)
                //adView!.frame = CGRect(x: 0, y: 0, width: self.adContainer.frame.width, height: self.adContainer.frame.height)
                adView!.frame = CGRect(x: 0, y: 0, width: self.bannerView.frame.width, height: self.bannerView.frame.height)
                adView!.delegate = self
                adView!.loadAd()
            }
        } else {
            bannerView.isHidden = true
            collectionView.frame = CGRect(x: collectionView.frame.origin.x, y: collectionView.frame.origin.y, width: collectionView.frame.size.width, height: collectionView.frame.size.height + bannerView.frame.size.height)
            print("There is no banner")
        }
        
        checkForValues(numberOfItems)
    }
    /*func ReLaodCategory() {
        apiExPeraforLang = "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))"
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            let apiURL = "" + apiExPeraforLang
            self.getAPIData(apiName: apiName, apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
//        numberOfItems = catData.count
//        checkForValues(numberOfItems)
    }*/
    // refresh function
    /* @objc func RefreshDataOnPullDown(){
       /* if(Reachability.isConnectedToNetwork()){
            apiExPeraforLang = "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))"
            Loader = LoadLoader(loader: Loader)
            let apiURL = "" + apiExPeraforLang
            self.getAPIData(apiName: apiName, apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        } */
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            if config?.LANGUAGE_MODE == 1{
                apiName = "get_categories_by_language"
                apiExPeraforLang = "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))&type=\(type)"
            }
            let apiURL = "" + apiExPeraforLang //+ "&type=1"
            self.getAPIData(apiName: apiName, apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
//        numberOfItems = catData.count
//        checkForValues(numberOfItems)
    }*/
    
    //MARK: -  Apps.ADV_TYPE = FB
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
             bannerView.addSubview(adView!)
         }
     }
    //MARK:  Apps.ADV_TYPE = FB -
    //MARK: Apps.ADV_TYPE = ADMOB
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
          print("Banner loaded successfully")
      }

    private func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: NSError) {
          print("Fail to receive ads")
          print(error)
      }
    //MARK:  Apps.ADV_TYPE = ADMOB -
   
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//        collectionView.reloadData()
//    }
    
    //load category data here
    func LoadData(jsonObj:NSDictionary){
        print("Category Response - ",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            DispatchQueue.main.async {
//                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
//                })
            }
        }else{
            //get data for category
            if type == 2 { //Learning Zone
                catLData.removeAll()
                if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                    for val in data{
                       // catLData.append(CategoryLearning.init(id: "\(val["id"]!)", name: "\(val["category_name"]!)", image: "\(val["image"]!)", language: "\(val["language"]!)", lang_id: "\(val["language_id"]!)", noOf: "\(val["no_of"]!)", rowOrder: "\(val["row_order"]!)", type: "\(val["type"]!)"))
                        catLData.append(CategoryLearning.init(id: "\(val["id"]!)", name: "\(val["category_name"]!)", image: "\(val["image"]!)", language: "", lang_id: "\(val["language_id"]!)", noOf: "\(val["no_of"]!)", rowOrder: "\(val["row_order"]!)", type: "\(val["type"]!)"))
                    }
                }
            }else if type == 3 { //Maths Zone
                catMData.removeAll()
                if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                    for val in data{
                        catMData.append(CategoryMaths.init(id: "\(val["id"]!)", name: "\(val["category_name"]!)", image: "\(val["image"]!)", language: "", lang_id: "\(val["language_id"]!)", noOf: "\(val["no_of"]!)", noOfQues: "\(val["no_of_que"]!)", rowOrder: "\(val["row_order"]!)", type: "\(val["type"]!)"))
                    }
                }
            }else{
                //add data to catData
                catData.removeAll()
                if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                    for val in data{
                        catData.append(Category.init(id: "\(val["id"]!)", name: "\(val["category_name"]!)", image: "\(val["image"]!)", maxlvl: "\(val["maxlevel"]!)", noOf: "\(val["no_of"]!)", noOfQues: "\(val["no_of_que"]!)"))
                    }
                }
            }
            
            //Add collectionView dimesnsions from ASACollection
            DispatchQueue.main.async {
                self.collectionView.register(UINib(nibName: self.collectionElementKindHeader, bundle: nil), forSupplementaryViewOfKind:  self.collectionElementKindHeader, withReuseIdentifier: "header")
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now(), execute: { // + 0.5
           DispatchQueue.main.async {
//                self.DismissLoader(loader: self.Loader)
                var totalNum = self.catData.count
                if (self.type == 2){ //learning
                   totalNum = self.catLData.count
                }else if (self.type == 3){ //maths
                    totalNum = self.catMData.count
                }else{ //quiz
                    totalNum = self.catData.count
                }
                self.numberOfItems = totalNum//(self.type == 2) ? self.catLData.count : self.catData.count
                self.checkForValues(self.numberOfItems)
                self.collectionView.reloadData()
                //self.catetableView.reloadData()
//                self.refreshController.endRefreshing()
            }
        });
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
    @IBAction func backButton(_ sender: Any) {
//        if isGroupCategoryBattle == true {
//           // self.dismiss(animated: false, completion: nil)
//            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil) //dismiss categoryView and it's parent/GroupBattleTypeSelection view also.
//        }else{
            addPopTransition()
            self.navigationController?.popViewController(animated: false)
//            self.navigationController?.popViewController(animated: true)
//        }
    }
    @IBAction func settingButton(_ sender: Any) {
        //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
//        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//        self.present(myAlert, animated: true, completion: nil)
        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier:"SettingsAlert")
        myAlert.modalPresentationStyle = .overCurrentContext
        self.present(myAlert, animated: true, completion: nil)
    }
}

//extension CategoryViewController: ASCollectionViewDelegate {
//
//    func loadMoreInASCollectionView(_ asCollectionView: ASCollectionView) {
//        if numberOfItems > 30 {
//            collectionView.enableLoadMore = false
//            return
//        }
//       // numberOfItems += 1//0
//        collectionView.loadingMore = false
//        collectionView.reloadData()
//        //checkForValues(numberOfItems)
//    }
//  /*  func animateView(_ type: CATransitionSubtype) -> CATransition{
//        let animationS:CATransition = CATransition()
//        animationS.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
//        animationS.type = CATransitionType.push
//        animationS.subtype = CATransitionSubtype.fromLeft//type
//        animationS.duration = 0.50
//        self.layer.add(animationS, forKey: "CATransition")
//        return animationS
//    }*/
//}

extension CategoryViewController: UICollectionViewDataSource,UICollectionViewDelegate { //ASCollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.type == 2){
            numberOfItems = catLData.count
        }else if (self.type == 3){
            numberOfItems = catMData.count
        }else{
            numberOfItems = catData.count
        }
        print("total count- \(numberOfItems)")
        return numberOfItems
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GridCell
        print("values of Cat data - \(catData.count) - \(catLData.count) - \(catMData.count)")
        if catData.count > 0 || catLData.count > 0 || catMData.count > 0 {
            print("INside IF count values of Cat data - \(catData.count) - \(catLData.count) - \(catMData.count)")
            var nameVal = ""
            var totalQues = ""
            var imgURL = ""
            if (self.type == 2){ //learning
                nameVal = catLData[indexPath.row].name
                totalQues = "\(Apps.VALUES): \(catLData[indexPath.row].noOf)"
                imgURL = self.catLData[indexPath.row].image
            }else if (self.type == 3){ //maths
                nameVal = catMData[indexPath.row].name
                totalQues = ""
                imgURL = self.catMData[indexPath.row].image
            }else{ //quiz
                nameVal = catData[indexPath.row].name
                totalQues = "\(Apps.STR_QUE): \(catData[indexPath.row].noOfQues)"
                imgURL = self.catData[indexPath.row].image
            }
            gridCell.catLabel.text = "" //nameVal
            gridCell.catLabel.typeOn(string: nameVal, typeInterval: 0.059)
//            gridCell.catLabel.textChangeAnimationToRight()
            gridCell.totalQue.text = totalQues
            if (imgURL != "") {
                gridCell.logoImg.loadImageUsingCache(withUrl: imgURL)
            }else{
                gridCell.logoImg.image = UIImage(named: "AppIcon")
            }
        }else{
            gridCell.catLabel.text = "Category"
            gridCell.totalQue.text = "Que: 0"
            gridCell.logoImg.image = UIImage(named: "AppIcon")
        }
//        gridCell.circleImgView.image = UIImage(named: "circle")
//        gridCell.circleImgView.tintColor = UIColor.init(named: Apps.tintArr[indexPath.row])
//        gridCell.bottomLineView.startColor = Apps.arrColors1[indexPath.row] ?? UIColor.blue
//        gridCell.bottomLineView.endColor = Apps.arrColors2[indexPath.row] ?? UIColor.cyan
//        gridCell.setCellShadow()
        gridCell.roundCorners(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 15)
        return gridCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //collectionView.contentInset = UIEdgeInsets(top: 20, left: 15, bottom: 0, right: 10)//(deviceStoryBoard == "Ipad") ? UIEdgeInsets(top: 40, left: 15, bottom: 0, right: 10) : UIEdgeInsets(top: 20, left: 15, bottom: 0, right: 10)//not working-works when assigned in design/storybaord in ipad
        let itemSpacing: CGFloat = (deviceStoryBoard == "Ipad") ? 64 : 32 //35 //55
        //let textAreaHeight: CGFloat = 65
        let width: CGFloat = ((collectionView.bounds.width) - itemSpacing)
        let height: CGFloat = width * 10/40 //33 //+ textAreaHeight
        return CGSize(width: width, height: height)
        //return CGSize(width: (collectionView.bounds.width-32), height: 150)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isCategoryBattle == true{
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "BattleViewController") as! BattleViewController
            if catData[indexPath.row].noOfQues != "0" { //if there's no levels or no questions then do nothing
                viewCont.isCategoryBattle = true
                viewCont.catID = Int(self.catData[indexPath.row].id)!
                self.addTransition()
                self.navigationController?.pushViewController(viewCont, animated: false)
//                self.navigationController?.pushViewController(viewCont, animated: true)
            }else{
                ShowAlertOnly(title: "", message: Apps.NOT_ENOUGH_QUESTION_TITLE)
            }
        }else if isGroupCategoryBattle == true {
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "GroupBattleView") as! GroupBattleView
            if catData[indexPath.row].noOfQues != "0" { //if there's no levels or no questions then do nothing
                viewCont.catID = Int(self.catData[indexPath.row].id)!
                viewCont.selection = self.selection
                self.addTransition()
                self.navigationController?.pushViewController(viewCont, animated: false)
//                self.navigationController?.pushViewController(viewCont, animated: true)
            }else{
                ShowAlertOnly(title: "", message: Apps.NOT_ENOUGH_QUESTION_TITLE)
            }
        }else{
            if catData.count > 0 || catLData.count > 0 || catMData.count > 0 {
                if (type == 2) {
                    if catLData[indexPath.row].noOf != "0"{ //there are no subcategories there
                        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "subcategoryview") as! subCategoryViewController
                        viewCont.catID = catLData[indexPath.row].id
                        viewCont.catName = catLData[indexPath.row].name
                        viewCont.type = self.type
                        print("chapter id and name -- \(catLData[indexPath.row].id) \(catLData[indexPath.row].name)")
                        self.addTransition()
                        self.navigationController?.pushViewController(viewCont, animated: false)
//                        self.navigationController?.pushViewController(viewCont, animated: true)
                    }else{
                        ShowAlertOnly(title: "", message: Apps.NOT_ENOUGH_QUESTION_TITLE)
                    }
                }else if (type == 3) {
                    if catMData[indexPath.row].noOfQues != "0" { //if there's no levels or no questions then show alert
                        if catMData[indexPath.row].noOf != "0" { //if there's no subcategories - then go to play screen directly
                            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "subcategoryview") as! subCategoryViewController
                            viewCont.catID = catMData[indexPath.row].id
                            viewCont.catName = catMData[indexPath.row].name
                            viewCont.type = self.type
                            self.addTransition()
                            self.navigationController?.pushViewController(viewCont, animated: false)
//                            self.navigationController?.pushViewController(viewCont, animated: true)
                        }else{
                            //goto play screen instead of subcategory
                            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "PlayMathQuizView") as! PlayMathQuizView
                            viewCont.catID = Int(catMData[indexPath.row].id) ?? 0
                            viewCont.catName = catMData[indexPath.row].name
                            viewCont.isSubCat = false //set it to true in SubcategoryView
                            self.addTransition()
                            self.navigationController?.pushViewController(viewCont, animated: false)
//                            self.navigationController?.pushViewController(viewCont, animated: true)
                        }
                    }else{
                        ShowAlertOnly(title: "", message: Apps.NOT_ENOUGH_QUESTION_TITLE)
                    }
                }else{
                    if(catData[indexPath.row].noOf == "0"){
                        // this category does not have any sub category so move to level screen
                        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "LevelView") as! LevelView
                        if catData[indexPath.row].maxlvl != "0" { //if there's no levels or no questions then do nothing
                            if catData[indexPath.row].maxlvl.isInt{
                                viewCont.maxLevel = Int(catData[indexPath.row].maxlvl)!
                            }
                            viewCont.catID = Int(self.catData[indexPath.row].id)!
                            viewCont.questionType = "main"
                            self.addTransition()
                            self.navigationController?.pushViewController(viewCont, animated: false)
//                            self.navigationController?.pushViewController(viewCont, animated: true)
                        }else{
                            ShowAlertOnly(title: "", message: Apps.NOT_ENOUGH_QUESTION_TITLE)
                        }
                    }else{
                        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "subcategoryview") as! subCategoryViewController
                        viewCont.catID = catData[indexPath.row].id
                        viewCont.catName = catData[indexPath.row].name
                        print("cat id and name -- \(catData[indexPath.row].id) \(catData[indexPath.row].name)")
                        self.addTransition()
                        self.navigationController?.pushViewController(viewCont, animated: false)
//                        self.navigationController?.pushViewController(viewCont, animated: true)
                    }
                }
            }
        }
    }
   /* func numberOfItemsInASCollectionView(_ asCollectionView: ASCollectionView) -> Int {
        if (self.type == 2){
            numberOfItems = catLData.count
        }else if (self.type == 3){
            numberOfItems = catMData.count
        }else{
            numberOfItems = catData.count
        }
        print("total count- \(numberOfItems)")
        return numberOfItems
    }
    
//    func collectionView(_ asCollectionView: ASCollectionView, headerAtIndexPath indexPath: IndexPath) -> UICollectionReusableView {
//        let header = collectionView.dequeueReusableSupplementaryView(ofKind: ASCollectionViewElement.Header, withReuseIdentifier: "header", for: indexPath)
//        return header
//    }
    func collectionView(_ asCollectionView: ASCollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell { // - cellForItemAtIndexPath
        let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GridCell
       // print("catdata values - \(catData.count) indexpath row value -- \(indexPath.row) --  total count of array - \(Apps.arrColors1.count) -- total count of cells - \(numberOfItems)")
        print("values of Cat data - \(catData.count) - \(catLData.count) - \(catMData.count)")
        if catData.count > 0 || catLData.count > 0 || catMData.count > 0 {
            //gridCell.catLabel.text = catData[indexPath.row].name //"General knowledge"//String(format: "Item %ld ", indexPath.row) //
            print("INside IF count values of Cat data - \(catData.count) - \(catLData.count) - \(catMData.count)")
            var nameVal = "" //catData[indexPath.row].name
            var totalQues = "" //"\(Apps.STR_QUE): \(catData[indexPath.row].noOfQues)"
            var imgURL = "" //self.catData[indexPath.row].image
            if (self.type == 2){ //learning
                nameVal = catLData[indexPath.row].name
                totalQues = "\(Apps.VALUES): \(catLData[indexPath.row].noOf)"
                imgURL = self.catLData[indexPath.row].image
            }else if (self.type == 3){ //maths
                nameVal = catMData[indexPath.row].name
                totalQues = "" //"\(Apps.STR_QUE): \(catMData[indexPath.row].noOfQues)"
                imgURL = self.catMData[indexPath.row].image
            }else{ //quiz
                nameVal = catData[indexPath.row].name
                totalQues = "\(Apps.STR_QUE): \(catData[indexPath.row].noOfQues)"
                imgURL = self.catData[indexPath.row].image
            }
            gridCell.catLabel.text = nameVal //(self.type == 2) ? catLData[indexPath.row].name : catData[indexPath.row].name //""
//            let anim = animateView(.fromLeft)
//            gridCell.catLabel.layer.add(anim, forKey: "CATransition")
            gridCell.catLabel.textChangeAnimationToRight()
            //gridCell.catLabel.typeOn(string: catData[indexPath.row].name, typeInterval: 0.099)
            gridCell.totalQue.text = totalQues //(self.type == 2) ? "\(Apps.VALUES): \(catLData[indexPath.row].noOf)" : "\(Apps.STR_QUE): \(catData[indexPath.row].noOfQues)"
            if (imgURL != "") {
                gridCell.logoImg.loadImageUsingCache(withUrl: imgURL)
            }else{
                gridCell.logoImg.image = UIImage(named: "AppIcon")
            }
           // gridCell.logoImg.loadImageUsingCache(withUrl: ((imgURL != "") ? imgURL : localImgURL))//(self.type == 2) ? self.catLData[indexPath.row].image : self.catData[indexPath.row].image)//UIImage(named: "quiz")
        }else{
            gridCell.catLabel.text = "Category"
            gridCell.totalQue.text = "Que: 0"
            gridCell.logoImg.image = UIImage(named: "AppIcon")
        }
       // gridCell.catLabel.textChangeAnimationToRight()
        gridCell.circleImgView.image = UIImage(named: "circle")
        //print("index of tintColors - \(indexPath.row) - name of tint color - \(Apps.tintArr[indexPath.row]) - - name of color - \(Apps.arrColors1[indexPath.row])")
        gridCell.circleImgView.tintColor = UIColor.init(named: Apps.tintArr[indexPath.row])//UIColor.init(named: "pink1")
//        gridCell.bottomLineView.setGradientLayer(arrColors1[indexPath.row] ?? UIColor.blue,arrColors2[indexPath.row] ?? UIColor.cyan)
//        gridCell.bottomLineView.backgroundColor = UIColor.systemRed
        //gridCell.bottomLineView.backgroundColor = Apps.arrColors1[indexPath.row]
        //gridCell.backgroundColor = UIColor.random(from: [UIColor.systemRed,UIColor.systemBlue,UIColor.systemGreen])
        gridCell.bottomLineView.startColor = Apps.arrColors1[indexPath.row] ?? UIColor.blue
        gridCell.bottomLineView.endColor = Apps.arrColors2[indexPath.row] ?? UIColor.cyan      
        //print(indexPath.row)
//        gridCell.addBottomBorderWithGradientColor(startColor: Apps.arrColors1[indexPath.row]!, endColor: Apps.arrColors2[indexPath.row]!, width: 3, cornerRadius: 0) //gridCell.layer.cornerRadius
        gridCell.setCellShadow()
        return gridCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // print("clicked")
        if isCategoryBattle == true{
//            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "BattleViewController") as! BattleViewController
            if catData[indexPath.row].noOfQues != "0" { //if there's no levels or no questions then do nothing
                viewCont.isCategoryBattle = true
                viewCont.catID = Int(self.catData[indexPath.row].id)!
                self.navigationController?.pushViewController(viewCont, animated: true)
            }else{
                ShowAlertOnly(title: "", message: Apps.NOT_ENOUGH_QUESTION_TITLE)
            }
        }else if isGroupCategoryBattle == true {
           // let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "GroupBattleView") as! GroupBattleView //(withIdentifier: "PrivateRoomView") as! PrivateRoomView
//            viewCont.isCategoryBattle = true
            if catData[indexPath.row].noOfQues != "0" { //if there's no levels or no questions then do nothing
                viewCont.catID = Int(self.catData[indexPath.row].id)!
                viewCont.selection = self.selection
                self.navigationController?.pushViewController(viewCont, animated: true)
            }else{
                ShowAlertOnly(title: "", message: Apps.NOT_ENOUGH_QUESTION_TITLE)
            }
        }else{
            if catData.count > 0 || catLData.count > 0 || catMData.count > 0 {
                if (type == 2) {
//                        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "LearningView") as! LearningView
//                        viewCont.learning_id = self.catLData[indexPath.row].id
//                        self.navigationController?.pushViewController(viewCont, animated: true)
                    if catLData[indexPath.row].noOf != "0"{ //there are no subcategories there
                        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "subcategoryview") as! subCategoryViewController
                        viewCont.catID = catLData[indexPath.row].id
                        viewCont.catName = catLData[indexPath.row].name
                        viewCont.type = self.type
                        print("chapter id and name -- \(catLData[indexPath.row].id) \(catLData[indexPath.row].name)")
                        self.navigationController?.pushViewController(viewCont, animated: true)
                    }else{
                        ShowAlertOnly(title: "", message: Apps.NOT_ENOUGH_QUESTION_TITLE)
                    }
                }else if (type == 3) {
                    if catMData[indexPath.row].noOfQues != "0" { //if there's no levels or no questions then show alert
                        if catMData[indexPath.row].noOf != "0" { //if there's no subcategories - then go to play screen directly
                            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "subcategoryview") as! subCategoryViewController
                            viewCont.catID = catMData[indexPath.row].id
                            viewCont.catName = catMData[indexPath.row].name
                            viewCont.type = self.type
                            self.navigationController?.pushViewController(viewCont, animated: true)
                        }else{
                            //goto play screen instead of subcategory
                            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "PlayMathQuizView") as! PlayMathQuizView
                            viewCont.catID = Int(catMData[indexPath.row].id) ?? 0
                            viewCont.catName = catMData[indexPath.row].name
                            viewCont.isSubCat = false //set it to true in SubcategoryView
                            self.navigationController?.pushViewController(viewCont, animated: true)
                        }
                    }else{
                        ShowAlertOnly(title: "", message: Apps.NOT_ENOUGH_QUESTION_TITLE)
                    }
                }else{
                    if(catData[indexPath.row].noOf == "0"){
                        // this category does not have any sub category so move to level screen
                       // let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "LevelView") as! LevelView
                        if catData[indexPath.row].maxlvl != "0" { //if there's no levels or no questions then do nothing
                            if catData[indexPath.row].maxlvl.isInt{
                                viewCont.maxLevel = Int(catData[indexPath.row].maxlvl)!
                            }
                            viewCont.catID = Int(self.catData[indexPath.row].id)!
                            viewCont.questionType = "main"
                            self.navigationController?.pushViewController(viewCont, animated: true)
                        }else{
                            ShowAlertOnly(title: "", message: Apps.NOT_ENOUGH_QUESTION_TITLE)
                        }
                    }else{
                        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "subcategoryview") as! subCategoryViewController
                        viewCont.catID = catData[indexPath.row].id
                        viewCont.catName = catData[indexPath.row].name
                        print("cat id and name -- \(catData[indexPath.row].id) \(catData[indexPath.row].name)")
                        self.navigationController?.pushViewController(viewCont, animated: true)
                    }
                }
            }
        }
    } */
        
//    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
//        return UIColor(
//            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
//            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
//            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
//            alpha: CGFloat(1.0)
//        )
//    }
}

class GridCell: UICollectionViewCell {

    @IBOutlet var catLabel: UILabel!
    @IBOutlet var totalQue: UILabel!
   // @IBOutlet var circleImgView: UIImageView!
    @IBOutlet weak var logoImg: UIImageView!
//    @IBOutlet weak var bottomLineView: GradientButton! //UIView!
    @IBOutlet weak var gotoButton: UIButton!
    
   /* override public func layoutSubviews() {
        super.layoutSubviews()
        
        let subLayer = self.layer.superlayersublayers?.last
        
        subLayer.cornerRadius = 5
        subLayer.shadowColor = UIColor.gray.cgColor
        subLayer.shadowOffset = CGSize(width: 3, height: 4)
        subLayer.shadowOpacity = 1
        subLayer.shadowRadius = 4
        subLayer.masksToBounds = falsesubLayer!.masksToBounds = false self.layer.
        
        setLayerGradient()
    } */
    
   /* func setLayerGradient(){
        //set gradient layer
        
        let gradientLayer = CAGradientLayer()
        self.backgroundColor = .clear
        gradientLayer.colors = [Apps.arrColors1[0] ?? UIColor.blue,Apps.arrColors2[0] ?? UIColor.cyan]
        gradientLayer.startPoint = CGPoint(x: 0,y: 1)
        gradientLayer.endPoint = CGPoint(x: 1,y: 0)
        gradientLayer.locations = [0.50, 0.1]
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.bottomLineView.frame.size.width * UIScreen.main.bounds.width, height: self.bottomLineView.frame.size.height * UIScreen.main.bounds.height)
//        if let topLayer = self.layer.sublayers?.first, topLayer is CAGradientLayer
//        {
//            topLayer.removeFromSuperlayer()
//        }
        self.bottomLineView.layer.addSublayer(gradientLayer)
    } */
}

//extension UIImage {
//    static func gradientImageWithBounds(bounds: CGRect, colors: [CGColor]) -> UIImage {
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = bounds
//        gradientLayer.colors = colors
//
//        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
//        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return image!
//    }
//}
