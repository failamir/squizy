import Foundation
import UIKit
import AVFoundation
import Reachability
import SystemConfiguration
import Firebase

//color setting that will use in whole apps
extension UIColor{
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
        return UIColor.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
    
    static let Vertical_progress_true = Apps.RIGHT_ANS_COLOR //verticle proress bar color for true answer
    static let Vertical_progress_false = Apps.WRONG_ANS_COLOR // verticle progress bar color for false answer
    
    static func random(from colors: [UIColor]) -> UIColor? {
        return colors.randomElement()
    }
}

/* extension UIProgressView{
    
    // set  verticle progress bar here
    static func Vertical(color: UIColor)->UIProgressView{
            let prgressView = UIProgressView()
            prgressView.progress = 0.0
            prgressView.progressTintColor = color
            prgressView.trackTintColor = UIColor.clear
            prgressView.layer.borderColor = color.cgColor
            prgressView.layer.borderWidth = 2
            prgressView.layer.cornerRadius = 10
            prgressView.clipsToBounds = true
            prgressView.transform = CGAffineTransform(rotationAngle: .pi / -2)
            prgressView.translatesAutoresizingMaskIntoConstraints = false
            return prgressView
    }
    
  /*  static func Horizontal(color: UIColor)->UIProgressView{
          let prgressView = UIProgressView()
          prgressView.progress = 0.0
          prgressView.progressTintColor = color
          prgressView.trackTintColor = UIColor.clear
          prgressView.layer.borderColor = color.cgColor
          prgressView.layer.borderWidth = 20
          prgressView.layer.cornerRadius = 10
          prgressView.clipsToBounds = true
         // prgressView.transform = CGAffineTransform(rotationAngle: .pi / -2)
          prgressView.translatesAutoresizingMaskIntoConstraints = false
          return prgressView
      } */
} */
extension User{
    func userLogOut(_ user: User){
        if user.userType == "apple"{
            // if app is not loged in than navigate to loginview controller
            UserDefaults.standard.set(false, forKey: "isLogedin")
            UserDefaults.standard.removeObject(forKey: "user")
            UserDefaults.standard.removeObject(forKey: "fr_code")
            // let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let initialViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "LoginView")
            let navigationcontroller = UINavigationController(rootViewController: initialViewController)
            navigationcontroller.setNavigationBarHidden(true, animated: false)
            navigationcontroller.isNavigationBarHidden = true
            UIApplication.shared.windows.first!.rootViewController = navigationcontroller //keyWindow?
            return
       }//if fb -> fbLoginManager.logout same as signIn
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                UserDefaults.standard.removeObject(forKey: "isLogedin")
                //remove friend code
                UserDefaults.standard.removeObject(forKey: "fr_code")
                UserDefaults.standard.removeObject(forKey: "user")
                //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                let initialViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "LoginView")
                let navigationcontroller = UINavigationController(rootViewController: initialViewController)
                navigationcontroller.setNavigationBarHidden(true, animated: false)
                navigationcontroller.isNavigationBarHidden = true
                UIApplication.shared.windows.first!.rootViewController = navigationcontroller //keyWindow?
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
//        if user.userType == "apple"{
//           // if app is not loged in then navigate to loginview controller
//           UserDefaults.standard.set(false, forKey: "isLogedin")
//           UserDefaults.standard.removeObject(forKey: "fr_code")
//           UserDefaults.standard.removeObject(forKey: "user")
//           //let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//           let initialViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "LoginView")
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
//                let initialViewController = Apps.storyBoard.instantiateViewController(withIdentifier: "LoginView")
//                let navigationcontroller = UINavigationController(rootViewController: initialViewController)
//                navigationcontroller.setNavigationBarHidden(true, animated: false)
//                navigationcontroller.isNavigationBarHidden = true
//                UIApplication.shared.windows.first!.rootViewController = navigationcontroller
////                self.navigationController?.popToViewController( (self.navigationController?.viewControllers[0]) as! LoginView, animated: true)
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//        }
    }
}
extension Data {
    
