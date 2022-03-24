import UIKit
import FirebaseDatabase

class BattleResultAlert: UIViewController {
    
    @IBOutlet weak var user1Image: UIImageView!
    @IBOutlet weak var user1Name: UILabel!
    @IBOutlet weak var user1Result: UILabel!
    @IBOutlet weak var user2Image: UIImageView!
    @IBOutlet weak var user2Name: UILabel!
    @IBOutlet weak var user2Result: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var usersView: UIView!
    @IBOutlet weak var titleTxt: UILabel!
    @IBOutlet weak var userResultTxt: UILabel!
    @IBOutlet weak var resultImage: UIImageView!
    
    @IBOutlet weak var reBattle: UIButton!
    @IBOutlet weak var shareScore: UIButton!
    @IBOutlet weak var exit: UIButton!
        
    var user1 = ""
    var user1Img = ""
    var user2 = ""
    var user2Img = ""
    var winnerCase = 0
    var isOneToOne = false
    var roomCode = "00000"
    var parentController:UIViewController?
    var dUser:User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.layer.cornerRadius = 15
        mainView.backgroundColor = UIColor.white
        
        user1Image.layer.borderWidth = 2
        user1Image.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
        user1Image.layer.cornerRadius = user1Image.bounds.width / 2
        user1Image.clipsToBounds = true
        user1Name.layer.cornerRadius = user1Name.bounds.height / 3
        user1Name.layer.masksToBounds = true
        
        user2Image.layer.borderWidth = 2
        user2Image.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
        user2Image.layer.cornerRadius = user2Image.bounds.width / 2
        user2Image.clipsToBounds = true
        user2Name.layer.masksToBounds = true
        user2Name.layer.cornerRadius = user2Name.bounds.height / 3
        
        dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey: "user") as? Data)!)
        print(dUser!)
        
        user1Name.text = user1
        user2Name.text = user2
        user1Image.loadImageUsingCache(withUrl: user1Img)
        if user2Img != "robot" {
            user2Image.loadImageUsingCache(withUrl: user2Img)
        }else{            
            user2Image.image = UIImage(named: "robot")
        }
        
        if winnerCase == 1 {  //player1 is winner
            titleTxt.text = Apps.CONGRATS
            userResultTxt.text = Apps.VICTORY
            resultImage.image = UIImage(named: "trophy")
            user1Result.text = Apps.WINNER
            user2Result.text = Apps.LOSER
        }else if winnerCase == 2{ //player2 is winner
            titleTxt.text = Apps.LOSE_BATTLE
            userResultTxt.text = Apps.DEFEAT
            resultImage.image = UIImage(named: "defeat")
            user2Result.text = Apps.WINNER
            user1Result.text = Apps.LOSER
        }else{ //match Draw
               //no image - Match Draw !! Game is over ! Play Again with  OKAY/EXIT button only & hide users view + reBattle and ScoreShare button
            titleTxt.text = Apps.APP_NAME
            userResultTxt.frame = CGRect(x:  userResultTxt.frame.origin.x, y:  userResultTxt.frame.origin.y + 20, width:  userResultTxt.frame.width, height:  userResultTxt.frame.height + 50) //increase height to add one more line there
            userResultTxt.text = Apps.MATCH_DRAW + "\n" + Apps.GAME_OVER
            resultImage.alpha = 0
            reBattle.alpha = 0
            shareScore.alpha = 0
            //exit button height increase
            exit.frame = CGRect(x: exit.frame.origin.x , y: exit.frame.origin.y - 100 , width: exit.frame.width, height: exit.frame.height + 60) //exit.frame.height + 250
            usersView.alpha = 0
            mainView.frame = CGRect(x:  mainView.frame.origin.x , y:  mainView.frame.origin.y + 150, width:  mainView.frame.width, height:  mainView.frame.height - 250)
        }
        
    }
    
    @IBAction func RebattleBtn(_ sender: Any) {
        if isOneToOne == false { //for robot & random battle play
            print("resultViewAlert of robot/random battle")
            NotificationCenter.default.post(name: Notification.Name("CloseRobotPlay"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("CompleteBattle"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("CheckBattle"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }else{ //for OneToOne battle play
            print("resultViewAlert of OneToOneBattle")
            Complete1TO1Battle()
            NotificationCenter.default.post(name: Notification.Name("CloseBattlePlay"), object: nil)
            self.dismiss(animated: true, completion: nil)
             
        }
    }
    
    @IBAction func shareScoreBtn(_ sender: Any) {
        let str  = Apps.APP_NAME
        var shareUrl = ""
        if user1Name.text == dUser?.name { //current user is user1
            if user1Result.text == Apps.WINNER {
                shareUrl = "\(Apps.SHARE_BATTLE_WON) \(user2Name.text ?? "Player 2")"
            }else{
                shareUrl = "\(Apps.SHARE_BATTLE_LOST) \(user2Name.text ?? "Player 2")"
            }
        }else{ //current user is user2
            if user1Result.text == Apps.WINNER {
                shareUrl = "\(Apps.SHARE_BATTLE_LOST) \(user1Name.text ?? "Player 1")"
            }else{
                shareUrl = "\(Apps.SHARE_BATTLE_WON) \(user1Name.text ?? "Player 1")"
            }
        }
        let textToShare = str + "\n" + shareUrl
//        //take screenshot
        
        let vc = UIActivityViewController(activityItems: [textToShare], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = sender as? UIView
        present(vc, animated: true)
    }
    func Complete1TO1Battle(){
        let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
               
        let roomVal = Database.database().reference().child("OneToOneRoom").child(roomCode)
        roomVal.observeSingleEvent(of: .value, with: { (snapshot) in
             if let data = snapshot.value as? [String:Any] {
                print(data)
                let authID = data["authId"] as! String
                print(authID)
                if authID == user.UID {
                    roomVal.removeValue()
                }
             }
        })
    }
    @IBAction func BattleExitBtn(_ sender: Any) {
        if isOneToOne == false { //for robot & random battle play
            NotificationCenter.default.post(name: Notification.Name("CloseRobotPlay"), object: nil)// this will close if user play with robot to close robotplayviewcontroller
            NotificationCenter.default.post(name: Notification.Name("CloseBattleViewController"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }else{ //for OneToOne battle play
            Complete1TO1Battle()
            NotificationCenter.default.post(name: Notification.Name("goToRootViewController"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
