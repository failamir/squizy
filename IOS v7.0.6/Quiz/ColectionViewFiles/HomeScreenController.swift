import UIKit
import Firebase
import AVFoundation
//import Lottie //lottie

class HomeScreenController: UIViewController, UITableViewDelegate, UITableViewDataSource,LanguageViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var allTimeScoreButton: UIButton!
    @IBOutlet weak var coinsButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet var languageButton: UIButton!
    @IBOutlet var iAPButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var backTopImg: UIImageView!
    //let storyBoard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
    var audioPlayer : AVAudioPlayer!
    var backgroundMusicPlayer: AVAudioPlayer!
    var setting:Setting? = nil
    var sysConfig:SystemConfiguration!
    var Loader: UIAlertController = UIAlertController()
    //var config:SystemConfiguration?
    let varSys = SystemConfig()
    let homeTblViewCell = HomeTableViewCell()
    var userDATA:UserScore? = nil
    var dUser:User? = nil
    var apiName = "get_categories"
    var apiExPeraforLang = ""
    var catData:[Category] = []
    var langList:[Language] = []
    var arr = [Apps.MATHS,Apps.LEARNING,Apps.QUIZ_ZONE,Apps.PLAY_ZONE,Apps.BATTLE_ZONE,Apps.CONTEST_ZONE]
    let leftImg = [Apps.IMG_MATHS_QUIZ,Apps.IMG_LEARNING_QUIZ,Apps.IMG_QUIZ_ZONE,Apps.IMG_PLAYQUIZ,Apps.IMG_BATTLE_QUIZ,Apps.IMG_CONTEST_QUIZ]
    //battle modes
    var ref: DatabaseReference!
    var roomDetails:RoomDetails?
    var isUserBusy = false
   // private var animationView: AnimationView? //lottie
   // private var animationView2: AnimationView? //lottie
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if Apps.CONTEST_MODE == "0"{
//            arr.removeLast() //as contest mode is last element there
//        }
//        self.tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "LearningZone")
//        self.tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "QuizZone")
//        self.tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "PlayZone")
//        self.tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "BattleZone")
//        self.tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "ContestZone")
        self.PlayBackgrounMusic(player: &backgroundMusicPlayer, file: "snd_bg")
        //check setting object in user default
        if UserDefaults.standard.value(forKey:"setting") != nil {
            setting = try! PropertyListDecoder().decode(Setting.self, from: (UserDefaults.standard.value(forKey:"setting") as? Data)!)
        }else{
            setting = Setting.init(sound: true, backMusic: false, vibration: true)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.setting), forKey: "setting")
        }
        
        //check score object in user default
        if UserDefaults.standard.value(forKey:"UserScore") != nil {
            //available
            let userScores = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
            print("User Score Value -- \(userScores)")
            if UserDefaults.standard.bool(forKey: "isLogedin"){
                print("user Details from HomeScreen - ViewDidLoad")
                varSys.getUserDetails()
                allTimeScoreButton.setTitle(String(userScores.points), for: .normal)
                coinsButton.setTitle(String(userScores.coins), for: .normal)
                leaderboardButton.setTitle(Apps.ALL_TIME_RANK as? String , for: .normal)
            }else{
                allTimeScoreButton.setTitle("0", for: .normal)
                coinsButton.setTitle("0", for: .normal)
                leaderboardButton.setTitle("0" , for: .normal)
            }
            print("user score and points - \(Apps.SCORE) - \(Apps.COINS) - \(Apps.ALL_TIME_RANK) - \(userScores.coins) - \(userScores.points)")
        }else{
            // not available add it to user default
            UserDefaults.standard.set(try? PropertyListEncoder().encode(UserScore.init(coins: 0, points: 0)), forKey: "UserScore")
        }
        
        //register nsnotification for latter call for play music and stop music
        NotificationCenter.default.addObserver(self,selector: #selector(self.PlayBackMusic),name: NSNotification.Name(rawValue: "PlayMusic"),object: nil) // for play music
        NotificationCenter.default.addObserver(self,selector: #selector(self.StopBackMusic),name: NSNotification.Name(rawValue: "StopMusic"),object: nil) // for stop music
        if UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) != nil {
            sysConfig = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        }
       // getUserNameImg()
       // self.ObserveInvitation()
       // test()
        backTopImg.setCellShadow()
//        backTopImg.layer.shadowColor = UIColor.gray.cgColor
//        backTopImg.layer.shadowOffset = CGSize(width: 0, height: 1)
//        backTopImg.layer.shadowOpacity = 1
//        backTopImg.layer.shadowRadius = 1.0
//        backTopImg.clipsToBounds = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        varSys.getDeviceInterfaceStyle()
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            if self.isUserBusy{
                self.isUserBusy = false
            }
        }
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            varSys.getUserDetails()
        }
       // sleep(2)
        getUserNameImg()
        ReLaodCategory()
    }    
    override func viewDidAppear(_ animated: Bool) {
        languageButton.isHidden = true
        iAPButton.isHidden = true
        if Apps.IN_APP_PURCHASE == "1" {
            iAPButton.isHidden = false
        }
        if isKeyPresentInUserDefaults(key: DEFAULT_SYS_CONFIG){
            let config = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
            if config.LANGUAGE_MODE == 1{
                languageButton.isHidden = false
                //open language view
                if UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG) == 0{
                    LanguageButton(self)
                }
            }
        }
        if isKeyPresentInUserDefaults(key: "isLogedin") && UserDefaults.standard.bool(forKey: "isLogedin") == true {
            if Apps.ALL_TIME_RANK as! String != "0"{
                leaderboardButton.setTitle(Apps.ALL_TIME_RANK as? String , for: .normal)
            }
            if Apps.SCORE as! String != "0"{
                allTimeScoreButton.setTitle(Apps.SCORE as? String, for: .normal)
            }
            if Apps.COINS != "0"{
                coinsButton.setTitle(Apps.COINS , for: .normal)
            }
            if !UserDefaults.standard.bool(forKey: "isLogedin"){
                return
            }
        }else{
            leaderboardButton.setTitle("0" , for: .normal) //Apps.ALL_TIME_RANK as? String
            allTimeScoreButton.setTitle("0" , for: .normal) //Apps.SCORE as? String
            coinsButton.setTitle("0" , for: .normal) //Apps.COINS
            return
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLayoutSubviews() {        
    //lottie
    // 2. Start AnimationView with animation name (without extension)
   /* animationView = .init(name: "flower")
    animationView2 = .init(name: "setting")
    animationView!.frame = CGRect(x: languageButton.frame.origin.x, y: languageButton.frame.origin.y + 50, width: languageButton.frame.width, height: languageButton.frame.height) //languageButton.bounds//view.bounds
    animationView2!.frame = CGRect(x: iAPButton.frame.origin.x, y: iAPButton.frame.origin.y + 50, width: iAPButton.frame.width, height: iAPButton.frame.height) //languageButton.bounds//view.bounds
        
      // 3. Set animation content mode
    animationView!.contentMode = .scaleAspectFit
//        animationView2!.contentMode = .scaleAspectFit
      
      // 4. Set animation loop mode
      animationView!.loopMode = .loop
      animationView2!.loopMode = .repeat(100000) //.autoReverse//.loop
      
      // 5. Adjust animation speed
      animationView!.animationSpeed = 0.5
      animationView2!.animationSpeed = 0.5
      
      view.addSubview(animationView!)
      view.addSubview(animationView2!)
      
      // 6. Play animation
      animationView!.play()
      animationView2!.play()  */
    //lottie
        
        leaderboardButton.layer.cornerRadius = leaderboardButton.frame.height / 2//4
        leaderboardButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        allTimeScoreButton.layer.cornerRadius = leaderboardButton.frame.height / 2//4
        allTimeScoreButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        coinsButton.layer.cornerRadius = coinsButton.frame.height / 2//4
        coinsButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        
        iAPButton.layer.cornerRadius = 5//iAPButton.frame.height / 3
        languageButton.layer.cornerRadius = 5//languageButton.frame.height / 3
        
       // getUserNameImg()
        tableView.reloadData()
    
    }
    func ReLaodCategory() {
        print("refresh Cell here")
        homeTblViewCell.getCatData()
        //tableView.reloadData()
        
        tableView.indexPathsForVisibleRows?.forEach {
            tableView.isHidden = true
             if let cell = tableView.cellForRow(at: $0) as? HomeTableViewCell {
                 cell.awakeFromNib()//configure()
             }
         }
        tableView.isHidden = false
    }
    func test(){
      //  func getAPIData(apiName:String, apiURL:String,completion:@escaping (NSDictionary)->Void,image:UIImageView? = nil){
                  
            let url = URL(string: "http://math.mirzapar.com/api.php")!
            let postString = "get_question=1"
                print("POST URL",url)
                print("POST String = \(postString)")
              //  print("token \(GetTokenHash())")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = Data(postString.utf8)
           // request.addValue("Bearer \(GetTokenHash())", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {             // check for fundamental networking error
                    print("error=\(String(describing: error))")
                    //let res = ["status":false,"message":"JSON Parser Error - NW Error"] as NSDictionary
                   // completion(res)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {   // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                   // let res = ["status":false,"message":"JSON Parser Error - HTTP Error"] as NSDictionary
                   // completion(res)
                    return
                }
                
                if let jsonObj = ((try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary) as NSDictionary??) {
                    if (jsonObj != nil)  {
                        print(jsonObj)
                      //  completion(jsonObj!)
                    }else{
                       // let res = ["status":false,"message":"JSON Parser Error - API Error"] as NSDictionary
                       // completion(res)
                        print("JSON API ERROR",String(data: data, encoding: String.Encoding.utf8)!)
                    }
                }else{
                    //let res = ["error":"false","message":"Error while fetching data"] as NSDictionary
                    print("JSON API ERROR",String(data: data, encoding: String.Encoding.utf8)!)
                  //  completion(res)
                }
            }
            task.resume()
        //}
    }
