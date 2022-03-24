import UIKit
import Firebase
import FirebaseAuth

class GroupBattleTypeSelection: UIViewController {
        
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createRoomBtn: GradientButton!
    @IBOutlet weak var joinRoomBtn: GradientButton!
    var selection = Apps.GRP_BTL
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //if group battle then GROUP_BTL else ONE_TO_ONE_BTL
        if selection == Apps.GRP_BTL{
            titleLabel.text = Apps.GROUP_BTL
        }else{
            titleLabel.text = Apps.ONE_TO_ONE_BTL
        }
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    override func viewDidLayoutSubviews() {
        mainView.layer.cornerRadius = 15
        joinRoomBtn.alpha = 1
        createRoomBtn.alpha = 1
        
        
        //change button colors for different battle type selection
        if selection == Apps.ONE_TO_ONE_BTL { //swap colors for OneToOne and Group battle.
            createRoomBtn.startColor = UIColor(named: Apps.ORANGE1)!
            createRoomBtn.endColor = UIColor(named: Apps.ORANGE2)!
            
            joinRoomBtn.startColor = UIColor(named: Apps.GREEN1)!
            joinRoomBtn.endColor = UIColor(named: Apps.GREEN2)!
        }
    }
         
    @IBAction func closeView(_ sender: Any) {
       //go to rootViewController
        addPopTransition()
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func createRoom(_ sender: Any) {
        //show battle group View if category selection is not enabled / and if enabled - then open categoryView.
        if selection == Apps.GRP_BTL {
            if UserDefaults.standard.bool(forKey: "isLogedin"){
                if Apps.GROUP_BATTLE_WITH_CATEGORY == "1"{
                print("battle with category")
                    let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "categoryview") as! CategoryViewController
                    //pass value to identify to jump to battle and not play quiz view.
                    viewCont.isGroupCategoryBattle = true
                    viewCont.selection = self.selection
                    self.addTransition()
                    self.navigationController?.pushViewController(viewCont, animated: false)
                }else{
                print("battle without category")
                     let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "GroupBattleView") as! GroupBattleView
                     viewCont.isUserJoininig = false
                     viewCont.selection = self.selection
                    self.addTransition()
                    self.navigationController?.pushViewController(viewCont, animated: false)
                }
            }else{
            self.navigationController?.popToRootViewController(animated: true)
            }
        }else{ //one to one battle
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "OneToOneBattleView") as! OneToOneBattleView
            viewCont.isUserJoininig = false
            viewCont.selection = self.selection
            self.addTransition()
            self.navigationController?.pushViewController(viewCont, animated: false)
        }
    }
    
    @IBAction func JoinRoom(_ sender: Any) {
        //enter room code and join / play group battle
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "EnterInGroupBattleAlert") as! EnterInGroupBattleAlert
            viewCont.selection = self.selection
            self.addTransition()
            self.navigationController?.pushViewController(viewCont, animated: false)
    }
} 
