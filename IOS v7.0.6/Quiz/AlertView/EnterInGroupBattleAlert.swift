import UIKit
import FirebaseDatabase

class EnterInGroupBattleAlert: UIViewController, UITextFieldDelegate  {
    
    @IBOutlet weak var joinRoomBtn: UIButton!
    @IBOutlet weak var gameCodeTxt: UITextField!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var selection = Apps.GRP_BTL
    var ref: DatabaseReference!
    var tblName = "MultiplayerRoom"
    var roomList:[RoomDetails] = []
    var availRooms = ["00000","11111"]
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        gameCodeTxt.attributedPlaceholder = NSAttributedString(string:Apps.P_GAMECODE, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        self.hideKeyboardWhenTappedAround()
        
        tblName = (selection == Apps.GRP_BTL) ? "MultiplayerRoom" : "OneToOneRoom"
        
        ref = Database.database().reference().child(tblName)
     }
    override func viewDidLayoutSubviews() {
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 600)
        joinRoomBtn.layer.cornerRadius = joinRoomBtn.frame.height / 3
        gameCodeTxt.layer.cornerRadius = gameCodeTxt.frame.height / 3
        gameCodeTxt.clipsToBounds = true
        gameCodeTxt.backgroundColor = UIColor.cyan.withAlphaComponent(0.6)
        bgView.layer.cornerRadius = 25
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0,y: textField.center.y-40), animated: true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
    }
    func checkForAvailability(){
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
             if let data = snapshot.value as? [String:Any]{
                print(data)
                self.roomList.removeAll()
                self.availRooms.removeAll()
                for val in data{
                    self.availRooms.append(val.key)
                }
                  if self.availRooms.contains(self.gameCodeTxt.text!){
                    print("game code found")
                    for val in data{
                        if self.gameCodeTxt.text == val.key {
                            print(val.key)
                            if let room = val.value as? [String:Any]{
                                if ("\(room["isRoomActive"] ?? "true")".bool ?? true){
                                    if !("\(room["isStarted"] ?? "true")".bool ?? true){
                                            print("true - enter in room - OneToOne")
                                            self.gotoGroupBattleView()
                                            //break myCondition
                                            return
                                    }else{
                                        DispatchQueue.main.async {
                                            self.ShowAlert(title: Apps.GAME_CLOSED, message: "")
                                            self.CloseAlert(self)
                                            }
                                        }
                                }else{
                                print("Is room active - false")
                                DispatchQueue.main.async {
                                    self.ShowAlert(title: Apps.GAME_CLOSED, message: "")
                                    self.CloseAlert(self) 
                                    }
                                }
                          }
                        }else{
                          //  print("entered roomcode match not found")
                        }
                    }
                }else{
                    print("gameCode not found")
                    self.ShowAlert(title: Apps.GAMECODE_INVALID, message: "")
                } //if of gamecodeText
            }
        })
    }
    func gotoGroupBattleView(){
        //go to Group battle view & add yourself with group of people present there
        let id = (selection == Apps.GRP_BTL) ? "GroupBattleView" : "OneToOneBattleView"
        if id == "GroupBattleView" {
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: id) as! GroupBattleView
            viewCont.isUserJoininig = true
            viewCont.gameRoomCode = self.gameCodeTxt.text ?? "00000"
            self.addTransition()
            self.navigationController?.pushViewController(viewCont, animated: false)
        }else{
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: id) as! OneToOneBattleView
            viewCont.isUserJoininig = true
            viewCont.gameRoomCode = self.gameCodeTxt.text ?? "00000"
            self.addTransition()
            self.navigationController?.pushViewController(viewCont, animated: false)
        }        
    }
    @IBAction func CloseAlert(_ sender: Any){
        addPopTransition()
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func GoToRoom(_ sender: Any) {               
        if gameCodeTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
             gameCodeTxt.placeholder = Apps.GAMEROOM_ENTERCODE
        }else{
            checkForAvailability()
        }
    } //goto room button
}
