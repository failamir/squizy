import Foundation
import UIKit
//import FirebaseInstanceID
import AVFoundation
import Reachability
import SystemConfiguration
import SwiftyJWT
import Firebase

extension UIViewController{
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
//    func hideCurrViewWhenTappedAround() {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissCurrView))
//        tap.numberOfTapsRequired = 2
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
//    }
    
    @objc func dismissCurrView() {
        addPopTransition()
        self.navigationController?.popViewController(animated: false)
//        self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
    
    //play sound
    func PlaySound(player:inout AVAudioPlayer!,file:String){
        let soundURL = Bundle.main.url(forResource: file, withExtension: "mp3")
        do {
            player = try AVAudioPlayer(contentsOf: soundURL!)
        }
        catch {
            print(error)
        }
        let setting = try! PropertyListDecoder().decode(Setting.self, from: (UserDefaults.standard.value(forKey:"setting") as? Data)!)
        if setting.sound {
            player.play()
        }
    }
    
    func PlayBackgrounMusic(player:inout AVAudioPlayer!,file:String){
        let soundURL = Bundle.main.url(forResource: file, withExtension: "mp3")
        do {
            player = try AVAudioPlayer(contentsOf: soundURL!)
            player.numberOfLoops = -1
            player.prepareToPlay()
            
            if(UserDefaults.standard.value(forKey:"setting") == nil){
                UserDefaults.standard.set(try? PropertyListEncoder().encode(Setting.init(sound: true, backMusic: false, vibration: true)),forKey: "setting")
            }
            let setting = try! PropertyListDecoder().decode(Setting.self, from: (UserDefaults.standard.value(forKey:"setting") as? Data)!)
            
            if setting.backMusic {
                player.play()
            }
        }
        catch {
            print(error)
        }
    }
    
    //do device vibration
    func Vibrate(){
        let setting = try! PropertyListDecoder().decode(Setting.self, from: (UserDefaults.standard.value(forKey:"setting") as? Data)!)
        if setting.vibration {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    // generate JWT Token Hash
       func GetTokenHash() -> String {
        let headerWithKeyId = JWTHeader.init(keyId:Apps.JWT)

           var payload = JWTPayload()
           payload.expiration = Int(Date(timeIntervalSinceNow: 60).timeIntervalSince1970)
           payload.issuer = "quiz"
           payload.subject = "quiz Authentication"
           payload.issueAt = Int(Date().timeIntervalSince1970)
           let alg = JWTAlgorithm.hs256(Apps.JWT)
           let jwtWithKeyId = JWT.init(payload: payload, algorithm: alg, header: headerWithKeyId) //try?
        
           return jwtWithKeyId!.rawString!
       }

    
    // get api data
    func getAPIData(apiName:String, apiURL:String,completion:@escaping (NSDictionary)->Void,image:UIImageView? = nil){
              
        let url = URL(string: Apps.URL)!
        let postString = "access_key=\(Apps.ACCESS_KEY)&\(apiName)=1&\(apiURL)"
            print("POST URL",url)
            print("POST String = \(postString)")
            print("token \(GetTokenHash())")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = Data(postString.utf8)
        request.addValue("Bearer \(GetTokenHash())", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {             // check for fundamental networking error
                print("error=\(String(describing: error))")
                let res = ["status":false,"message":"JSON Parser Error - NW Error"] as NSDictionary
                completion(res)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {   // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                let res = ["status":false,"message":"JSON Parser Error - HTTP Error"] as NSDictionary
                completion(res)
                return
            }
            
            if let jsonObj = ((try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary) as NSDictionary??) {
                if (jsonObj != nil)  {
                    completion(jsonObj!)
                }else{
                    let res = ["status":false,"message":"JSON Parser Error - API Error"] as NSDictionary
                    completion(res)
                    print("JSON API ERROR",String(data: data, encoding: String.Encoding.utf8)!)
                }
            }else{
                let res = ["error":"false","message":"Error while fetching data"] as NSDictionary
                print("JSON API ERROR",String(data: data, encoding: String.Encoding.utf8)!)
                completion(res)
            }
        }
        task.resume()
    }
    //refer code generator
    func referCodeGenerator(_ displayNm: String) -> String {
        let displayname = displayNm
        var g = SystemRandomNumberGenerator()
        let rn = Int.random(in: 0000...9999, using: &g)
        let referCode = (displayname)+String(rn)
        
        return referCode
    }
    //random Numbers for battle game room code
    func randomNumberForBattle() -> String {
        var g = SystemRandomNumberGenerator()
        let rn = Int.random(in: 00000...99999, using: &g)//5 digits
        var code = String(rn)
        if code.count < 5 {
            code = "0\(code)"
        }
        print(code)
        return code
    }
           
    //load loader
    func LoadLoader(loader:UIAlertController)->UIAlertController{
        let pending = UIAlertController(title: nil, message: Apps.WAIT , preferredStyle: .alert)
        
        pending.view.tintColor = (Apps.APPEARANCE == "dark") ? UIColor.white : UIColor.black //UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x:10,y:5), size: CGSize(width: 50, height: 50))) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium//UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
          
        pending.view.addSubview(loadingIndicator)
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2, execute: {
            DispatchQueue.main.async {
                self.present(pending, animated: true, completion: nil)
            }
        });
        return pending 
    }
    //show alert view here with any title and messages
    func ShowAlert(title:String,message:String){
        
        let attributedTitle = NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor : Apps.BASIC_COLOR
        ])

        let attributedMsg = NSAttributedString(string: message, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13), //UIFont.systemFont(ofSize: 15)
            NSAttributedString.Key.foregroundColor : (Apps.APPEARANCE == "dark") ? UIColor.white : UIColor.black //UIColor.black
        ])
                
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = Apps.BASIC_COLOR
        alert.addAction(UIAlertAction(title: Apps.OKAY, style: UIAlertAction.Style.cancel, handler: nil)) //Apps.DISMISS
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.45, execute: {
            DispatchQueue.main.async {
                self.getTopMostViewController()?.present(alert, animated: true, completion: nil)
            }
        });
        alert.setValue((attributedTitle), forKey: "attributedTitle")
        alert.setValue(attributedMsg, forKey: "attributedMessage")
        
        /*let attributedTitle = NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17), //your font here
            NSAttributedString.Key.foregroundColor : Apps.BASIC_COLOR
        ])

        let attributedMsg = NSAttributedString(string: message, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13), //UIFont.systemFont(ofSize: 15)
            NSAttributedString.Key.foregroundColor : UIColor.black
        ])
        let alert = UIAlertController(title: "", message: "",  preferredStyle: .alert)

        alert.setValue((attributedTitle), forKey: "attributedTitle")
        alert.setValue(attributedMsg, forKey: "attributedMessage")

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        }
        
        alert.view.tintColor = Apps.BASIC_COLOR
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)*/
        
    }
    //show alert view here with any title and messages & without button
    func ShowAlertOnly(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for c  in 0...15 {
            if c == 0 {
                self.present(alert, animated: true)
            }
            if c == 15 {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    func logOutUserAlert(_ user: User){
        let alert = UIAlertController(title: Apps.LOGOUT_TITLE,message: Apps.LOGOUT_MSG,preferredStyle: .alert)
        let imageView = UIImageView(frame: CGRect(x: 30, y: 100, width: 230, height: 100))
        imageView.image = UIImage(named: "Sad Puppy")
        alert.view.addSubview(imageView)
        
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            user.userLogOut(user)
        }))
        
        let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        let width = NSLayoutConstraint(item: alert.view! , attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        alert.view.addConstraint(height)
        alert.view.addConstraint(width)
        
        alert.view.tintColor = (Apps.APPEARANCE == "dark") ? UIColor.white : UIColor.black  // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)        
    }
    /*
    //Actionsheet for Settings Alert
    class func settingsAlert(vc: UIViewController){
    //(title: String, titleColor: UIColor, message: String, preferredStyle: UIAlertController.Style, titleAction: String, actionStyle: UIAlertAction.Style, vc: UIViewController) {

//        let attributedString = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: titleColor])
//        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
//
//        alert.setValue(attributedString, forKey: "attributedTitle")
//
//        alert.addAction(UIAlertAction(title: titleAction, style: actionStyle, handler: nil))
//        vc.present(alert, animated: true)
        
//        let attributedString = NSAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.red])
       /* let alert = UIAlertController() //(title: "", message: "", preferredStyle: .actionSheet)
//        alert.setValue(attributedString, forKey: "attributedTitle")
        
        let soundButton = UIAlertAction(title: "Sound", style: .default, handler: { _ in
            let switchControl = UISwitch(frame:CGRect(x: 60, y: 20, width: 0, height: 0));
            switchControl.isOn = true
            switchControl.setOn(true, animated: false);
            switchControl.addTarget(self, action: "switchValueDidChange:", for: .valueChanged)
            alert.view.addSubview(switchControl)//(createSwitch())
            
        })//sound
        soundButton.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        alert.addAction(soundButton)
        alert.addAction(UIAlertAction(title: "Vibration", style: .default, handler: nil))//vibration
        alert.addAction(UIAlertAction(title: "Background Music", style: .default, handler: nil))//bgMusic
        alert.addAction(UIAlertAction(title: "Font Size", style: .default, handler: nil))//font Size
        alert.addAction(UIAlertAction(title: "Rate Us", style: .default, handler: nil))//Rate us
        alert.addAction(UIAlertAction(title: "Share App", style: .default, handler: nil))//share App
        alert.addAction(UIAlertAction(title: "More Apps", style: .default, handler: nil))//More App
        alert.addAction(UIAlertAction(title: "Save Settings", style: .cancel, handler: nil))//Okay button
        vc.present(alert, animated: true) */
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let viewAction =  UIAlertAction(title: "View", style: .default , handler:{ (UIAlertAction)in
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let orderDetailVC = storyboard.instantiateViewController(withIdentifier: "orderDetail") as! OrderDetailTableViewController
//            orderDetailVC.orderId = self.myDraftOrders[indexPath.row]["id"].intValue
//            self.navigationController?.pushViewController(orderDetailVC, animated: true)
        })
        viewAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(viewAction)
        let modifyAction = UIAlertAction(title: "Modify", style: .default, handler:{ (UIAlertAction)in
            print("User click Modify button")
            //showAlert("Coming soon...")
        })
//        let separator = UIView(frame: CGRect(x: 8, y: 88, width: 16, height: 0.5)) //CGRect(x: 8, y: 88, width: 16, height: 0.5)
//        separator.backgroundColor = UIColor.rgb(219,219,223,1)
//        alert.view.addSubview(separator)
        
        modifyAction.setValue(UIColor.black, forKey: "titleTextColor")
      //  modifyAction.setValue(true, forKey: "checked")
        alert.addAction(modifyAction)
        let copyAction = UIAlertAction(title: "Copy", style: .default, handler:{ (UIAlertAction)in
            print("User click Copy button")
            //self.copyOrder(orderId: self.myDraftOrders[indexPath.row]["id"].intValue)
        })
        copyAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(copyAction)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler:{ (UIAlertAction)in
            print("User click delete button")
            // self.deleteOrder(orderId: self.myDraftOrders[indexPath.row]["id"].intValue, indexPath: indexPath)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        let width: Int = Int(UIScreen.main.bounds.width - 100)
        if deviceStoryBoard == "Ipad" {
            let popover = alert.popoverPresentationController
            popover!.sourceView = vc.view//vc as? UIView
            popover!.sourceRect = CGRect(x: width,y: 25,width: 0,height: 0)
        }
        vc.present(alert, animated: true)
          
    }
//    func createSwitch () -> UISwitch{
//        let switchControl = UISwitch()//frame:CGRectMake(10, 20, 0, 0));
//        switchControl.isOn = true
//        switchControl.setOn(true, animated: false);
//        switchControl.addTarget(self, action: "switchValueDidChange:", for: .valueChanged);
//        return switchControl
//    }
    func switchValueDidChange(sender:UISwitch!){
        print("Switch Value : \(sender.isOn))")
    }*/
    //dismiss loader
    func DismissLoader(loader:UIAlertController){
        //DispatchQueue.main.async {
            loader.dismiss(animated: true, completion: nil)
        //}
    }
    
    func battleOpponentAnswer(btn: UIButton, str: String){
        var lblWidth:CGFloat = 90
        var lblHeight:CGFloat = 25
        var fontSize: CGFloat = 12
        
        if deviceStoryBoard == "Ipad" {
            lblWidth = 180
            lblHeight = 50
            fontSize = 24
        }
        print("opponent answer done")
        let lbl = UILabel(frame: CGRect(x: btn.frame.size.width - (lblWidth + 5) ,y: (btn.frame.size.height - lblHeight)/2, width: lblWidth, height: lblHeight))
        lbl.textAlignment = .center
        lbl.text = "\(str)"
        lbl.tag = 11 // identified tag for remove it from its super view
        lbl.clipsToBounds = true
        lbl.layer.cornerRadius = lblHeight / 3//2
        if btn.tag == 1{ // true answer
            lbl.textColor = Apps.RIGHT_ANS_COLOR
        }else{ //wrong answer
            lbl.textColor = Apps.WRONG_ANS_COLOR
        }
              // if clickedButton.contains(btn){
                   lbl.backgroundColor = UIColor.white //UIColor.rgb(211, 205, 139, 1)
              // }
        
        lbl.font = .systemFont(ofSize: fontSize)
        btn.addSubview(lbl)
    }
    
    // reachability class
    public class Reachability {
        class func isConnectedToNetwork() -> Bool {
            
            var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }
            var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
            if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
                return false
            }
            
            // Working for Cellular and WIFI
            let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
            let ret = (isReachable && !needsConnection)
            return ret
            
        }
    }
    
  /*  class IAPLoader {
        
        var container: UIView = UIView()
        var loadingView: UIView = UIView()
        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

        func showActivityIndicator(uiView: UIView) {
            
            container.frame = uiView.frame
            container.center = uiView.center
            container.backgroundColor = .clear //UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)
        
            loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            loadingView.center = uiView.center
            loadingView.backgroundColor = Apps.WHITE_ALPHA//.lightGray
            loadingView.clipsToBounds = true
            loadingView.layer.cornerRadius = 10
            loadingView.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
            loadingView.layer.borderWidth  = 1
        
            activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
            activityIndicator.style = UIActivityIndicatorView.Style.large
            activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2);
            activityIndicator.color = Apps.BASIC_COLOR
            
            loadingView.addSubview(activityIndicator)
            container.addSubview(loadingView)
            uiView.addSubview(container)
            activityIndicator.startAnimating()
        }

        func hideActivityIndicator(uiView: UIView) {
            activityIndicator.stopAnimating()
            container.removeFromSuperview()
        }
    }*/
    
    //design image view
    func DesignImageView(_ images:UIImageView...){
        for image in images{
            image.layer.backgroundColor = UIColor.white.cgColor
            image.layer.masksToBounds = false
            image.clipsToBounds = true
            image.layer.cornerRadius = image.frame.width / 2
        }
    }
        
    func RegisterNotification(notificationName:String){
        NotificationCenter.default.addObserver(self,selector: #selector(self.Dismiss),name: NSNotification.Name(rawValue: notificationName),object: nil)
    }
    func addTransitionAndPushViewController(_ viewCont : UIViewController,_ type: CATransitionSubtype){
        let transition = CATransition.init()
        transition.duration = 0.4
        transition.type = .push
        transition.subtype = type//.fromLeft//.fromTop
       // if let transition = transition {
        self.navigationController?.view.layer.add(
                transition,
                forKey: kCATransition)
       // }
        //if let VC = viewCont {
        self.navigationController?.pushViewController(viewCont, animated: false)
        //}
    }
    func addTransitionAndPopViewController(_ type: CATransitionSubtype){
        let transition = CATransition.init()
        transition.duration = 0.4
        transition.type = .reveal
        transition.subtype = type//.fromBottom
       // if let transition = transition {
        self.navigationController?.view.layer.add(
                transition,
                forKey: kCATransition)
       // }
        self.navigationController?.popViewController(animated: false)
    }
    @objc func Dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    func CallNotification(notificationName:String){
        NotificationCenter.default.post(name: Notification.Name(notificationName), object: nil)
    }
    
    // set verticle progress bar here
    func setVerticleProgress(view:UIView, progress:UIProgressView){
        view.addSubview(progress)
        progress.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progress.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        progress.widthAnchor.constraint(equalToConstant: view.frame.size.height).isActive = true
        progress.heightAnchor.constraint(equalToConstant: 20).isActive = true
        progress.setProgress(0, animated: true)
    }
    
    //design four choice view function
    func SetViewWithoutShadow(views:UIView...){
        for view in views{
            DispatchQueue.main.async {
                view.layer.cornerRadius =  10//15//25//0
            }            
           // view.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
        }
    }
    
    // design option button
    func DesignOptionButton(buttons: UIButton...){
        DispatchQueue.main.async {
            for button in buttons{
                button.contentMode = .center
                button.layer.cornerRadius =  10//15//25//0
               // button.SetShadow()
                button.titleLabel?.numberOfLines = 0
                button.titleLabel?.lineBreakMode = .byWordWrapping
            }
        }        
    }
    
   /* func AllignButton(buttons:UIButton...){
        let width = self.view.frame.width
        var x = (width - (CGFloat(buttons.count) * buttons[0].frame.width)) / CGFloat(buttons.count + 1)
        let tempX = x
        var count = 0
        for button in buttons{
            button.frame.origin.x = x + button.frame.width * CGFloat(count)
            x = x + tempX
            count += 1
        }
    } */
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func checkForValues(_ diff : Int){
       // print("count of tintArr - \(Apps.tintArr.count) - Arr1 -\(Apps.arrColors1) - Arr2 -\(Apps.arrColors2) -- difference val - \(diff)")
        if Apps.arrColors1.count < diff {
            let dif = diff - (Apps.arrColors1.count - 1)
//        if Apps.tintArr.count < diff {
//            let dif = diff - (Apps.tintArr.count - 1)
            print("difference - \(dif)")
            for i in 0...dif{
                Apps.arrColors1.append(Apps.arrColors1[i])
                Apps.arrColors2.append(Apps.arrColors2[i])
                Apps.tintArr.append(Apps.tintArr[i])
            }
            //print("tintColors -\(Apps.tintArr) with count \(Apps.tintArr.count)\n Arr1 - \(Apps.arrColors1) with count \(Apps.arrColors1.count)\n Arr2 - \(Apps.arrColors2) with count \(Apps.arrColors2.count)")
        }
    }
    
    func SetButtonHeight(buttons:UIButton... , view:UIView,scroll:UIScrollView){
        var btnY = 0
        var minHeight = 50
        if UIDevice.current.userInterfaceIdiom == .pad{
            minHeight = 90
        }else{
            minHeight = 50
        }
        scroll.setContentOffset(.zero, animated: true)
        
        let perButtonChar = 35
        var extraHeight: CGFloat = 10
        if deviceStoryBoard == "Ipad" {
            extraHeight = 30
        }
        btnY = Int(view.frame.height + view.frame.origin.y + extraHeight)
        
        for button in buttons{
            let btnWidth = button.frame.width
            //let fonSize = 18
            let charCount = button.title(for: .normal)?.count
            
            let btnX = button.frame.origin.x
            
            let charLine = Int(charCount! / perButtonChar) + 1
            
            let btnHeight = charLine * 20 < minHeight ? minHeight : charLine * 20
            
            let newFram = CGRect(x: Int(btnX), y: btnY, width: Int(btnWidth), height: btnHeight)
            btnY += btnHeight + 8
            
            button.frame = newFram
            
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.numberOfLines = 0
        }
        let widthh = scroll.frame.width
        scroll.contentSize = CGSize(width: Int(widthh), height: Int(btnY) + 10)
    }
    /* code from RobotPlay
     var btnY = 0
     func SetButtonHeight(buttons:UIButton...){
         
         var minHeight = 50
         if UIDevice.current.userInterfaceIdiom == .pad{
             minHeight = 90
         }else{
             minHeight = 50
         }
         self.scroll.setContentOffset(.zero, animated: true)
         
         let perButtonChar = 35
         var extraHeight: CGFloat = 10
         if deviceStoryBoard == "Ipad" {
             extraHeight = 30
         }
         btnY = Int(self.secondChildView.frame.height + self.secondChildView.frame.origin.y + extraHeight)
         
         for button in buttons{
             let btnWidth = button.frame.width
             //let fonSize = 18
             let charCount = button.title(for: .normal)?.count
             
             let btnX = button.frame.origin.x
             
             let charLine = Int(charCount! / perButtonChar) + 1
             
             let btnHeight = charLine * 20 < minHeight ? minHeight : charLine * 20
             
             let newFram = CGRect(x: Int(btnX), y: btnY, width: Int(btnWidth), height: btnHeight)
             btnY += btnHeight + 8
             
             button.frame = newFram
             
             button.titleLabel?.lineBreakMode = .byWordWrapping
             button.titleLabel?.numberOfLines = 0
         }
         let with = self.scroll.frame.width
         self.scroll.contentSize = CGSize(width: Int(with), height: Int(btnY))
     }
     */
    
}

extension UIView {
    
    func createImage() -> UIImage {
        
        let rect: CGRect = self.frame 
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
        
    }
    
}

extension String {
    var bool: Bool? {
        switch self.lowercased() {
        case "true", "t", "yes", "y", "1":
            return true
        case "false", "f", "no", "n", "0":
            return false
        default:
            return nil
        }
    }
}