    mutating func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

let imageCache = NSCache<NSString, AnyObject>()
extension UIImageView {
    func loadImageUsingCache(withUrl urlString : String) {
        let url = URL(string: urlString)
        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        // if not, download image from url
        if url != nil{
            URLSession.shared.dataTask(with: (url)!, completionHandler: { (data, response, error) in
                       if error != nil {
                           print(error!)
                           return
                       }
                       DispatchQueue.main.async {
                           if let image = UIImage(data: data!) {
                               imageCache.setObject(image, forKey: urlString as NSString)
                               self.image = image
                           }
                       }
                   }).resume()
        }
    }
    static func fromGif(frame: CGRect, resourceName: String) -> UIImageView? { //to display GIF
        guard let path = Bundle.main.path(forResource: resourceName, ofType: "gif") else {
            print("Gif does not exist at that path")
            return nil
        }
        let url = URL(fileURLWithPath: path)
        guard let gifData = try? Data(contentsOf: url),
            let source =  CGImageSourceCreateWithData(gifData as CFData, nil) else { return nil }
        var images = [UIImage]()
        let imageCount = CGImageSourceGetCount(source)
        for i in 0 ..< imageCount {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: image))
            }
        }
        let gifImageView = UIImageView(frame: frame)
        gifImageView.contentMode = .scaleAspectFit
        gifImageView.layer.masksToBounds = true
        gifImageView.animationImages = images
        return gifImageView
    }
    
  /*  func aspectFitImage(inRect rect: CGRect) -> UIImage? {
        let width = self.frame.width
        let height = self.frame.height
            let aspectWidth = rect.width / width
            let aspectHeight = rect.height / height
            let scaleFactor = aspectWidth > aspectHeight ? rect.size.height / height : rect.size.width / width

            UIGraphicsBeginImageContextWithOptions(CGSize(width: width * scaleFactor, height: height * scaleFactor), false, 0.0)
            self.draw(CGRect(x: 0.0, y: 0.0, width: width * scaleFactor, height: height * scaleFactor))

            defer {
                UIGraphicsEndImageContext()
            }
            return UIGraphicsGetImageFromCurrentImageContext()
        } */ // usage: cell.bookImg.image = cell.bookImg?.aspectFitImage(inRect: cell.bookImg.frame)
}
extension Date{
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
   /* func endOfDay() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: Calendar.current.startOfDay(for: self))!
    }
    
    func endOfMonth() -> Date {
       var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth())!
    } */
    
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
extension UITextView {
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
    // html tags set
  /*  func stringFormation(_ str: String) {
        let recStr = str
        var getFont = UserDefaults.standard.float(forKey: "fontSize")
        if (getFont == 0){
            getFont = (deviceStoryBoard == "Ipad") ? 26 : 16
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        self.attributedText = recStr.htmlToAttributedString
        self.font = UIFont(name: "Optima", size: CGFloat(getFont)) //.systemFont(ofSize: CGFloat(getFont)) //UIFont(name: "System Medium", size: CGFloat(getFont))
    }    */
}
extension UILabel{
   /* func setLabel(){
          self.numberOfLines = 0
          let maximumLabelSize: CGSize = CGSize(width: self.frame.width, height: self.frame.height)
          let expectedLabelSize: CGSize = self.sizeThatFits(maximumLabelSize)
          // create a frame that is filled with the UILabel frame data
          var newFrame: CGRect = self.frame
        //   newFrame.size.width = expectedLabelSize.width
           newFrame.size.height = expectedLabelSize.height
          self.frame = newFrame
       } */
    