//    func LoadData(jsonObj:NSDictionary){
//        print("RS",jsonObj)
//        let status = jsonObj.value(forKey: "error") as! String
//        if (status == "true"){
//        }else{
//            //get data for category
//            catData.removeAll()
//            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
//                for val in data{
//                    catData.append(Category.init(id: "\(val["id"]!)", name: "\(val["category_name"]!)", image: "\(val["image"]!)", maxlvl: "\(val["maxlevel"]!)", noOf: "\(val["no_of"]!)", noOfQues: "\(val["no_of_que"]!)"))
//                }
//            }
//
//        }
//
//        //Add tableview cells
//        DispatchQueue.main.async {
//            self.tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "LearningZone")
//            self.tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "QuizZone")
//            self.tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "PlayZone")
//            self.tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "BattleZone")
//            self.tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "ContestZone")
//        }
//    }
    func logOutUserAndGoBackToLogin(){
        dUser!.userLogOut(dUser!)
//        if self.dUser!.userType == "apple"{
//           // if app is not loged in than navigate to loginview controller
//           UserDefaults.standard.set(false, forKey: "isLogedin")
//           UserDefaults.standard.removeObject(forKey: "fr_code")
//           UserDefaults.standard.removeObject(forKey: "user")
//
//           //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//           let initialViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "LoginView")
//
//           let navigationcontroller = UINavigationController(rootViewController: initialViewController)
//           navigationcontroller.setNavigationBarHidden(true, animated: false)
//           navigationcontroller.isNavigationBarHidden = true
//
//            UIApplication.shared.windows.first!.rootViewController = navigationcontroller
//           return
//       }
//        if Auth.auth().currentUser != nil {
//            do {
//                try Auth.auth().signOut()
//                UserDefaults.standard.removeObject(forKey: "isLogedin")
//                //remove friend code
//                UserDefaults.standard.removeObject(forKey: "fr_code")
//                UserDefaults.standard.removeObject(forKey: "user")
//
//                let initialViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "LoginView")
//                let navigationcontroller = UINavigationController(rootViewController: initialViewController)
//                navigationcontroller.setNavigationBarHidden(true, animated: false)
//                navigationcontroller.isNavigationBarHidden = true
//                UIApplication.shared.windows.first!.rootViewController = navigationcontroller
//
////                self.navigationController?.popToViewController( (self.navigationController?.viewControllers[0]) as! LoginView, animated: true)
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//        }
    }
    func getUserNameImg(){
        //user name and display image
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            print("user data - \(dUser!)")
            if dUser?.status == "0" { //user status is - deactivated
                ShowAlert(title: Apps.DEACTIVATED, message: "\(Apps.HELLO) \(dUser!.name)\n \(Apps.DEACTIVATED_MSG)")
                logOutUserAndGoBackToLogin()
                return
            }
            userName.text = "\(dUser!.name)" //\(Apps.HELLO)  
          
            imgProfile.layer.cornerRadius =  imgProfile.frame.height / 2
            imgProfile.layer.masksToBounds = true
            imgProfile.clipsToBounds = true
            imgProfile.layer.borderWidth = 2
            imgProfile.layer.borderColor = UIColor.white.cgColor
            
            imgProfile.isUserInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            imgProfile.addGestureRecognizer(tapRecognizer)
            
            DispatchQueue.main.async {
                if(self.dUser!.image != ""){
                    self.imgProfile.loadImageUsingCache(withUrl: self.dUser!.image)
                }else{
                    self.imgProfile.image = UIImage(systemName: "person.fill") //UIImage(named: "guest")
                }
            }
        }else{
            userName.text = "\(Apps.USER)" //\(Apps.HELLO)
            imgProfile.image = UIImage(systemName: "person.fill")//UIImage(named: "guest") //"user")
        }
    }
        
    @objc func imageTapped(gestureRecognizer: UITapGestureRecognizer) {
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "UpdateProfileView")
            self.addTransition()
            self.navigationController?.pushViewController(viewCont, animated: false)
