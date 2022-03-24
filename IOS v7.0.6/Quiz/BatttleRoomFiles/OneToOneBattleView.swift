import UIKit
import FirebaseDatabase
import AVFoundation

class OneToOneBattleView: UIViewController {
    
    @IBOutlet weak var Create1To1View: UIView!
    @IBOutlet weak var joinView: UIView!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var gameCode: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var playersView:UIView!
    
    @IBOutlet weak var player1Img: UIImageView!
    @IBOutlet weak var player1Name: UILabel!
    @IBOutlet weak var player2Img: UIImageView!
    @IBOutlet weak var player2Name: UILabel!
    @IBOutlet var vsImg: UIImageView!
    
    @IBOutlet weak var joinPlayer1Img: UIImageView!
    @IBOutlet weak var joinPlayer1Name: UILabel!
    @IBOutlet weak var joinPlayer2Img: UIImageView!
    @IBOutlet weak var joinPlayer2Name: UILabel!
    @IBOutlet var joinVsImg: UIImageView!
    
    @IBOutlet weak var waitForPlayers: UILabel!
    
    @IBOutlet weak var shareBtn: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    var selection = Apps.ONE_TO_ONE_BTL
    var tblName = "OneToOneRoom"
    
    var ref: DatabaseReference!
    var db: DatabaseReference!
    var joinUser:[JoinedUser] = []
    
    var roomInfo:RoomDetails? 
    var selfUser = true
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var isRoomStarted = false
    
    var count:CGFloat = 0.0
    var timer: Timer!
    var seconds = 03
    let countdownTimeStart = Date()
    var countdownTimeRemaining = 0
    
    var isUserJoininig = false
    var gameRoomCode = ""
    var usersCount = 0
    var catID = 0
    var langID = 0
    var sysConfig:SystemConfiguration!
    let currUser =  try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Database.database().reference().child(tblName)
        titleLabel.text = Apps.ONE_TO_ONE_BTL
        
        waitForPlayers.layer.cornerRadius = 10
        waitForPlayers.clipsToBounds = true
        waitForPlayers.text = Apps.WAIT_IN_ONE_TO_ONE
        
        shareBtn.layer.cornerRadius = 10
        shareBtn.clipsToBounds = true
        