    func textChangeAnimation() {
        let animationS:CATransition = CATransition()
        animationS.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        animationS.type = CATransitionType.push
        animationS.subtype = CATransitionSubtype.fromTop
       // self.userCount1.text = "\(String(format: "%02d", rightCount))"
        animationS.duration = 1.50
        self.layer.add(animationS, forKey: "CATransition")
    }
   /* func textChangeAnimationToRight() {
         let animationS:CATransition = CATransition()
         animationS.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
         animationS.type = CATransitionType.push
         animationS.subtype = CATransitionSubtype.fromLeft
         animationS.duration = 1.50 //0.25//
        self.layer.add(animationS, forKey: "CATransition")
    } */
    func typeOn(string: String, typeInterval: TimeInterval) { //use with text which are loading only once - not working with refreshing text - i.e. TableViewCell label text
        let characterArray = string.characterArray
        var characterIndex = 0
        Timer.scheduledTimer(withTimeInterval: typeInterval, repeats: true) { (timer) in
            while characterArray[characterIndex] == " " {
                self.text! += " "
                characterIndex += 1
                if characterIndex == characterArray.count {
                    timer.invalidate()
                    return
                }
            }
            UIView.transition(with: self,
                              duration: typeInterval,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.text! += String(characterArray[characterIndex])
            })
            characterIndex += 1
            if characterIndex == characterArray.count {
                timer.invalidate()
            }
        }
    }
}
extension UIButton {
    
    func resizeButton() {
        let btnSize = titleLabel?.sizeThatFits(CGSize(width: frame.width, height: .greatestFiniteMagnitude)) ?? .zero
        let desiredButtonSize = CGSize(width: btnSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: btnSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
        self.titleLabel?.sizeThatFits(desiredButtonSize)
    }
    func setBorder(){
        self.layer.cornerRadius = self.frame.height / 3 //2 //15
        self.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR  //UIColor.white.cgColor
        self.layer.borderWidth = 2
    }
    func setOptionBorder(){
        self.layer.cornerRadius =  10
        self.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR  //UIColor.white.cgColor
        self.layer.borderWidth = 1
    }
    
    func setLoginBorder(){
        self.layer.cornerRadius = self.frame.height / 4
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
    }
    
//    func addBottomBorder(width: CGFloat) {
//        let border = CALayer()
//        border.backgroundColor = UIColor.black.cgColor
//        border.frame = CGRect(x: 0, y: self.frame.size.height - 5, width: self.frame.size.width, height: width)
//      //  self.layer.addSublayer(border)
//        self.layer.insertSublayer(border, at: 0)
//    }
//    func removeBottomBorder(){
//        if let topLayer = self.layer.sublayers?.last, topLayer is CALayer
//        {
//        self.layer.removeFromSuperlayer()
//        }
//    }
}

extension UIView{
   /* func navBar(navBar: UINavigationBar){
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        navBar.backgroundColor = Apps.WHITE_ALPHA
    } */
    
    func shadow(color : UIColor, offSet:CGSize, opacity: Float = 0.7, radius: CGFloat = 30, scale: Bool = true){
        DispatchQueue.main.async {
            self.layer.masksToBounds = false
            self.layer.shadowColor = color.cgColor
            self.layer.shadowOpacity = opacity
            self.layer.shadowOffset = offSet
            self.layer.shadowRadius = radius
        }
//        DispatchQueue.main.async {
//            self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
//            self.layer.shouldRasterize = true
//            self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
//        }
    }
    
  /*  func applyGradient(colors: [CGColor])
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.3)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.8)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = 30
        self.layer.addSublayer(gradientLayer)
    } */
    
    func DesignViewWithShadow(){
       self.layer.cornerRadius = 10
//        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds,cornerRadius: self.layer.cornerRadius).cgPath
//        self.layer.shadowColor = UIColor.lightGray.cgColor
//        self.layer.shadowOpacity = 0.7//5
//        self.layer.shadowOffset = CGSize(width: 3, height: 3) //5
//        self.layer.shadowRadius = 1
//        self.layer.masksToBounds = false
//        self.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
//        self.layer.borderWidth = 1
        self.backgroundColor =  UIColor.white//UIColor.white.withAlphaComponent(0.4) //Apps.BASIC_COLOR//
//        self.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 20, scale: true) //30
    }
    