//            self.navigationController?.pushViewController(viewCont, animated: true)
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func moreBtn(_ sender: UIButton) {        
        //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "MoreOptions")
        addTransitionAndPushViewController(viewCont,.fromLeft)
      //  self.navigationController?.pushViewController(viewCont, animated: true)
        
    }    
    
    // play background music function
    @objc func PlayBackMusic(){
        backgroundMusicPlayer.play()
    }
    
    // stop background music function
    @objc func StopBackMusic(){
        backgroundMusicPlayer.stop()
    }
   
   /* func showAllCategories(){
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        //check if language is enabled and not selected

        //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "subcategoryview") as! subCategoryViewController
        self.navigationController?.pushViewController(viewCont, animated: true)
    } */
    
    @IBAction func leaderboardBtn(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "Leaderboard")
            self.addTransition()
            self.navigationController?.pushViewController(viewCont, animated: false)
//            self.navigationController?.pushViewController(viewCont, animated: true)
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    @IBAction func LanguageButton(_ sender: Any){
        //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let view = Apps.storyBoard.instantiateViewController(withIdentifier: "LanguageView") as! LanguageView
        view.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        view.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        view.delegate = self
        self.present(view, animated: true, completion: nil)
    }
    @IBAction func IAPButton(_ sender: Any){
//        if UserDefaults.standard.bool(forKey: "isLogedin"){
        //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier:"CoinStoreViewController") as! CoinStoreViewController
        addTransition()
        self.navigationController?.pushViewController(viewCont, animated: false)//true
//        }else{
//            self.navigationController?.popToRootViewController(animated: true)
//        }
    }
    
    //tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier = "QuizZone"
        if indexPath.row == 0 {
            cellIdentifier = "MathsZone"
        }
        if indexPath.row == 1 {
            cellIdentifier = "LearningZone"
        }
        if indexPath.row == 2 {
            cellIdentifier = "QuizZone"
        }
        if indexPath.row == 3 {
            cellIdentifier = "PlayZone"
        }
        if indexPath.row == 4 {
            cellIdentifier = "BattleZone"
        }
        if indexPath.row == 5 {
            cellIdentifier = "ContestZone"
        }
      
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HomeTableViewCell
       // print("test -- \(arr[indexPath.row])")
        cell.cellDelegate = self
        cell.titleLabel.text = arr[indexPath.row]
        cell.titleLabel.frame = (deviceStoryBoard == "Ipad") ? CGRect(x: 80, y: 4, width: 508, height: 25) : CGRect(x: 52, y: 11, width: 270, height: 20)
        cell.leftImg.image = UIImage(named: leftImg[indexPath.row])
        //cell.leftImg.frame = (deviceStoryBoard == "Ipad") ? CGRect(x: 9, y: 4, width: 61, height: 28) : CGRect(x: 18, y: 5, width: 33, height: 28)
        