        if isUserJoininig == true{
            joinView.alpha = 1
            Create1To1View.alpha = 0
            gameCode.text = gameRoomCode
            self.ref = db.child(self.gameRoomCode)
            ref.child("isJoined").setValue("true")
        }else{
            joinView.alpha = 0
            Create1To1View.alpha = 1
            gameRoomCode = randomNumberForBattle()
            gameCode.text = gameRoomCode
            self.ref = db
            //create room api
            var apiURL = ""
                apiURL = "user_id=\(currUser.userID)&room_id=\(gameRoomCode)&room_type=private&category=&no_of_que=\(Apps.TOTAL_BATTLE_QS)"
            if UserDefaults.standard.value(forKey: DEFAULT_USER_LANG) != nil{
               langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
               apiURL += "&language_id=\(langID)"
           }
            
            self.getAPIData(apiName: "create_room", apiURL: apiURL,completion: {jsonObj in
                print("JSON response - create room-",jsonObj)
                let status = "\(jsonObj.value(forKey: "error")!)".bool ?? true
                if (status) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.ShowAlert(title: Apps.ERROR, message: "\(jsonObj.value(forKey: "message")!)")
                        self.ref.removeAllObservers()
                        self.addPopTransition()
                        self.navigationController?.popViewController(animated: false) //go back if there's no questions / room not created
                    })
                    return
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.ShowAlertOnly(title: "\(jsonObj.value(forKey: "message")!)", message: "")
                    })
                }
            })
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
            timer.fire()
        }
        print(currUser.name)
              
        if isUserJoininig == false{
            
            player1Name.text = currUser.name
            player1Img.loadImageUsingCache(withUrl: currUser.image)
            
            let refAdd = ref.child(gameRoomCode)
            var setDetails:[String:String] = [:]
            setDetails["authId"] = currUser.UID
            setDetails["isRoomActive"] = "true"
            setDetails["isStarted"] = "false"
            setDetails["isJoined"] = "false"
            refAdd.setValue(setDetails, withCompletionBlock: {(error,snapshot) in
            })
            
        } else{
            joinPlayer1Name.text = currUser.name
            joinPlayer1Img.loadImageUsingCache(withUrl: currUser.image)
            self.ObserveRoomActive()
        }
        var userDetails:[String:String] = [:]
        userDetails["UID"] = currUser.UID
        userDetails["userID"] = currUser.userID
        userDetails["name"] = currUser.name
        userDetails["image"] = currUser.image
        userDetails["isJoined"] = "true"
        let refR = db.child(gameRoomCode).child("joinUser").child(currUser.UID)
        refR.setValue(userDetails, withCompletionBlock: {(error,snapshot) in
        })
        self.DesignViews(views: player1Img,player2Img,joinPlayer1Img,joinPlayer2Img)
                
        self.ObserveUser()
        let imgToAnimate = ((isUserJoininig == false) ? vsImg : joinVsImg)!
        imgAnimation(imgToAnimate)
        
        //set DataSource and delegate for both collectionView
    }
    // set Custom Design function
    func DesignViews(views:UIView...){
        for view in views{
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.white.cgColor
            //view.SetShadow()
            view.layer.cornerRadius = view.frame.height / 2
            view.clipsToBounds = true
        }
    }
    @IBAction func shareButton(_ sender: Any) {
        let str  = Apps.APP_NAME
        var shareUrl = ""
        let gameCode = self.gameCode.text ?? "00000"
        shareUrl = "\(Apps.MSG_GAMEROOM_SHARE) \(gameCode)"
       
        let textToShare = str + "\n" + shareUrl
       
        let vc = UIActivityViewController(activityItems: [textToShare], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = (sender as! UIView)
        present(vc, animated: true)
    }
    func imgAnimation(_ imgToAnim: UIImageView){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat,.autoreverse,UIView.AnimationOptions.curveEaseIn,], animations: {
            imgToAnim.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5) // Scale your image
         }) { (finished) in
             UIView.animate(withDuration: 1, animations: {
              imgToAnim.transform = CGAffineTransform.identity // undo in 1 seconds
           })
        }
    }
    @IBAction func PlayBtn(_ sender: Any) {
        if self.usersCount <= 1 {
            ShowAlert(title: Apps.GAMEROOM_WAIT_ALERT, message: "")
        }else{
            
            let refR = db.child(self.gameRoomCode)
            refR.child("isStarted").setValue("true")
            
            self.PlaySound(player: &self.audioPlayer, file: "click") // play sound
            self.Vibrate() // make device vibrate
            
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "OneToOneRoomBattlePlayView") as! OneToOneRoomBattlePlayView
            
            viewCont.roomCode = gameRoomCode
            viewCont.roomType = "private"
            viewCont.selection = self.selection
            //viewCont.roomInfo = self.roomInfo
            print("values of joinUser - \(self.joinUser.count)")
            if self.joinUser.count > 1 {
                print("join user data 1 -\(self.joinUser[0])")
                print("other join user data 2 -\(self.joinUser[1])")
                var opponentUser: BattleUser = BattleUser.init(UID: "\(self.joinUser[1].uID)", userID: "\(self.joinUser[1].userID)", name: "\(self.joinUser[1].userName)", image: "\(self.joinUser[1].userImage)", matchingID: "\(self.joinUser[0].userID)", cateId: "0", langId: "\(String(self.langID))")
                
                if self.joinUser.count > 1 && self.joinUser.contains(where: {$0.uID == self.currUser.UID}){
                    for i in 0...(self.joinUser.count - 1){
                        if self.joinUser[i].userID != self.currUser.userID {
                        opponentUser = BattleUser.init(UID: "\(self.joinUser[i].uID)", userID: "\(self.joinUser[i].userID)", name: "\(self.joinUser[i].userName)", image: "\(self.joinUser[i].userImage)", matchingID: "\(self.joinUser[0].userID)", cateId: "0", langId: "\(String(self.langID))")
                        }
                    }
                }
                viewCont.battleUser = opponentUser
                self.isRoomStarted = true
                 timer.invalidate()
                self.addTransition()
                self.navigationController?.pushViewController(viewCont, animated: false)
            }else{
                print("No user joined yet.")
            }
        }
    }
    
    @objc func incrementCount(){
        
        let timeRemaining = Apps.ONETOONE_BTL_WAIT_TIME - (0 + Int(floor(Date().timeIntervalSince(countdownTimeStart))))
        timerLabel.text = String(format: "%02d", (timeRemaining))

        if timeRemaining <= 0 {
            timer.invalidate()
            
            //show alert
            let alert = UIAlertController(title: "\(Apps.OOPS) \(Apps.NO_USER_JOINED)", message: Apps.NO_USER_JOINED_MSG, preferredStyle: .alert)
            selfUser = true
            alert.addAction(UIAlertAction(title: Apps.EXIT, style: UIAlertAction.Style.cancel, handler: backButton(_:)))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
        }
    }
    @IBAction func backButton(_ sender: Any) {
        
        if self.selfUser{
            var msg = ""
            if isUserJoininig == true { //user have joined room.
                msg = Apps.LEAVE_MSG
            }else{ //user have created room.
                msg = Apps.GAMEROOM_CLOSE_MSG
            }
            let alert = UIAlertController(title: msg, message: "", preferredStyle: .alert)
            let acceptAction = UIAlertAction(title: Apps.LEAVE, style: .default, handler: {_ in
                
                // make room deactive and leave viewcontroller
                    let ref = self.db.child(self.gameRoomCode).child("joinUser").child(self.currUser.UID)
                    //set isLeave to true
                    ref.child("isLeave").setValue("true")
                
                    let refR = self.db.child(self.gameRoomCode)
                    if self.isUserJoininig == false { //user have created room.
                        refR.child("isRoomActive").setValue("false")
                        refR.removeValue() //remove created room
                    }else{ //joined User
                        ref.removeValue() //removes current user
                    }                   
                
                    self.ref.removeAllObservers()
                    refR.removeAllObservers()
                    ref.removeAllObservers()
                    self.addPopTransition()
                    self.navigationController?.popViewController(animated: false)
            })
            let rejectAction = UIAlertAction(title: Apps.STAY_BACK, style: .cancel, handler: {_ in
              // do nothing here
            })
            
                alert.addAction(acceptAction)
                alert.addAction(rejectAction)
            
            self.present(alert, animated: true, completion: nil) //try to set in main thread to avoid app crash
            return
        }
    }
        
    func ObserveRoomActive(){
        let refR = db.child(self.gameRoomCode)
        refR.observe(.value, with: { (snapshot) in
            if self.isRoomStarted{
                refR.removeAllObservers()
                return
            }
            // print("SNAP",snapshot.value,snapshot.key)
            if let data = snapshot.value as? [String:Any]{
                if let isStarted = "\(data["isStarted"] ?? "false")".bool , let isRoomActive = "\(data["isRoomActive"] ?? "false")".bool {
                    if !isRoomActive{
                        self.ShowRoomLeaveAlert()
                        refR.removeAllObservers()
                        return
                    }
                    if self.joinUser.count > 1 {
                        if isStarted{
                            // room active here
                            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "OneToOneRoomBattlePlayView") as! OneToOneRoomBattlePlayView
                            viewCont.roomType = "private"
                            viewCont.roomInfo = self.roomInfo
                            viewCont.selection = self.selection
                            print("join user data -\(self.joinUser[1])")
                            
                            var opponentUser: BattleUser = BattleUser.init(UID: "\(self.joinUser[1].uID)", userID: "\(self.joinUser[1].userID)", name: "\(self.joinUser[1].userName)", image: "\(self.joinUser[1].userImage)", matchingID: "\(self.joinUser[0].userID)", cateId: "0", langId: "\(String(self.langID))")
                            
                            if self.joinUser.count > 1 && self.joinUser.contains(where: {$0.uID == self.currUser.UID}){
                                for i in 0...(self.joinUser.count - 1){
                                    if self.joinUser[i].userID != self.currUser.userID {
                                    opponentUser = BattleUser.init(UID: "\(self.joinUser[i].uID)", userID: "\(self.joinUser[i].userID)", name: "\(self.joinUser[i].userName)", image: "\(self.joinUser[i].userImage)", matchingID: "\(self.joinUser[0].userID)", cateId: "0", langId: "\(String(self.langID))")
                                    }
                                }
                            }
                            viewCont.battleUser = opponentUser
                            
                            self.isRoomStarted = true
                            viewCont.roomCode = self.gameRoomCode
                            self.addTransition()
                            self.navigationController?.pushViewController(viewCont, animated: false)
                        }
                    }
                }
            }
        })
    }
    
    func ObserveUser(){
        self.joinUser.removeAll()
        let refR = db.child(self.gameRoomCode).child("joinUser")
        refR.observe(.value, with: {(snapshot) in
            if let data = snapshot.value as? [String:Any]{
                print("DATA",data)
                self.joinUser.removeAll()
                for val in data{
                    if let user = val.value as? [String:Any]{
                        let isBlank = user["UID"]
                        if (isBlank == nil) {
                        }else{
                            print("ELSE case")
                            self.joinUser.append(JoinedUser.init(uID: "\(user["UID"]!)", userID: "\(user["userID"]!)", userName: "\(user["name"]!)", userImage: "\(user["image"]!)", isJoined: "\(user["isJoined"]!)".bool ?? false,rightAns: "\(user["rightAns"] ?? "0")",wrongAns: "\(user["wrongAns"] ?? "0")",isLeave:  "\(user["isLeave"] ?? "false")".bool ?? false))
                            self.usersCount = self.joinUser.count
                            if self.joinUser.count > 1 && self.joinUser.contains(where: {$0.uID == self.currUser.UID}){
                                for i in 0...(self.joinUser.count - 1){
                                    print("joinUsers -- \(self.joinUser[i].userName)")
                                    if self.joinUser[i].userID != self.currUser.userID {
                                        self.player2Name.text = self.joinUser[i].userName
                                        self.player2Img.loadImageUsingCache(withUrl: self.joinUser[i].userImage)
                                        self.joinPlayer2Name.text = self.joinUser[i].userName
                                        self.joinPlayer2Img.loadImageUsingCache(withUrl: self.joinUser[i].userImage)
                                        
                                        let refOpposite = self.db.child(self.gameRoomCode)
                                        refOpposite.observe(.value, with: {(snapshot) in
                                            //  print("Observe val",snapshot)
                                              if let data = snapshot.value as? [String:Any]{
                                                  print("OPP USER DATA",data)
                                                 // self.joinUser.removeAll()
                                                  for val in data{
                                                      if let room = val.value as? [String:Any]{
                                                          if ("\(room["isJoined"] ?? "true")".bool ?? true) {
                                                              self.startButton.alpha = 1
                                                              //shift PlayersView to top - same as Y of timer
                                                              self.playersView.frame = CGRect(x: self.playersView.frame.origin.x , y: self.timerLabel.frame.origin.y , width: self.playersView.bounds.size.width, height: self.playersView.bounds.size.height)
                                                              //hide timer
                                                              self.timerLabel.alpha = 0
                                                              if (self.timer != nil) {
                                                                  if (self.timer.isValid) {
                                                                      self.timer.invalidate()
                                                                  }
                                                              }
                                                          }else{
                                                              return
                                                          }
                                                      }
                                                  }
                                              }
                                        })
                                    }
                                }
                            }
                            print("count of JoinUsers - \(self.joinUser.count)")
                        }
                    }
                }
                self.usersCount = self.joinUser.count
            }
        })
    }
    
    func ShowRoomLeaveAlert(){
        DispatchQueue.main.async {
            self.ShowAlert(title: "\(Apps.GAMEROOM_EXIT_MSG)", message: "")
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