    func SetShadow(){
        
        //self.layer.cornerRadius = 6
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0.7, height: 0.7)
        self.layer.masksToBounds = false
    }
    
  /*  func SetDarkShadow(){
        self.layer.cornerRadius = self.frame.height / 2 //35
        self.layer.shadowColor =  UIColor.black.cgColor //UIColor(named: "blue1")!.cgColor
        self.layer.shadowOffset = CGSize(width: 3, height: 4)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
    } */
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        DispatchQueue.main.async {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
//            mask.frame = self.bounds
//            self.clipsToBounds = true
        }
    }
    
    //battle modes
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0,y: 0, width:self.frame.size.width, height:width)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithGradientColor(startColor: UIColor,endColor: UIColor, width: CGFloat, cornerRadius: CGFloat) {
        let border = CALayer()
        //border.sublayers = nil //remove sublayer / gradient layer from CALayer
        border.sublayers?.forEach { $0.removeFromSuperlayer() }
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0,y: 1)
        gradientLayer.endPoint = CGPoint(x: 1,y: 0)
       // gradientLayer.locations = [0.50, 0.1]
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: border.frame.size.width, height: border.frame.size.height)
        gradientLayer.cornerRadius = cornerRadius
        border.cornerRadius = cornerRadius
        border.addSublayer(gradientLayer)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat, cornerRadius: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        border.cornerRadius = cornerRadius
        self.layer.addSublayer(border)
    }
    
   /* func addCenterBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0,y: self.frame.height / 2, width:self.frame.size.width, height:width)
        self.layer.addSublayer(border)
    } */
    
    func setGradientLayer(_ color1: UIColor,_ color2: UIColor)
    {
        let gradientLayer = CAGradientLayer()
        self.backgroundColor = .clear
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0,y: 1)
        gradientLayer.endPoint = CGPoint(x: 1,y: 0)
        gradientLayer.locations = [0.50, 0.1]
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width * UIScreen.main.bounds.width, height: self.frame.size.height * UIScreen.main.bounds.height)
        //gradientLayer.shouldRasterize = true
        //gradientLayer.cornerRadius = 25 //self.layer.cornerRadius
//        gradientLayer.roundCorners(corners: [ .bottomLeft, .topLeft], radius: 10)
        if let topLayer = self.layer.sublayers?.first, topLayer is CAGradientLayer
        {
            topLayer.removeFromSuperlayer()
        }
       //self.layer.addSublayer(gradientLayer)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
//    func setGradientHome(_ color1: UIColor,_ color2: UIColor)
//    {
//        let l = CAGradientLayer()
//        l.type = kCAGradientLayerAxial
//        self.backgroundColor = .clear
//        l.colors = [ color1.cgColor,color2.cgColor]
//        l.locations = [ 0.1,1.5 ]
////        l.startPoint = CGPoint(x: 1.0, y: 0.5)
////        l.endPoint = CGPoint(x: 0.5, y: 1.0)
//        l.startPoint = CGPoint(x: 0.5, y: 1.5)
//        l.endPoint = CGPoint(x: 1.0, y: 2.5)
//        l.frame = self.bounds
//        if let topLayer = self.layer.sublayers?.first, topLayer is CAGradientLayer
//        {
//            topLayer.removeFromSuperlayer()
//        }
//        self.layer.insertSublayer(l, at: 0)
//        print("home gradient - color -- \(color2) - \(color1)")
//
//    }
    
    func setCellShadow(){
        let subLayer = self.layer//.superlayer//sublayers?.last
        //subLayer.cornerRadius = 5
        subLayer.shadowColor = UIColor.gray.cgColor//.label.cgColor
        subLayer.shadowOffset = CGSize(width: 1, height: 2) //CGSize(width: 3, height: 4)
        subLayer.shadowOpacity = 0.7//0.5//0.2 //1
        subLayer.shadowRadius = 4
        subLayer.masksToBounds = false//subLayer!.masksToBounds = false //self.layer.
    }
}

