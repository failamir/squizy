import Foundation
import UIKit
import AVFoundation
import FirebaseDatabase
import CallKit

class OneToOneRoomBattlePlayView: UIViewController, UIScrollViewDelegate, CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded == true {
            print("Disconnected")
        }
        
        if call.isOutgoing == true && call.hasConnected == false {
            print("Dialing")
        }
        
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            print("Incoming")
        }
        
        if call.hasConnected == true && call.hasEnded == false {
            print("Connected")
            self.LeaveBattleProc()
        }
    }
    
    //@IBOutlet weak var timerLabel:UILabel!
    @IBOutlet var questionView: UIView!
    @IBOutlet weak var mainQuestionLbl: UITextView!
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var mainQuesCount: UILabel!

    @IBOutlet weak var imageQuestionLbl: UITextView!
    
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var secondChildView: UIView!
    
    @IBOutlet weak var battleScoreView: UIView!
    
    @IBOutlet weak var btnA: ResizableButton!
    @IBOutlet weak var btnB: ResizableButton!
    @IBOutlet weak var btnC: ResizableButton!
    @IBOutlet weak var btnD: ResizableButton!
    @IBOutlet weak var btnE: ResizableButton!
    
    @IBOutlet weak var leaveButton:UIButton!
    
    @IBOutlet weak var timerView: UIView!
    
    @IBOutlet weak var player1Img: UIImageView!
    @IBOutlet weak var player1Name: UILabel!
    @IBOutlet weak var userCount1: UILabel!
    @IBOutlet weak var player2Img: UIImageView!
    @IBOutlet weak var player2Name: UILabel!
    @IBOutlet weak var userCount2: UILabel!
    
    var battleUser:BattleUser!
    var user:User!
    
   // @IBOutlet weak var collectionView:UICollectionView!
    var progressRing: CircularProgressBar!
    var timer: Timer?
    
    var count: CGFloat = 0.0
    var rightCount = 0
    var wrongCount = 0
    var myAnswer = false
    var oppAnswer = false
   // var stopCount = false
    var oppSelectedAns = ""
    var zoomScale:CGFloat = 1
    var opponentRightCount = 0
    
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var quesData: [QuestionWithE] = []
    var currentQuestionPos = 0
    
    var joinedUsers:[JoinedUser] = []
    var ref: DatabaseReference!
    var observeQues = 0
    var sysConfig:SystemConfiguration!
    var hasLeave = false
    var callObserver: CXCallObserver!
    var roomInfo:RoomDetails?
    var seconds = 0
    
    var roomType = "private"
    var roomCode = "00000"
    var isCompleted = false
    var selection = Apps.GRP_BTL
    var tblName = "OneToOneRoom"//"MultiplayerRoom"
    
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
        
        callObserver = CXCallObserver()
        callObserver.setDelegate(self, queue: nil) // nil queue means main thread
        
        player1Img.layer.borderWidth = 2
        player1Img.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
        player1Img.layer.cornerRadius = player1Img.bounds.width / 2
        player1Img.clipsToBounds = true
        
        player2Img.layer.borderWidth = 2
        player2Img.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
        player2Img.layer.cornerRadius = player2Img.bounds.width / 2
        player2Img.clipsToBounds = true
        
