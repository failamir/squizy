import Foundation
import UIKit
import Firebase

class UpdateProfileView: UIViewController{
    
    @IBOutlet var usrImg: UIImageView!
    @IBOutlet var btnUpdate: UIButton!
    @IBOutlet var logOutBtn: UIButton!
        
    @IBOutlet weak var statsBtn: UIButton!
    @IBOutlet weak var leaderboardBtn: UIButton!
    @IBOutlet weak var bookmarkBtn: UIButton!
    @IBOutlet weak var inviteBtn: UIButton!
    
    @IBOutlet weak var removeAccount: UIButton!
    
    @IBOutlet var imgView: UIView!
    @IBOutlet weak var mainview: UIView!
    @IBOutlet weak var optionsView: UIView!
    
    @IBOutlet var nameTxt: UITextField!
    @IBOutlet var nmbrTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
        
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var email = ""
    var dUser:User? = nil
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
       
        statsBtn.addBottomBorderWithColor(color: UIColor(named: Apps.BLUE1)!, width: 3,cornerRadius: 0)
        leaderboardBtn.addBottomBorderWithColor(color: UIColor(named: Apps.PINK1)!, width: 3,cornerRadius: 0)
        bookmarkBtn.addBottomBorderWithColor(color: UIColor(named: Apps.ORANGE1)!, width: 3,cornerRadius: 0)
        inviteBtn.addBottomBorderWithColor(color: UIColor(named: Apps.GREEN1)!, width: 3,cornerRadius: 0)
        
        usrImg.contentMode = .scaleAspectFill
        usrImg.clipsToBounds = true
        usrImg.layer.cornerRadius = usrImg.frame.height / 2
        usrImg.layer.masksToBounds = true
        usrImg.layer.borderWidth = 1.5
        usrImg.layer.borderColor =  Apps.BASIC_COLOR_CGCOLOR
        
        nameTxt.text = dUser!.name
        nmbrTxt.text = dUser!.phone
        email = dUser!.email
        emailTxt.text = dUser?.email
        
        DispatchQueue.main.async {
            if(self.dUser!.image != ""){
                self.usrImg.loadImageUsingCache(withUrl: self.dUser!.image)
            }
        }
                
        nmbrTxt.leftViewMode = UITextField.ViewMode.always
        if emailTxt.text != " " {
            nmbrTxt.rightViewMode = UITextField.ViewMode.always
            nmbrTxt.rightView = UIImageView(image:  UIImage(named: "edit"))
            nmbrTxt.tintColor = Apps.BASIC_COLOR
            
            emailTxt.leftViewMode = UITextField.ViewMode.always
        }else{
            nmbrTxt.isUserInteractionEnabled = false
        }
        nameTxt.leftViewMode = UITextField.ViewMode.always
        nameTxt.rightViewMode = UITextField.ViewMode.always
        nameTxt.rightView = UIImageView(image:  UIImage(named: "edit"))
        nameTxt.tintColor = Apps.BASIC_COLOR
            
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidLayoutSubviews() {
        //hide updt btn by default, show it on editing of any of textfields
        mainview.heightAnchor.constraint(equalToConstant: 380).isActive = true
        btnUpdate.isEnabled = false
        btnUpdate.setTitleColor(UIColor.darkGray, for: .normal)
        btnUpdate.layer.cornerRadius = btnUpdate.frame.height / 3
        removeAccount.layer.cornerRadius = btnUpdate.frame.height / 3
        logOutBtn.layer.cornerRadius = logOutBtn.frame.height / 3
        
        mainview.SetShadow()
        optionsView.SetShadow()
        logOutBtn.SetShadow()
    }