//        if indexPath.row == 0 {
//            if Apps.LEARNING_MODE ==  "0" {
//                cell.alpha = 0
//            }else{
//                cell.alpha = 1
//            }
//        }
        return cell
    }
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          return 15
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightVal:CGFloat = 0
        if indexPath.row == 0 { //Maths Zone
            if Apps.MATHS_MODE == "0"{ //if disabled from admin panel
                //arr.removeFirst()
                heightVal = 0
            }else{
                heightVal = (deviceStoryBoard == "Ipad" ? 400 : 225 )
            }
            return heightVal
        }else if indexPath.row == 1 { //Learning Zone
            if Apps.LEARNING_MODE == "0"{ //if disabled from admin panel
                //arr.removeFirst()
                heightVal = 0
            }else{
                heightVal = (deviceStoryBoard == "Ipad" ? 400 : 225 )
            }
            return heightVal
        }else if indexPath.row == 3 { //playzone
            heightVal = (deviceStoryBoard == "Ipad" ? 550 : 350 )//800//400
            return heightVal
        }else if indexPath.row == 4 { //BattleZone
            heightVal = (deviceStoryBoard == "Ipad" ? 750 : 450 )//950 //400) //350
            return heightVal
        }else if indexPath.row == 5 { //Contest Zone
            if Apps.CONTEST_MODE == "0"{ //if disabled from admin panel
                heightVal = 0
            }else{
                heightVal = (deviceStoryBoard == "Ipad" ? 400 : 225 )
            }
            return heightVal
        }else{
            heightVal = (deviceStoryBoard == "Ipad" ? 400 : 225 )//300)
            return heightVal
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected - \(indexPath.row)")
    }
    
    @IBAction func viewAllCategory(_ sender: Any) {
        //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "categoryview") as! CategoryViewController
        self.addTransition()
        self.navigationController?.pushViewController(viewCont, animated: false)
//        self.navigationController?.pushViewController(viewCont, animated: true)
    }
}
extension HomeScreenController:CellSelectDelegate{
        
   
    func didCellSelected(_ type: String,_ rowIndex: Int){
        print("FUNCTION HERE \(type) -- catdata total \(catData.count) -- row Index - \(rowIndex)")
                
        //[Apps.DAILY_QUIZ_PLAY,Apps.RNDM_QUIZ,Apps.TRUE_FALSE,Apps.SELF_CHLNG]
        if type == "playzone-0"{
            getQuestions("daily")
        }else if type == "playzone-1"{
            getQuestions("random")
        }else if type == "playzone-2"{
            getQuestions("true/false")
        }else if type == "playzone-3"{ //self challenge
                //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "SelfChallengeController")
                self.addTransition()
                self.navigationController?.pushViewController(viewCont, animated: false)
//            self.navigationController?.pushViewController(viewCont, animated: true)
        }else if type == "learningzone"{ //Learning //playzone-4
               //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
               let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "categoryview") as! CategoryViewController
                viewCont.apiExPeraforLang = "&type=2"
                viewCont.type = 2
                self.addTransition()
                self.navigationController?.pushViewController(viewCont, animated: false)
//            self.navigationController?.pushViewController(viewCont, animated: true)
        }else if type == "mathszone"{ //Maths
               //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
               let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "categoryview") as! CategoryViewController
                viewCont.apiExPeraforLang = "&type=3"
                viewCont.type = 3
                self.addTransition()
                self.navigationController?.pushViewController(viewCont, animated: false)
//            self.navigationController?.pushViewController(viewCont, animated: true)
        }else if (type == "battlezone-0") || (type == "battlezone-1") { //Group Battle || one vs one Battle
            if UserDefaults.standard.bool(forKey: "isLogedin"){
              //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
              let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "GroupBattleTypeSelection")as! GroupBattleTypeSelection
                viewCont.selection = (type == "battlezone-0") ? Apps.GRP_BTL : Apps.ONE_TO_ONE_BTL  //Apps.GRP_BTL
//                viewCont.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//                viewCont.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//                self.present(viewCont, animated: true, completion: nil)
                self.addTransition()
                self.navigationController?.pushViewController(viewCont, animated: false)
//                self.navigationController?.pushViewController(viewCont, animated: true)
            }else{
              self.navigationController?.popToRootViewController(animated: true)
            }
      /*  }else if type == "battlezone-1"{ //one vs one Battle
            if UserDefaults.standard.bool(forKey: "isLogedin"){
              let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "GroupBattleTypeSelection") as! GroupBattleTypeSelection
              viewCont.selection = Apps.ONE_TO_ONE_BTL
              self.navigationController?.pushViewController(viewCont, animated: true)
            }else{
              self.navigationController?.popToRootViewController(animated: true)
            } */
        }else if type == "battlezone-2"{ //Random Battle
            if UserDefaults.standard.bool(forKey: "isLogedin"){
                if Apps.RANDOM_BATTLE_WITH_CATEGORY == "1"{
                    //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                    let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "categoryview") as! CategoryViewController
                    //pass value to identify to jump to battle and not play quiz view.
                    viewCont.isCategoryBattle = true
                    self.addTransition()
                    self.navigationController?.pushViewController(viewCont, animated: false)
//                    self.navigationController?.pushViewController(viewCont, animated: true)
                }else{
                   // let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                    let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "BattleViewController")
                    self.addTransition()
                    self.navigationController?.pushViewController(viewCont, animated: false)
//                    self.navigationController?.pushViewController(viewCont, animated: true)
                }
            }else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else if type == "ContestView" {
            if UserDefaults.standard.bool(forKey: "isLogedin"){
              //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
              let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: type)
                self.addTransition()
                self.navigationController?.pushViewController(viewCont, animated: false)
//                self.navigationController?.pushViewController(viewCont, animated: true)
            }else{
              self.navigationController?.popToRootViewController(animated: true)
            }
        }else{
            self.PlaySound(player: &audioPlayer, file: "click") // play sound
            self.Vibrate() // make device vibrate
            //check if language is enabled and not selected
            if languageButton.isHidden == false{
                if UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG) == 0 {
                    LanguageButton(self)
                }
            }
            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        
            if type == "subcategoryview"{
                let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: type) as! subCategoryViewController
                if (UserDefaults.standard.value(forKey: "categories") != nil){
                    self.catData = try! PropertyListDecoder().decode([Category].self,from:(UserDefaults.standard.value(forKey: "categories") as? Data)!)
                }
                viewCont.catID = catData[rowIndex].id
                viewCont.catName = catData[rowIndex].name
                print("call subcategoryview with id and name - \(catData[rowIndex].id) - \(catData[rowIndex].name)")
                self.addTransition()
                self.navigationController?.pushViewController(viewCont, animated: false)