//        NotificationCenter.default.post(name: Notification.Name("PlayMusic"), object: nil)
        //show 4 options by default & set 5th later by checking for opt E mode
        btnE.isHidden = true
        hasLeave = false
        buttons = [btnA,btnB,btnC,btnD]
        
        // set refrence for firebase database
        //tblName = "OneToOneRoom" //(selection == Apps.GRP_BTL) ? "MultiplayerRoom" : "OneToOneRoom"
        self.ref = Database.database().reference().child(tblName) //AvailUserForBattle
        mainQuestionLbl.centerVertically()
        imageQuestionLbl.centerVertically()
        
        self.seconds = Int(Apps.GROUP_BTL_WAIT_TIME) //Int(self.roomInfo!.playTime)! * 60
        
        self.questionView.DesignViewWithShadow()
        user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        print("both users name - \(user.name) -  \(battleUser.name)")
        player1Name.text = user.name
        player2Name.text = battleUser.name
        DispatchQueue.main.async {
            self.player1Img.loadImageUsingCache(withUrl: self.user.image)
            self.player2Img.loadImageUsingCache(withUrl: self.battleUser.image)
        }
        
        //user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        
        sysConfig = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)

            let apiURL = "room_id=\(self.roomCode)"
            self.getAPIData(apiName: "get_question_by_room_id", apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        NotificationCenter.default.addObserver(self,selector: #selector(self.CompleteBattle),name: NSNotification.Name(rawValue: "CompleteBattle"),object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.DismissSelf),name: NSNotification.Name(rawValue: "CloseBattlePlay"),object: nil) // close this view controller
        NotificationCenter.default.addObserver(self,selector: #selector(self.goToRootViewController),name: NSNotification.Name(rawValue: "goToRootViewController"),object: nil)
    
        // add ring progress to timer view
        if deviceStoryBoard == "Ipad"{
//            progressRing = CircularProgressBar(radius:28, position: CGPoint(x: battleScoreView.center.x - 20, y: battleScoreView.center.y), innerTrackColor: Apps.defaultInnerColor, outerTrackColor: Apps.defaultOuterColor, lineWidth: 6) //y: timerView.center.y - 20 //timerView
//            progressRing.progressLabel.font = progressRing.progressLabel.font.withSize(20)
            progressRing = CircularProgressBar(radius:25, position: CGPoint(x: battleScoreView.center.x - 20, y: battleScoreView.center.y - 10), innerTrackColor: Apps.defaultInnerColor, outerTrackColor: Apps.defaultOuterColor, lineWidth: 6)
            progressRing.progressLabel.font = progressRing.progressLabel.font.withSize(18)
        }else{
//            let xPosition = battleScoreView.center.x + 5
//            let yPosition = battleScoreView.center.y - 15
//            let position = CGPoint(x: xPosition, y: yPosition)
//            progressRing = CircularProgressBar(radius: (battleScoreView.frame.size.height) / 3, position: position, innerTrackColor: Apps.defaultInnerColor, outerTrackColor: Apps.defaultOuterColor, lineWidth: 6)
            progressRing = CircularProgressBar(radius: 18, position: CGPoint(x: battleScoreView.center.x - 20, y: battleScoreView.center.y - 10), innerTrackColor: Apps.defaultInnerColor, outerTrackColor: Apps.defaultOuterColor, lineWidth: 6) //timerView //battleScoreView.center.x - 20,battleScoreView.center.y + 3
        }
        battleScoreView.layer.addSublayer(progressRing) //timerView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        clearColor()
    }
    
//    func DesignViews(battleHeight:CGFloat){
//        let battleFrame = CGRect(x: self.battleScoreView.frame.origin.x, y: self.battleScoreView.frame.origin.y, width: self.battleScoreView.frame.width, height: battleHeight)
//        self.battleScoreView.frame = battleFrame
//
//        let secondFrame = CGRect(x: self.secondChildView.frame.origin.x, y: self.battleScoreView.frame.height + self.battleScoreView.frame.origin.y + 20, width: self.secondChildView.frame.width, height: self.secondChildView.frame.height)
//        self.secondChildView.frame = secondFrame
//    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return questionImageView
    }
    @objc func DismissSelf(){
        addPopTransition()
        self.navigationController?.popViewController(animated: false)
//        self.navigationController?.popViewController(animated: true)
        self.ref.removeAllObservers()
        //goto GroupBattleTypeSelection Instead of OnetoOneBattleView
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "GroupBattleTypeSelection")as! GroupBattleTypeSelection
          viewCont.selection = Apps.ONE_TO_ONE_BTL
         self.addTransition()
         self.navigationController?.pushViewController(viewCont, animated: false)
//        self.navigationController?.pushViewController(viewCont, animated: true)
      /*  let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "OneToOneBattleView") as! OneToOneBattleView
        viewCont.isUserJoininig = false
//        viewCont.player2Img.image = UIImage(systemName: "person.fill")
//        viewCont.player2Name.text = Apps.PLYR2
        viewCont.selection = Apps.ONE_TO_ONE_BTL// self.selection
        self.navigationController?.pushViewController(viewCont, animated: true) */
    }
    @objc func goToRootViewController(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func settingButton(_ sender: Any) {
        // let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
//        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier:"SettingsAlert") as! SettingsAlert
        myAlert.modalPresentationStyle = .overCurrentContext
        myAlert.parentName = "play"
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func LeaveBattle(_ sender: Any) {
        let alert = UIAlertController(title: Apps.EXIT_APP_MSG,message: "",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            self.LeaveBattleProc()
           
        }))
        alert.view.tintColor = (Apps.APPEARANCE == "dark") ? UIColor.white : UIColor.black //UIColor.black  // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
    }
    
    func LeaveBattleProc(){
        self.hasLeave = true
        let users = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        let refR = ref.child(roomCode).child("joinUser").child(users.UID)
        let refRoom = ref.child(roomCode)
        if refRoom != nil {
            refR.child("isLeave").setValue("true")
            let roomVal = ref.child(roomCode)
            roomVal.observeSingleEvent(of: .value, with: { (snapshot) in
                 if let data = snapshot.value as? [String:Any]{
                    print(data)
                    let authID = data["authId"] as! String
                   // print(authID)
                    if authID == self.user.UID {
                        roomVal.child("isRoomActive").setValue("false")
                    }
                 }
            })
            if  let index = self.joinedUsers.firstIndex(where: {$0.uID == "\(user.UID)"}){
                self.joinedUsers[index].isLeave = true
               // self.collectionView.reloadData()
            }
            if (self.timer?.isValid) != nil {
                self.timer!.invalidate()
            }
            ref.child(roomCode).removeValue()
            self.ref.removeAllObservers()
            if(Reachability.isConnectedToNetwork()){
                let apiURL = "room_id=\(self.roomCode)"
                self.getAPIData(apiName: "destroy_room_by_room_id", apiURL: apiURL,completion: {_ in })
            }
        }
//        NotificationCenter.default.post(name: Notification.Name("StopMusic"), object: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func CompleteBattle(){
        if self.isCompleted{
            return
        }
        if timer != nil && timer!.isValid{
            timer!.invalidate()
        }
        if ref != nil{
            self.ref.removeAllObservers()
            self.ref.removeValue()
            self.ref = nil
        }
        
        if(Reachability.isConnectedToNetwork()){
            let apiURL = "room_id=\(self.roomCode)"
            self.getAPIData(apiName: "destroy_room_by_room_id", apiURL: apiURL,completion: {_ in })
        }
        showResultView()
    }
    //load data here
    func LoadData(jsonObj:NSDictionary){
        print("Questions by Room ID one Vs one - Response - ",jsonObj)
        let status = "\(jsonObj.value(forKey: "error")!)".bool!
        if (status) {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
        }else{
            //get data for category
            // print(jsonObj.value(forKey: "data") as Any)
            self.quesData.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", optionA: "\(val["optiona"]!)", optionB: "\(val["optionb"]!)", optionC: "\(val["optionc"]!)", optionD: "\(val["optiond"]!)", optionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType: "\(val["question_type"]!)"))
                }
                print("total number of questions loaded - \(quesData.count) - & Apps Value is - \(Apps.TOTAL_PLAY_QS)")
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
               // self.animationView()
                self.DismissLoader(loader: self.Loader)
//                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.incrementCount), userInfo: nil, repeats: true)
//                self.timer!.fire()
                self.ObserveUser(self.roomCode)
                self.LoadQuestion()
                self.ObserveData()
                //print("QSN",self.quesData.count)
            }
        });
    }
    
    func ObserveUser(_ roomcode: String){ 
        self.joinedUsers.removeAll()
        //tblName = "OneToOneRoom"//(selection == Apps.GRP_BTL) ? "MultiplayerRoom" : "OneToOneRoom"
        let refR = Database.database().reference().child(tblName).child(roomcode).child("joinUser")//.child(self.roomType == "private" ? Apps.PRIVATE_ROOM_NAME : Apps.PUBLIC_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser")
            refR.observe(.value, with: {(snapshot) in
            print("Observe val",snapshot)
            if let data = snapshot.value as? [String:Any]{
                print("DATA",data)
                self.joinedUsers.removeAll()
                    for val in data{
                        if let user = val.value as? [String:Any]{
                            if user["name"] != nil {
                                self.joinedUsers.append(JoinedUser.init(uID: "\(user["UID"]!)", userID: "\(user["userID"]!)", userName: "\(user["name"]!)", userImage: "\(user["image"]!)", isJoined: "\(user["isJoined"]!)".bool ?? false,rightAns: "\(user["rightAns"] ?? "0")",wrongAns: "\(user["wrongAns"] ?? "0")",isLeave:  "\(user["isLeave"] ?? "false")".bool ?? false))
                        }
                    }
                }
                
               // self.collectionView.reloadData()
                
                /* if self.joinedUsers.count == 1 || self.joinedUsers.count == 2 {
                    self.DesignViews(battleHeight: 60) //50
                }else if self.joinedUsers.count == 3 || self.joinedUsers.count == 4 {
                    self.DesignViews(battleHeight: 110) //100
                }else if self.joinedUsers.count == 5 || self.joinedUsers.count == 6 {
                    self.DesignViews(battleHeight: 160) //150
                } */
                        
                let count = self.joinedUsers.filter({ $0.isLeave ?? false }).count
                if (count == self.joinedUsers.count - 1){
                    print("All User have been left")
                    if !self.hasLeave{
                        self.AllUserLeft()
                    }
                }
            }
        })
    }
    
    func AllUserLeft(){
        
        if self.isCompleted{
            return
        }        
        let alert = UIAlertController(title: "\(Apps.NO_PLYR_LEFT)",message: "",preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: Apps.EXIT, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            //self.stopCount = true
            self.navigationController?.popToRootViewController(animated: true)
            //self.LeaveBattleProc() //already done by player who have created room - so no need to call func. for other player
           
        }))
        alert.view.tintColor = (Apps.APPEARANCE == "dark") ? UIColor.white : UIColor.black //UIColor.black  // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
    }
    
    // Note only works when time has not been invalidated yet
    @objc func resetProgressCount() {
        buttons.forEach{$0.isUserInteractionEnabled = true}
        if self.timer != nil && self.timer!.isValid{
            timer!.invalidate()
        }
        progressRing.innerTrackShapeLayer.strokeColor = Apps.defaultInnerColor.cgColor
        progressRing.progressLabel.textColor = Apps.BASIC_COLOR
        self.myAnswer = false
        self.oppAnswer = false
        count = 0
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer!.fire()
    }
    
    @objc func incrementCount() {
        //if stopCount != true{
            count += 0.1
        //}
        //print("count value - \(count)")
        //self.timerLabel.text = self.secondsToHoursMinutesSeconds(seconds: Int(CGFloat(CGFloat(self.seconds) - count)))
        progressRing.progress = CGFloat(Apps.QUIZ_PLAY_TIME - count)
        if count >= 20 { //CGFloat(self.seconds - 10){
            progressRing.innerTrackShapeLayer.strokeColor = Apps.WRONG_ANS_COLOR.cgColor
            progressRing.progressLabel.textColor = Apps.WRONG_ANS_COLOR
        }
        if count >= Apps.QUIZ_PLAY_TIME { //CGFloat(self.seconds) {
            //timer!.invalidate()
            self.AddQuestionToFIR(question: quesData[self.currentQuestionPos], userAns: "")
//            wrongCount += 1
//            falseCount.text = "\(wrongCount)" //label with progressbar
            //self.SetRightWrongtoFIR()
            if Apps.TOTAL_PLAY_QS > self.currentQuestionPos{
                self.currentQuestionPos += 1
                self.LoadQuestion()
            }
            //self.ShowResultAlert()
        }
        
      /*  if count >= CGFloat(self.seconds - 10){
           //change color on based remain seconds
        }
        if count >= CGFloat(self.seconds) {
            timer!.invalidate()
            self.SetRightWrongtoFIR()
            self.ShowResultAlert()
        } */
    }
    
    //load question here
    func LoadQuestion(){
        print("LoadQuestion called !!! \(currentQuestionPos) - \(quesData.count)")
        if(currentQuestionPos  < quesData.count) {
            resetProgressCount()
            ObserveQuestion()
            print("LoadQuestion called !!! -1")
            if(currentQuestionPos  < quesData.count && currentQuestionPos + 1 <= Apps.TOTAL_PLAY_QS ) {
                print("LoadQuestion called !!! -2")
                if(quesData[currentQuestionPos].image == ""){
                    print("LoadQuestion called !!! -3(1)")
                    mainQuestionLbl.text = quesData[currentQuestionPos].question
                    mainQuestionLbl.centerVertically()
                    //hide some components
                    imageQuestionLbl.isHidden = true
                    questionImageView.isHidden = true
                    mainQuestionLbl.isHidden = false
                }else{
                    print("LoadQuestion called !!! -3(2)")
                    imageQuestionLbl.text = quesData[currentQuestionPos].question
                    imageQuestionLbl.centerVertically()
                    questionImageView.loadImageUsingCache(withUrl: quesData[currentQuestionPos].image)
                    questionImageView.layer.cornerRadius = 11
                    questionImageView.clipsToBounds = true
                    
                    questionImageView.isHidden = false
                    imageQuestionLbl.isHidden = false
                    mainQuestionLbl.isHidden = true
                }
            }
            print("LoadQuestion called !!! -4")
            if(quesData[currentQuestionPos].optionE == ""){
                   Apps.opt_E = false
               }else{
                   Apps.opt_E = true
               }
               if Apps.opt_E == true {
                   clearColor(views: btnA,btnB,btnC,btnD,btnE)
                   btnE.isHidden = false
                   buttons = [btnA,btnB,btnC,btnD,btnE]
                   DesignOptionButton(buttons: btnA,btnB,btnC,btnD,btnE)
                   self.SetViewWithoutShadow(views: btnA,btnB, btnC, btnD, btnE)
                   // enabled options button
                   MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD,btnE)
               }else{
                clearColor(views: btnA,btnB,btnC,btnD)
                btnE.isHidden = true
                buttons = [btnA,btnB,btnC,btnD]
                DesignOptionButton(buttons: btnA,btnB,btnC,btnD)
                self.SetViewWithoutShadow(views: btnA,btnB, btnC, btnD)
                // enabled options button
                MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD)
               }
            self.SetButtonOption(options: quesData[currentQuestionPos].optionA,quesData[currentQuestionPos].optionB,quesData[currentQuestionPos].optionC,quesData[currentQuestionPos].optionD,quesData[currentQuestionPos].optionE,quesData[currentQuestionPos].correctAns)
            mainQuesCount.roundCorners(corners: [.topLeft,.topRight,.bottomLeft,.bottomRight], radius: 5)
            mainQuesCount.text = "\(currentQuestionPos + 1) / \(Apps.TOTAL_PLAY_QS)" //"\(currentQuestionPos + 1)"
        } else {
            print("LoadQuestion called !!! -5")
            // If there are no more questions show the results
            if oppAnswer{
                ShowResultAlert()
            }
          /*  self.scroll.setContentOffset(.zero, animated: true)
            self.secondChildView.isHidden = true
            self.btnA.isHidden = true
            self.btnB.isHidden = true
            self.btnC.isHidden = true
            self.btnD.isHidden = true
            self.btnE.isHidden = true
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: self.scroll.frame.width, height: self.scroll.frame.height))
            noDataLabel.text          = Apps.BTL_WAIT_MSG
            noDataLabel.textColor     = Apps.BASIC_COLOR
            noDataLabel.textAlignment = .center
            noDataLabel.numberOfLines = 0
            noDataLabel.font = noDataLabel.font?.withSize(deviceStoryBoard == "Ipad" ? 25 : 15)
            noDataLabel.lineBreakMode = .byWordWrapping
            self.scroll.addSubview(noDataLabel) */
        }
    }
    
  /*  var btnY = 0
    func SetButtonHeight(buttons:UIButton...){
        self.scroll.setContentOffset(.zero, animated: true)
        self.scroll.contentSize = CGSize(width: self.scroll.frame.width, height: self.view.frame.height)
        btnY = Int(self.secondChildView.frame.height + self.secondChildView.frame.origin.y + 20)
        for button in buttons{
            let btnWidth = self.btnD.frame.width
            let btnX = button.frame.origin.x
            let size = button.intrinsicContentSize
            let newHeight = size.height > 50 ? size.height : 50
            let newFrame = CGRect(x: Int(btnX), y: btnY, width: Int(btnWidth), height: Int(newHeight))
            btnY += Int(newHeight) + 10
            button.frame = newFrame
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.layoutIfNeeded()
            button.layoutIfNeeded()
        }
        let with = self.scroll.frame.width
        self.scroll.contentSize = CGSize(width: Int(with), height: Int(btnY + 10))
    } */
    func ObserveQuestion(){
        let refQ = ref.child(roomCode).child("joinUser")
        if(refQ != nil){
            refQ.child(battleUser.UID).child("Questions").child("\(self.currentQuestionPos)").observe(.value, with: {(snapshot) in
                let data = snapshot.value as? [String:Any]
                if data != nil{
                    print("COMES 1 - \(data)")
                    self.oppSelectedAns = data!["userSelect"]! as! String
                    self.oppSelectedAns = self.oppSelectedAns.trimmingCharacters(in: .whitespacesAndNewlines)
                    if self.myAnswer{
                       // print("COMES 2")
                        if self.oppSelectedAns.isEmpty || self.oppSelectedAns == ""{
                            self.timer!.invalidate()
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                // load next question after 1 second
                                if self.timer!.isValid{
                                    self.timer?.invalidate()
                                }
                                print("No Answer from Opponent user")
//                                self.currentQuestionPos += 1 //increment for next question
//                                self.LoadQuestion()
                            })
                        }//else{
                            for button in self.buttons{
                                let str = button.title(for: .normal)!.trimmingCharacters(in: .whitespacesAndNewlines)
                                print("COMES 3",str,"ANS",self.oppSelectedAns)
                                if str == self.oppSelectedAns{
                                    print("COMES 4")
                                    self.ShowOpponentAns(btn: button, str: "\(self.battleUser.name)")
//                                    self.currentQuestionPos += 1 //increment for next question
//                                    self.LoadQuestion()
                                }
                            }
                      //  }
                    }else{
                       // print("COMES 5")
                        self.oppAnswer = true
                    }
                    if self.currentQuestionPos + 1 >= Apps.TOTAL_PLAY_QS{
                        if self.myAnswer{
                            self.ShowResultAlert()
                        }
                    }
                }
            })
        }
    }
    func ShowResultAlert(){
//        NotificationCenter.default.post(name: Notification.Name("StopMusic"), object: nil)
        if timer != nil && timer!.isValid{
            timer!.invalidate()
        }
       showResultView()
    }
    func showResultView(){ //show BattleResultAlert
       // let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "BattleRoomResult") as! BattleRoomResult
//        viewCont.joinedUsers = self.joinedUsers
//        viewCont.roomType = self.roomType
//        viewCont.roomInfo = self.roomInfo
//        viewCont.roomCode = self.roomCode
//        self.navigationController?.pushViewController(viewCont, animated: true)
//        NotificationCenter.default.post(name: Notification.Name("StopMusic"), object: nil)
        if timer != nil && timer!.isValid{
            timer!.invalidate()
        }
        let alert = Apps.storyBoard.instantiateViewController(withIdentifier: "BattleResultAlert") as! BattleResultAlert
        alert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        alert.parentController = self
        alert.isOneToOne = true
        alert.roomCode = self.roomCode
        //show defeat / trophy image for current user + You Win /You Lost
        //print("user details - \(user.name)")
        //print("Alert user details - \(String(describing: alert.user1Name.text))")
        alert.user1 = user.name
        alert.user1Img = user.image
        alert.user2 = battleUser.name
        alert.user2Img = battleUser.image
        
        if rightCount < opponentRightCount{
//            alert.winnerImg = battleUser.image
//            alert.winnerName = battleUser.name
            alert.winnerCase = 2 //player2 is winner
        }else if opponentRightCount < rightCount{
//            alert.winnerImg = user.image
//            alert.winnerName = user.name
            alert.winnerCase = 1 //player1 is winner
        }else{
            //alert.winnerName = Apps.MATCH_DRAW
            alert.winnerCase = 0 //MATCH DRAW
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // right answer operation function
    func rightAnswer(btn:UIView){
        //make timer invalidate
        timer!.invalidate()
        //score count
        rightCount += 1
        let refQ = ref.child(roomCode).child("joinUser")
        refQ.child(user.UID).child("rightAns").setValue("\(rightCount)")
        self.userCount1.textChangeAnimation()
        self.userCount1.text = "\(String(format: "%02d", rightCount))"
        btn.backgroundColor = Apps.RIGHT_ANS_COLOR
        btn.tintColor = UIColor.white
        // sound
        self.PlaySound(player: &audioPlayer, file: "right")
        if self.oppAnswer{
            for button in self.buttons{
                if button.title(for: .normal) == self.oppSelectedAns{
                    self.ShowOpponentAns(btn: button, str: "\(self.battleUser.name)")
                }
            }
        }else{
            self.myAnswer = true
        }
        //self.SetRightWrongtoFIR()
       /* DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            DispatchQueue.main.async {
                self.currentQuestionPos += 1 //increment for next question
                self.LoadQuestion()
            }
        }); */
    }
    
    // wrong answer operation function
    func wrongAnswer(btn:UIView?){
        //make timer invalidate
        timer!.invalidate()
        for rbtn in self.buttons{
            if rbtn.tag == 1{
                rbtn.backgroundColor = Apps.RIGHT_ANS_COLOR
                rbtn.tintColor = UIColor.white
            }
        }
        //score count
        wrongCount += 1
        btn?.backgroundColor = Apps.WRONG_ANS_COLOR
        btn?.tintColor = UIColor.white
//        self.userCount2.textChangeAnimation()
//        self.userCount2.text = "\(String(opponentRightCount))"
        // sound
        self.PlaySound(player: &audioPlayer, file: "wrong")
        if self.oppAnswer{
            for button in self.buttons{
                if button.title(for: .normal) == self.oppSelectedAns{
                    self.ShowOpponentAns(btn: button, str: "\(self.battleUser.name)")
                }
            }
            }else{
                self.myAnswer = true
            }
        //self.SetRightWrongtoFIR()
      /*  DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            DispatchQueue.main.async {
                self.currentQuestionPos += 1 //increment for next question
                self.LoadQuestion()
            }
        }); */
    }
    
    //observe data in firebase and show updated data to user
   /* func SetRightWrongtoFIR(){
        let users = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        let refR = ref.child(roomCode).child("joinUser").child(users.UID)//Database.database().reference().child(self.roomType == "private" ? Apps.PRIVATE_ROOM_NAME : Apps.PUBLIC_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser").child(users.UID)
       
        var data = question.toDictionaryE
        data["userSelect"] = userAns
        //if refR != nil{
            refR.child("Questions").child("\(self.currentQuestionPos)").setValue(data) //.child(user.UID)
        //}
        
//        refR.child("rightAns").setValue("\(self.rightCount)")
//        refR.child("wrongAns").setValue("\(self.wrongCount)") //no need to add WrongAns for 2 players - as it's either win or Lose - only 2 options there.
    } */
    
    // add question data to firebase
    func AddQuestionToFIR(question:QuestionWithE, userAns:String){
       // if question != nil{
            var data = question.toDictionaryE
            data["userSelect"] = userAns
            //let currAns = userAns
            let refQ = ref.child(roomCode).child("joinUser")//.child(users.UID)
            if refQ != nil{
               refQ.child(user.UID).child("Questions").child("\(self.currentQuestionPos)").setValue(data)//.child("UserSelect")//(currAns)
            }
        //}
    }
    
    func ObserveData(){
        print("battle user/Opponent - \(self.battleUser.UID) ")
        let refQ = ref.child(roomCode).child("joinUser")
        refQ.child(self.battleUser.UID).observe(.value, with: {(snapshot) in
            if snapshot.hasChild("rightAns"){
                self.userCount2.textChangeAnimation()
                self.userCount2.text = "\(String(format: "%02d",Int(snapshot.childSnapshot(forPath: "rightAns").value as! String)!))"
                self.opponentRightCount = Int(snapshot.childSnapshot(forPath: "rightAns").value as! String)!
            }
//            DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
//                  DispatchQueue.main.async {
//                      self.currentQuestionPos += 1 //increment for next question
//                      self.LoadQuestion()
//                  }
//              });
            if snapshot.hasChild("leftBattle"){
                if  let boolCheck = snapshot.childSnapshot(forPath: "leftBattle").value as? Bool{
                    if boolCheck{
                        self.hasLeave = true
                        self.ShowResultAlert()
                    }
                }
            }
        })
    }
    
    
    // set button option's
    var buttons:[UIButton] = []
    func SetButtonOption(options:String...){
        clickedButton.removeAll()
        var temp : [String]
        if Apps.opt_E == true {
            temp = ["a","b","c","d","e"]
            self.buttons = [btnA,btnB,btnC,btnD,btnE]
        }else{
            temp = ["a","b","c","d"]
            self.buttons = [btnA,btnB,btnC,btnD]
        }
        var i = 0
        for button in buttons{
           // button.setImage(SetClickedOptionView(otpStr: temp[i]).createImage(), for: .normal)
            button.addSubview(SetClickedOptionView(otpStr: temp[i]))
            button.layer.masksToBounds = true
            i += 1
        }  
        let singleQues = quesData[currentQuestionPos]
        if singleQues.quesType == "2"{
            clearColor(views: btnA,btnB)
            MakeChoiceBtnDefault(btns: btnA,btnB)
            self.buttons = [btnA,btnB]
            btnC.isHidden = true
            btnD.isHidden = true
            btnE.isHidden = true
            temp = ["a","b"]
        }else{
            if Apps.opt_E == true {
            self.buttons = [btnA,btnB,btnC,btnD,btnE]
                clearColor(views: btnA,btnB,btnC,btnD,btnE)
                MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD,btnE)
                btnE.isHidden = false
            }else{
                self.buttons = [btnA,btnB,btnC,btnD]
                clearColor(views: btnA,btnB,btnC,btnD)
                MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD)
            }
            btnC.isHidden = false
            btnD.isHidden = false
            buttons.shuffle()
        }
        
        let ans = temp
        var rightAns = ""
        if ans.contains("\(options.last!.lowercased())") {
            rightAns = options[ans.firstIndex(of: options.last!.lowercased())!]
        }else{
            // self.ShowAlert(title: "Invalid Question", message: "This Question has wrong value.")
            rightAnswer(btn: btnA)
        }
        buttons.shuffle()
        var index = 0
        for button in buttons{
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.setTitle(options[index].trimmingCharacters(in: .whitespaces), for: .normal)
            if options[index] == rightAns{
                button.tag = 1
            }else{
                button.tag = 0
            }
            button.addTarget(self, action: #selector(ClickButton), for: .touchUpInside)
            button.addTarget(self, action: #selector(ButtonDown), for: .touchDown)
            index += 1
        }
        SetButtonHeight(buttons:btnA,btnB,btnC,btnD,btnE,view:secondChildView,scroll:scroll) //self.SetButtonHeight(buttons: btnA,btnB,btnC,btnD,btnE)
    }
    func clearColor(views:UIView...){
        for view in views{
            view.isHidden = false
            view.backgroundColor = UIColor.white.withAlphaComponent(0.8)//UIColor.white // Apps.BASIC_COLOR
//            view.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
        }
    }
    // option buttons click action
    @objc func ClickButton(button:UIButton){
        if clickedButton.first?.title(for: .normal) == button.title(for: .normal){
            buttons.forEach{$0.isUserInteractionEnabled = false}
            if button.tag == 1{
                rightAnswer(btn: button)
            }else{
                wrongAnswer(btn: button)
            }
            if currentQuestionPos < quesData.count {
                self.AddQuestionToFIR(question: self.quesData[currentQuestionPos],userAns: button.title(for: .normal)!)
            }
        }else{
            clickedButton.removeAll()
            buttons.forEach{$0.isUserInteractionEnabled = true}
        }
    }
    
    var clickedButton:[UIButton] = []
    @objc func ButtonDown(button:UIButton){
        clickedButton.append(button)
    }
    // set default to four/five choice button
    func MakeChoiceBtnDefault(btns:UIButton...){
        for btn in btns {
            btn.isEnabled = true
            btn.isHidden = false
            btn.frame = self.btnA.frame //btnE.frame
           // btn.backgroundColor = .clear
            btn.layer.backgroundColor =  UIColor.white.withAlphaComponent(0.8).cgColor //UIColor.white.cgColor//UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2).cgColor
            btn.subviews.forEach({
                if($0.tag == 11){
                    $0.removeFromSuperview()
                }
            })
        }
    }
    // add label and show opponent answer what he has selected
   func ShowOpponentAns(btn: UIButton, str: String){
        battleOpponentAnswer(btn: btn, str: str)
       // self.timer!.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // load next question after 1 second
            if self.timer!.isValid{
                self.timer?.invalidate()
            }
            self.currentQuestionPos += 1 //increment for next question
            self.LoadQuestion()
        })
    }
}

//class ResizableButton: UIButton {
//    override var intrinsicContentSize: CGSize {
//       let labelSize = titleLabel?.sizeThatFits(CGSize(width: frame.width, height: .greatestFiniteMagnitude)) ?? .zero
//       let desiredButtonSize = CGSize(width: labelSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: labelSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom + 25)
//
//       return desiredButtonSize
//    }
//}
