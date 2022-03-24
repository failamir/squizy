import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FirebaseAuth
import AuthenticationServices
import CryptoKit

class UserSignUpViewController: UIViewController, ASAuthorizationControllerPresentationContextProviding, UITextFieldDelegate  {

        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            return self.view.window!
        }
                    
        @IBOutlet weak var sName: UITextField!
        @IBOutlet weak var sEmail:UITextField!
        @IBOutlet weak var sPassword: UITextField!
        @IBOutlet weak var sReferralCode: UITextField!
        @IBOutlet weak var sBtnSignUp: UIButton!
             
        var ref: DatabaseReference!
        
        var email = ""
        var isInitial = true
        var Loader: UIAlertController = UIAlertController()
        
        // Unhashed nonce.
        fileprivate var currentNonce: String?
            
        override func viewDidLoad() {
            super.viewDidLoad()
            sName.attributedPlaceholder = NSAttributedString(string:Apps.P_NAME, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            sEmail.attributedPlaceholder = NSAttributedString(string:Apps.P_EMAIL, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            sPassword.attributedPlaceholder = NSAttributedString(string:Apps.P_PASSWORD, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            sReferralCode.attributedPlaceholder = NSAttributedString(string:Apps.P_REFERCODE, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            
            ref = Database.database().reference()
            self.hideKeyboardWhenTappedAround() //hide keyboard on tap anywhere in screen
        }
        override func viewDidLayoutSubviews() {
            
            sName.leftViewMode = UITextField.ViewMode.always
            sName.setLeftIcon(UIImage(named: "name")!)
            sName.tintColor = UIColor.black
            sName.layer.cornerRadius = 11
            sName.clipsToBounds = true
            sName.borderStyle = .none
            
            sEmail.leftViewMode = UITextField.ViewMode.always
            sEmail.setLeftIcon(UIImage(named: "mail")!)
            sEmail.tintColor = UIColor.black
            sEmail.layer.cornerRadius = 11
            sEmail.clipsToBounds = true
            sEmail.borderStyle = .none
            
            sPassword.leftViewMode = UITextField.ViewMode.always
            sPassword.setLeftIcon(UIImage(named: "security")!)
            sPassword.tintColor = UIColor.black
            sPassword.layer.cornerRadius = 11
            sPassword.clipsToBounds = true
            sPassword.borderStyle = .none
            
            sReferralCode.leftViewMode = UITextField.ViewMode.always
            sReferralCode.setLeftIcon(UIImage(named: "refer-SignUp")!)
            sReferralCode.tintColor = UIColor.black
            sReferralCode.layer.cornerRadius = 11
            sReferralCode.clipsToBounds = true
            sReferralCode.borderStyle = .none
            
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            textField.resignFirstResponder()
        }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
                nextField.becomeFirstResponder()
                return true
            }else {
               textField.resignFirstResponder()
               self.view.endEditing(true)
                return false
           }
        }
                
        @IBAction func LoginBtn(_ sender: UIButton) {
            //show signup View
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "LoginView")
            signUpToLoginTransition()
            self.navigationController?.pushViewController(viewCont, animated: false)
        }
        
        @IBAction func SignupUser(_ sender: Any) {
            //create referernce to the data user enter
            let nameTxt = sName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let emailTxt =  sEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let passwordTxt = sPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let refCodeTxt = sReferralCode.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            //chk for name As its not optional
            if  self.sName.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                self.sName.becomeFirstResponder()
                let alert = UIAlertController(title: "", message: Apps.MSG_NM, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true)
            }else{
                //create a user
                Auth.auth().createUser(withEmail: emailTxt, password: passwordTxt) { (result, err) in
                    if err != nil {
                        let error_descr = err?.localizedDescription
                        if error_descr != nil {
                            print(" error -- creating user \(error_descr!)")
                            let alert = UIAlertController(title: "", message: error_descr!, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true)
                        }
                        else{
                            print("Error Creating User")
                            let alert = UIAlertController(title: "", message: Apps.MSG_ERR, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true)
                        }
                        print("Error Creating User")
                        let alert = UIAlertController(title: "", message: Apps.MSG_ERR, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true)
                    } else {
                        //set frnd code
                        UserDefaults.standard.set(refCodeTxt, forKey: "fr_code")
                        //store data to realtime database of firebase as user created successfully
                        let key = self.ref.childByAutoId().key
                        let user = [
                            "uid": key,
                            "name" : nameTxt ,
                            "ref_code" : refCodeTxt
                        ]
                        self.ref.child("users").child(key!).setValue(user){(error:Error?, ref:DatabaseReference) in
                            if let error = error {
                                let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                                self.present(alert, animated: true)
                                print("error - \(error.localizedDescription)")
                            } else {
                                guard let user = Auth.auth().currentUser else {
                                    return signin(auth: Auth.auth())
                                }
                                user.reload { (error) in
                                    user.sendEmailVerification { (error) in
                                        guard let error = error else {
                                            print("user verification email sent")
                                            let alert = UIAlertController(title: "", message: Apps.VERIFY_MSG1, preferredStyle: UIAlertController.Style.alert)
                                            alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: { action in
                                                self.dismissCurrView()
                                                let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "LoginView")
                                                self.signUpToLoginTransition()
                                                self.navigationController?.pushViewController(viewCont, animated: false)
                                            }))
                                            return self.present(alert, animated: true, completion: nil)
                                        }
                                        let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                                        self.present(alert, animated: true)
                                        print("error - \(error.localizedDescription)")
                                    }
                                }
                            }//else of reference error
                        } //end of reference
                    } //else inside else
                } //create user
            } //else
       
            func signin (auth: Auth){
                Auth.auth().signIn(withEmail: emailTxt, password: passwordTxt) { (result, error) in
                    guard error == nil else {
                        return print(error!)
                    }
                    guard let user = result?.user else{
                        fatalError("User Not Found, Something went wrong")
                    }
                    print("Signed in user: \(user.email ?? emailTxt)")
                }
            }
        }//signup user
        
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
        @IBAction func guestBtn(_ sender: Any) {
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ViewController")
            SkipBtnTransition()
            self.navigationController?.pushViewController(viewCont, animated: false) //true
        }
        func checkIfEmailVerified(){
            if Auth.auth().currentUser != nil {
                print(Auth.auth().currentUser!)
                Auth.auth().currentUser?.reload (completion: {(error) in
                    if error == nil{
                        //signIn user & check whether it is verified or not ? if not verified then dnt allow to login by showing an alert
                        if Auth.auth().currentUser?.isEmailVerified == true {
                            self.signInVerification()
                        }else{
                            let alert = UIAlertController(title: Apps.RESET_MSG, message: Apps.VERIFY_MSG, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }else{
                        let alert = UIAlertController(title: Apps.ERROR, message: error!.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true)
                        print(error?.localizedDescription ?? "error")
                    }
                })
            }else{
                signInVerification()
            }
        }
        func signInVerification(){
            //create referernce to the data user enter
            let username = self.sEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = self.sPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().signIn(withEmail: username, password: password) { (result,error) in
                if error != nil {
                    let alert = UIAlertController(title: Apps.ERROR, message: error!.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true)
                    print(error!.localizedDescription)
                }else{
                   
                    //set DisplayName by splitting from given email address
                    let displayname = result?.user.email!.components(separatedBy: "@")
                    let nm = displayname![0]
                    //print("\(nm)")
                    var fcode = ""
                    var rcode = nm //ref code is same as initial username
                    Apps.REFER_CODE = rcode
                    print("curr user -- \((result?.user.uid)!)")
                    var mobile = "0"
                    if result?.user.phoneNumber != nil {
                        mobile = (result?.user.phoneNumber)!
                    }
                    if result?.user.displayName != nil {
                        rcode = self.referCodeGenerator((result?.user.displayName)!)
                    }else{
                        rcode = self.referCodeGenerator(nm)
                    }
                   
                    Apps.REFER_CODE = rcode
                    
                    if (UserDefaults.standard.value(forKey: "fr_code") != nil){
                        fcode = UserDefaults.standard.string(forKey: "fr_code")!
                        print(fcode)
                    }else{
                        fcode = ""
                    }
                    let sUser = User.init(UID: "\((result?.user.uid)!)",userID: "", name: "\(result?.user.displayName ?? "\(nm)")", email: "\((result?.user.email)!)",phone: "\(result?.user.phoneNumber ?? "")", address: " ", userType: "email", image: "", status: "1",ref_code: "\(rcode)")
                    
                    UserDefaults.standard.set(try? PropertyListEncoder().encode(sUser), forKey: "user")
                    print("user data-- \(sUser)")
                    
                    // send data to server after successfully loged in
                    let apiURL = "firebase_id=\(result?.user.uid ?? "0")&name=\(result?.user.displayName ?? "\(nm)")&email=\((result?.user.email)!)&profile=&mobile=\(mobile)&type=email&fcm_id=\(Apps.FCM_ID)&refer_code=\(rcode)&friends_code=\(fcode)&ip_address=1.0.0&status=1"
                    UserDefaults.standard.set(true, forKey: "isLogedin") //Bool
                    self.getAPIData(apiName: "user_signup", apiURL: apiURL,completion: self.ProcessLogin)
                }
            }
        }
            
        //load data here
        func ProcessLogin(jsonObj:NSDictionary){
            print("LOG",jsonObj)
            let msg = jsonObj.value(forKey: "message") as! String
            let status = jsonObj.value(forKey: "error") as! String
            if (status == "true") {
                DispatchQueue.main.async {
                    self.Loader.dismiss(animated: true, completion: {
                        self.ShowAlert(title: Apps.OK, message:"\(msg)" )
                    })
                }
                return
            }else{
                //get data for category
                if let data = jsonObj.value(forKey: "data") as? [String:Any] {
                    print("Data -- \(data)")
                    var userD:User = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
                    userD.name = "\((data["name"])!)"
                    userD.userID = "\((data["user_id"])!)"
                    userD.phone = "\((data["mobile"])!)"
                    userD.image = "\((data["profile"])!)"
                    userD.ref_code = "\((data["refer_code"])!)"
                    userD.status = "\((data["status"])!)"
                    UserDefaults.standard.set(try? PropertyListEncoder().encode(userD), forKey: "user")
                }
            }
            //close loader here
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                DispatchQueue.main.async {
                    self.DismissLoader(loader: self.Loader)
                    // Present the main view
                    let initialViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "ViewController")
                    let navigationcontroller = UINavigationController(rootViewController: initialViewController)
                    navigationcontroller.setNavigationBarHidden(true, animated: false)
                    navigationcontroller.isNavigationBarHidden = true
                    UIApplication.shared.windows.first!.rootViewController = navigationcontroller
                }
            });
        }
    }