//                self.navigationController?.pushViewController(viewCont, animated: true)
            }else if type == "LevelView"{
                let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: type) as! LevelView
                if (UserDefaults.standard.value(forKey: "categories") != nil){
                    self.catData = try! PropertyListDecoder().decode([Category].self,from:(UserDefaults.standard.value(forKey: "categories") as? Data)!)
                }
                if catData[rowIndex].maxlvl != "0" { //if there's no levels or no questions then do nothing 
                    if catData[rowIndex].maxlvl.isInt{
                        viewCont.maxLevel = Int(catData[rowIndex].maxlvl)!
                    }
                    viewCont.catID = Int(self.catData[rowIndex].id)!
                    viewCont.questionType = "main"
                    self.addTransition()
                    self.navigationController?.pushViewController(viewCont, animated: false)
//                    self.navigationController?.pushViewController(viewCont, animated: true)
                }else{
                    ShowAlertOnly(title: "", message: Apps.NOT_ENOUGH_QUESTION_TITLE)
                }
                
            }else{
                let viewCont = storyboard.instantiateViewController(withIdentifier: type)
                self.addTransition()
                self.navigationController?.pushViewController(viewCont, animated: false)
//                self.navigationController?.pushViewController(viewCont, animated: true)
            }            
        }
    }
    
    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }
    
    func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                    throw VersionError.invalidResponse
                }
                completion(version != currentVersion, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
    
    func CheckAppsUpdate(){
        _ = try? isUpdateAvailable { (update, error) in
            if let error = error {
                print("APPS UPDATE",error)
            } else if let update = update {
                print("Apps UPDATE SU",update)
            }
        }
    }
    
    func popupUpdateDialogue(){
        let alert = UIAlertController(title: Apps.UPDATE_TITLE, message: Apps.UPDATE_MSG, preferredStyle: .alert)
        
        let okBtn = UIAlertAction(title: Apps.UPDATE_BUTTON, style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let url = URL(string: Apps.SHARE_APP),
                UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        })
        let noBtn = UIAlertAction(title:Apps.SKIP , style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
        })
        alert.addAction(okBtn)
        alert.addAction(noBtn)
        self.present(alert, animated: true, completion: nil)
        
    }
    func getQues(_ type: Int){
        //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
        if type == 1{
            viewCont.playType = "RandomQuiz"
        }else{
            viewCont.playType = "TrueFalse"
        }
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        var quesData: [QuestionWithE] = []
        var apiURL = ""
       //if sysConfig.LANGUAGE_MODE == 1{
          //  let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
            apiURL = "&type=\(type)&limit=10" //type 1 -> random quiz and type 2 -> true-false
       // }
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            self.getAPIData(apiName: "get_questions_by_type", apiURL: apiURL,completion: {jsonObj in
                print("JSON",jsonObj)
                //close loader here
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                    DispatchQueue.main.async {
                        self.DismissLoader(loader: self.Loader)
                    }
                });
                let status = jsonObj.value(forKey: "error") as! String
                if (status == "true") {
                    //self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                }else{
    //                loadTrueFalseQues(jsonObj: jsonObj)
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
//                                    self.navigationController?.pushViewController(viewCont, animated: true)
                                }
                            })
                        }
                    }
                }
            })
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    
    func getQuestions(_ type: String){ //type should be random,true/false or daily only
        
        //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
        //viewCont.playType = "daily"
        
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        var quesData: [QuestionWithE] = []
        var apiURL = ""
        var apiName = "get_daily_quiz"
        
        if sysConfig.LANGUAGE_MODE == 1{
            let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
            apiURL += "language_id=\(langID)"
        }
        if(Reachability.isConnectedToNetwork()){
        Loader = LoadLoader(loader: Loader)
        if type == "random"{
            apiName = "get_questions_by_type" //"get_random_questions"
            apiURL += "&type=1&limit=\(Apps.TOTAL_PLAY_QS)&"  //1=normal ,2 = true/false
            viewCont.titlebartext = "Random Quiz"
            viewCont.playType = "RandomQuiz"
        }else if type == "true/false"{
            apiName = "get_questions_by_type"
            apiURL += "&type=2&limit=\(Apps.TOTAL_PLAY_QS)"
            viewCont.titlebartext = "True/False"
            viewCont.playType = "true/false"
        }else{ //Daily
            apiName = "get_daily_quiz"
            apiURL += "&user_id=\(dUser?.userID ?? "1")"
            viewCont.playType = "daily"
        }
        self.getAPIData(apiName: "\(apiName)", apiURL: apiURL,completion: {jsonObj in
            print("api name and url - \(apiName) - \(apiURL)")
            print("JSON",jsonObj)
            let status = jsonObj.value(forKey: "error") as! String
            if (status == "true") {
                //self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                //show random 10 questions if there are no questions in daily quiz.
                let msg = jsonObj.value(forKey: "message")! as! String
                if msg != "" && msg == "daily quiz already played" {
                   // self.DismissLoader(loader: self.Loader)
                    self.ShowAlert(title: Apps.PLAYED_ALREADY, message: Apps.PLAYED_MSG)
                }else{
                    var apiURL = ""
                    if self.sysConfig.LANGUAGE_MODE == 1{
                           let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
                           apiURL = "&language_id=\(langID)" //+=
                   }
                    if viewCont.playType != "daily" {
                        self.getAPIData(apiName: "get_random_questions_for_computer", apiURL: apiURL,completion: loadQuestions)
                    }else{
                        DispatchQueue.main.async {
                            self.DismissLoader(loader: self.Loader)
                            self.ShowAlert(title: Apps.NO_QSTN, message: Apps.NO_QSTN_MSG)
                        }
                    }
                }
            }else{
                //close loader here
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                    DispatchQueue.main.async {
                        self.DismissLoader(loader: self.Loader)
                    }
                });
               loadQuestions(jsonObj: jsonObj)
            }
        })
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        
        func loadQuestions(jsonObj:NSDictionary){
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
//                            self.navigationController?.pushViewController(viewCont, animated: true)
                        }
                    })
                }
            }
        }
    }
    
    //battle modes
    /*    @objc func MakeUserOnline(){
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            if let userDT = UserDefaults.standard.value(forKey:"user"){
                let user = try! PropertyListDecoder().decode(User.self, from: (userDT as? Data)!)
                var userDetails:[String:String] = [:]
                // userDetails["UID"] = user.UID
                userDetails["userID"] = user.userID
                userDetails["name"] = user.name
                userDetails["image"] = user.image
                userDetails["status"] = "free"
                // set data for available to battle with users in firebase database
                self.ref.child(user.UID).setValue(userDetails)
            }
        }
    }
    
      @objc func MakeUserOffiline(){
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            if let userDT = UserDefaults.standard.value(forKey:"user"){
                let ref = Database.database().reference().child(Apps.ROOM_NAME)
                let user = try! PropertyListDecoder().decode(User.self, from: (userDT as? Data)!)
                ref.child(user.UID).removeValue()
            }
        }
    }
    
         @objc func ShowInvitationAlert(){
        
        if self.isUserBusy{
            ref.removeAllObservers()
            return
        }        
        
        
        let alert = UIAlertController(title: "Game Invitation", message: "You have been invited to room \(self.roomDetails!.roomName) by your friend", preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "Invitation Accepted", style: .default, handler: {_ in
            print("Invitation accepted")
            //add PrivateRoomView and uncomment this section
//            DispatchQueue.main.async {
//                let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//                let viewCont = storyboard.instantiateViewController(withIdentifier: "PrivateRoomView") as! PrivateRoomView
//
//                viewCont.roomInfo = self.roomDetails
//                viewCont.selfUser = false
//                self.isUserBusy = true
//
//                self.navigationController?.pushViewController(viewCont, animated: true)
//                let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
//                let refR = Database.database().reference().child(Apps.PRIVATE_ROOM_NAME).child(self.roomDetails!.roomFID).child("joinUser").child(user.UID)
//                refR.child("isJoined").setValue("true")
//
//                self.ref.child(user.UID).child("status").setValue("busy")
//            }
        })
        let rejectAction = UIAlertAction(title: "Invitation Rejected", style: .cancel, handler: {_ in
            print("Invitation rejected")
            
            let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            
            let refR = Database.database().reference().child(Apps.PRIVATE_ROOM_NAME).child(self.roomDetails!.roomFID).child("joinUser")
            refR.child(user.UID).removeValue()
            
            self.ref.removeAllObservers()
            refR.removeAllObservers()
            
            let refOnline = Database.database().reference().child(Apps.ROOM_NAME).child(user.UID)
            refOnline.child("status").setValue("free")
            refOnline.removeAllObservers()
            
        })
        
        alert.addAction(acceptAction)
        alert.addAction(rejectAction)
        
        self.present(alert, animated: true, completion: nil)
        
        if Apps.badgeCount > 0 {
            Apps.badgeCount -= 1
            UserDefaults.standard.set(Apps.badgeCount, forKey: "badgeCount")           
        }
        UIApplication.shared.applicationIconBadgeNumber = Apps.badgeCount
    }
    
func ObserveInvitation(){
        if self.isUserBusy{
            ref.removeAllObservers()
            return
        }
        if UserDefaults.standard.bool(forKey: "isLogedin"){
        let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        let  ref = Database.database().reference().child(Apps.PRIVATE_ROOM_NAME)
        ref.observe(.value, with: { (snapshot) in
            if let data = snapshot.value as? [String:Any]{
                for val in data{
                    if let fireroom = val.value as? [String:Any]{
                        if  "\(fireroom["isStarted"] ?? "false")".bool ?? false{
                            // room is already started
                            continue
                        }
                        if "\(fireroom["isRoomActive"] ?? "false")".bool ?? false {
                            // room is active still & room is not started
                        }else{
                            //room is deactive by room owner
                            continue
                        }
                        if let roomUser = fireroom["roomUser"] as? [String:Any]{
                            if  let joinUser = fireroom["joinUser"] as? [String:Any]{
                                for ju in joinUser{
                                    if let udj = ju.value as? [String:Any]{
                                        if "\(udj["userID"]!)" == "\(roomUser["userID"] ?? "0")"{
                                            // same user do not show any invitation alert
                                            continue
                                        }else{
                                            if joinUser.keys.contains(user.UID){
                                                if let uUser = joinUser[user.UID] as? [String:Any]{
                                                    // print("UU USER",uUser)
                                                    if uUser["userID"] as! String == "\(roomUser["userID"] ?? "0")"{
                                                        // same user do not show any invitation alert
                                                        continue
                                                    }
                                                }
                                                //print("User got invitation here")
                                                self.roomDetails = RoomDetails.init(ID:  "\(fireroom["roomID"]!)", roomFID: val.key, userID: "\(roomUser["userID"] ?? "0")", roomName: "\(fireroom["roomName"]!)", catName: "\(fireroom["category"]!)", catLavel: "\( fireroom["catLavel"] ?? "0")", noOfPlayer: "\(fireroom["noOfPlayer"]!)", noOfQues: "\(fireroom["noOfQuestion"]!)", playTime: "\( fireroom["time"]!)")
                                                
                                                self.ShowInvitationAlert()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
        })
        }
    } */
    
   /* func timeFormatter(_ totalSeconds: Int) -> String {
            let seconds: Int = totalSeconds % 60
            let minutes: Int = (totalSeconds / 60) % 60
//            let hours: Int = (totalSeconds / 60 / 60) % 24
//            let days: Int = (totalSeconds / 60 / 60 / 24)
            return String(format: "%02d : %02d", minutes, seconds)
        }*/
    
}