    @IBAction func showUpdateButton(_ sender: Any) {

        if btnUpdate.isEnabled == false{
            btnUpdate.isEnabled = true
            btnUpdate.setTitleColor(UIColor.white, for: .normal)
        }
    }
    @IBAction func removeAccountButton(_ sender: Any){
       //remove user from firebase
       //show alert once - if Yes - then chk for currUser id - if it is not found then ask for login again & then delete account.
        let alert = UIAlertController(title: Apps.REMOVE_ACC_TITLE,message: Apps.REMOVE_ACC_MSG,preferredStyle: .alert)
        let imageView = UIImageView(frame: CGRect(x: 90, y: 170, width: 230, height: 100))
        imageView.image = UIImage(named: "Sad Puppy")
        alert.view.addSubview(imageView)
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            //remove user from firebase and backend !!
            if let currUserID = self.dUser?.UID {
                print(currUserID)
                let user = Auth.auth().currentUser
                user?.delete { error in
                  if let error = error {
                    // An error happened.
                      print("\(error)")
                      self.ShowAlert(title: error as! String, message:"")
                      return
                  } else {
                    // Account deleted.
                      self.ShowAlertOnly(title: "Account deleted !!", message: "")
                      //remove user from backend
                      if(Reachability.isConnectedToNetwork()){
                          self.Loader = self.LoadLoader(loader: self.Loader)
                          var apiURL = ""
                          apiURL = "user_id=\(self.dUser?.userID ?? "0")"

                           print(apiURL)
                          self.getAPIData(apiName: "delete_user_account", apiURL: apiURL,completion: {_ in
                              //remove local preferences of use
                              UserDefaults.standard.set(false, forKey: "isLogedin")
                              UserDefaults.standard.removeObject(forKey: "user")
                              UserDefaults.standard.removeObject(forKey: "fr_code")
                              //go back to loginScreen.
                              DispatchQueue.main.async {
                                  let initialViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "LoginView")
                                  let navigationcontroller = UINavigationController(rootViewController: initialViewController)
                                  navigationcontroller.setNavigationBarHidden(true, animated: false)
                                  navigationcontroller.isNavigationBarHidden = true
                                  UIApplication.shared.windows.first!.rootViewController = navigationcontroller
                              }
                          })
                      }else{
                          self.ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
                      }
                  }
                }
            }else{
                let loginAlert = UIAlertController(title: Apps.NOT_LOGGED_IN,message: Apps.NOT_LOGGED_IN_MSG,preferredStyle: .alert)
                loginAlert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.default, handler: {
                    (alertAction: UIAlertAction!) in
                    loginAlert.dismiss(animated: true, completion: nil)
                    //and goto loginscreen
                    DispatchQueue.main.async {
                        let initialViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "LoginView")
                        let navigationcontroller = UINavigationController(rootViewController: initialViewController)
                        navigationcontroller.setNavigationBarHidden(true, animated: false)
                        navigationcontroller.isNavigationBarHidden = true
                        UIApplication.shared.windows.first!.rootViewController = navigationcontroller
                    }
                }))
                loginAlert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertAction.Style.default, handler: {
                    (alertAction: UIAlertAction!) in
                    loginAlert.dismiss(animated: true, completion: nil)
                }))
            }
        }))
        
        let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
        let width = NSLayoutConstraint(item: alert.view! , attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 400)
        alert.view.addConstraint(height)
        alert.view.addConstraint(width)
        
        alert.view.tintColor = (Apps.APPEARANCE == "dark") ? UIColor.white : UIColor.black  // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        view.bringSubviewToFront(alert.view)
        present(alert, animated: true, completion: nil)
    }
    
    //load data here
    func LoadData(jsonObj:NSDictionary){
        print("Update Profile Response - ",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.Loader.dismiss(animated: true, completion: {
                self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
            })
        }else{
            //get data for success response
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlertOnly(title: Apps.PROFILE_UPDT, message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.dUser!.name = self.nameTxt.text!
                self.dUser!.phone = self.nmbrTxt.text!
                UserDefaults.standard.set(try? PropertyListEncoder().encode(self.dUser), forKey: "user")
            }
        });
    }
    
    @IBAction func backButton(_ sender: Any) {
        addPopTransition()
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        ImagePickerManager().pickImage(self, {image in
            self.usrImg.image = image
            self.myImageUploadRequest()
        })
    }
    
    @IBAction func logoutBtn(_ sender: Any) {
        logOutUserAlert(self.dUser!)
    }
    
    @IBAction func updateButton(_ sender: Any) {
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            var apiURL = ""
            if dUser?.userType == "Mobile"{
                apiURL = "user_id=\(dUser?.userID ?? "0")&email=\(String(describing: emailTxt.text!))&name=\(String(describing: nameTxt.text!))"
            }else{
                apiURL = "user_id=\(dUser?.userID ?? "0")&email=\(String(describing: emailTxt.text!))&name=\(String(describing: nameTxt.text!))&mobile=\(String(describing: nmbrTxt.text!))"
            }         
             print(apiURL)
            self.getAPIData(apiName: "update_profile", apiURL: apiURL,completion: LoadData)
            //print("Data updated")
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    
    @IBAction func userStatisticsButton(_ sender: Any){
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "UserStatistics")
        self.addTransition()
        self.navigationController?.pushViewController(viewCont, animated: false)
    }
    
    @IBAction func leaderboardButton(_ sender: Any){
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "Leaderboard")
        self.addTransition()
        self.navigationController?.pushViewController(viewCont, animated: false)
    }
    
    @IBAction func bookmarksButton(_ sender: Any){
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "BookmarkView")
        self.addTransition()
        self.navigationController?.pushViewController(viewCont, animated: false)
    }
    
    @IBAction func inviteFriendsButton(_ sender: Any){
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "ReferAndEarn")
        self.addTransition()
        self.navigationController?.pushViewController(viewCont, animated: false)
    }
    
    
    
    func myImageUploadRequest(){
        
        let url = URL(string: Apps.URL)
        var request = URLRequest(url:url!);
        request.httpMethod = "POST";
        let user_id = "\(self.dUser!.userID)"
        let param = [
            "access_key"  : "\(Apps.ACCESS_KEY)",
            "upload_profile_image"    : "1",
            "user_id"    : user_id
        ]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let imageData = self.usrImg.image!.jpegData(compressionQuality: 0.5)
        
        if(imageData==nil)  {return; }
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "image", imageDataKey: imageData!, boundary: boundary) as Data
        request.addValue("Bearer \(GetTokenHash())", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {             // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {   // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                return
            }
            
            if let jsonObj = ((try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary) as NSDictionary??) {
                if (jsonObj != nil)  {
                    print("JSON",jsonObj!)
                    let status = jsonObj!.value(forKey: "error") as! String
                    if (status == "true") {
                        self.Loader.dismiss(animated: true, completion: {
                            self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj!.value(forKey: "message")!)" )
                        })
                        
                    }else{
                        //get data for success response
                        self.dUser?.image = jsonObj!.value(forKey: "file_path") as! String
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.dUser), forKey: "user")
                    }
                }else{
                }
            }
        }
        task.resume()        
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        var body = Data();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let filename = "\(Date().currentTimeMillis()).jpg"
        let mimetype = "image/jpg"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}