extension UIViewController{
    func secondsToHoursMinutesSeconds (seconds : Int) -> String {
        //String(format: "%02d", (seconds % 3600) % 60)
        if seconds % 3600 == 0{
             return "60:00"
        }
        return "\(String(format: "%02d", (seconds % 3600) / 60)):\(String(format: "%02d", (seconds % 3600) % 60))"
    }
    
    func SetOptionView(otpStr:String) -> UIView{
       /* let color =  UIColor.white//Apps.BASIC_COLOR
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        lbl.text = otpStr.uppercased()
        lbl.textAlignment = .center
        lbl.textColor = .white //Apps.BASIC_COLOR //.black
        
        let imgView = UIView(frame: CGRect(x: 3, y: 3, width: 35, height: 35))
        imgView.layer.cornerRadius = 4
        imgView.layer.borderColor = color.cgColor
        imgView.layer.borderWidth = 2
       
        imgView.addSubview(lbl)
        return imgView*/
        
        let widthHeight: CGFloat = (deviceStoryBoard == "Ipad") ? 45 : 35
        let color = Apps.BLUE_COLOR //Apps.BASIC_COLOR // UIColor.white//
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: widthHeight, height: widthHeight))
        lbl.text = otpStr.uppercased()
        lbl.textAlignment = .center
        lbl.textColor = Apps.BLUE_COLOR// Apps.BASIC_COLOR //.black //.white
        let imgView = UIView(frame: CGRect(x: 0, y: 0, width: widthHeight, height: widthHeight))
        imgView.roundCorners(corners: [.topLeft,.bottomRight], radius: 11)
        imgView.clipsToBounds = true
        imgView.contentMode = .topLeft
        imgView.backgroundColor = .clear
//        imgView.layer.cornerRadius = 11//4
        imgView.layer.borderColor = color.cgColor
        imgView.layer.borderWidth = 1//2
       
        imgView.addSubview(lbl)
        return imgView
    }
        
    
    func SetClickedOptionView(otpStr:String) -> UIView{
      /*  let color = Apps.BASIC_COLOR //UIColor.white //
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        lbl.text = otpStr.uppercased()
        lbl.textAlignment = .center
        lbl.textColor = .white //Apps.BASIC_COLOR
        let imgView = UIView(frame: CGRect(x: 3, y: 3, width: 35, height: 35))
        imgView.layer.cornerRadius = 4
        imgView.layer.borderColor = color.cgColor
        imgView.layer.borderWidth = 1
        imgView.backgroundColor = color
        imgView.addSubview(lbl)
        return imgView*/
        let widthHeight: CGFloat = (deviceStoryBoard == "Ipad") ? 45 : 35
        let color = Apps.BLUE_COLOR//BASIC_COLOR //UIColor.white
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: widthHeight, height: widthHeight))
        lbl.text = otpStr.uppercased()
        lbl.textAlignment = .center
        lbl.textColor = .white //Apps.BASIC_COLOR
        let imgView = UIView(frame: CGRect(x: 0, y: 0, width: widthHeight, height: widthHeight))//UIView(frame: CGRect(x: 3, y: 3, width: widthHeight, height: widthHeight))
        imgView.roundCorners(corners: [.topLeft,.bottomRight], radius: 11)
        imgView.clipsToBounds = true
        imgView.contentMode = .topLeft
//        imgView.layer.cornerRadius = 4
//        imgView.layer.borderColor = color.cgColor
//        imgView.layer.borderWidth = 1
        imgView.backgroundColor = color
        imgView.addSubview(lbl)
        return imgView
    }
    
    
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.windows.first!.rootViewController //keyWindow?
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        return topMostViewController
    }
    
    func SetBookmark(quesID:String, status:String, completion:@escaping ()->Void){
         if isKeyPresentInUserDefaults(key: "user"){
             let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
             if(Reachability.isConnectedToNetwork()){
                 let apiURL = "user_id=\(user.userID)&question_id=\(quesID)&status=\(status)"
                self.getAPIData(apiName: Apps.API_BOOKMARK_SET, apiURL: apiURL,completion: {jsonObj in
                     //print("SET BOOK",jsonObj)
                    if (jsonObj.value(forKey: "data") as? [String:Any]) != nil {//if let data = jsonObj.value(forKey: "data") as? [String:Any] {
                         DispatchQueue.main.async {
                             completion()
                         }
                     }
                 })
             }
         }
     }
    
  /*  //add child ViewController
    func displayContentController(content: UIViewController) {
        addChild(content)
        self.view.addSubview(content.view)
        content.didMove(toParent: self)
    }
    
    //remove child viewController
    func hideContentController(content: UIViewController) {
        content.willMove(toParent: nil)
        content.view.removeFromSuperview()
        content.removeFromParent()
    } */
    
    func addTransition(){
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn) //easeOut //easeInEaseOut
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromLeft
        self.navigationController?.view.layer.add(transition, forKey: nil)
    }
    func addPopTransition(){
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut) //easeOut //easeInEaseOut
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        self.navigationController?.view.layer.add(transition, forKey: nil)
    }
    func signUpToLoginTransition(){
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        transition.type = CATransitionType.moveIn //.reveal
        transition.subtype = CATransitionSubtype.fromRight
        self.navigationController?.view.layer.add(transition, forKey: nil)
    }
    func SkipBtnTransition(){
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade //moveIn
        transition.subtype = CATransitionSubtype.fromBottom //fromRight
        self.navigationController?.view.layer.add(transition, forKey: nil)
    }
}

extension CALayer {
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }
        border.backgroundColor = color.cgColor;
        addSublayer(border)
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
//    var htmlToString: String {
//        return htmlToAttributedString?.string ?? ""
//    }
    var isInt: Bool {
        return Int(self) != nil
    }
    var characterArray: [Character]{
        var characterArray = [Character]()
        for character in self {
            characterArray.append(character)
        }
        return characterArray
    }
}
//battle modes
extension UITextField{
   /* func bordredTextfield(textField: UITextField){
        textField.layer.borderWidth = 1
        textField.layer.borderColor = Apps.GRAY_CGCOLOR
        textField.layer.cornerRadius = 5
        textField.backgroundColor = UIColor.white
    } */
    
   /* func PaddingLeft(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    } */
   /* func PaddingRight(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    } */
    
   /* func bottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    } */
    
   /* func AddAccessoryView(){
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = Apps.BASIC_COLOR
        toolBar.backgroundColor = .white
        toolBar.barTintColor = .white
        toolBar.sizeToFit()
        toolBar.addTopBorderWithColor(color: Apps.BASIC_COLOR, width: 1)
        
        let doneButton = UIBarButtonItem(title: Apps.DONE, style: UIBarButtonItem.Style.done, target: self, action: #selector(self.DismisPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Apps.CANCEL, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.DismisPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.inputAccessoryView = toolBar
    } */
   /* @objc func DismisPicker(){
        self.resignFirstResponder()
    } */
    // set icon of 20x20 with left padding of 8px
     func setLeftIcon(_ icon: UIImage) {
        let padding = 15//8
        let size = 20
        let additionalSpace = (deviceStoryBoard ==  "Ipad") ? 10 : 5
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding+additionalSpace, height: size)) // +5/10 for padding after image
        let iconView  = UIImageView(frame: CGRect(x: padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)
        leftView = outerView
        leftViewMode = .always
      }
    func setLeftPadding() {
       let padding = 15//8
       let outerView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: 20))
       leftView = outerView
       leftViewMode = .always
     }
}
