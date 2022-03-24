import UIKit
import StoreKit
import AVFoundation

class SettingsAlert: UIViewController {
    
    @IBOutlet weak var trayView: UIView!
    
    @IBOutlet weak var soundView: UIView!
    @IBOutlet weak var vibrationView: UIView!
    @IBOutlet weak var bgMusicView: UIView!
    @IBOutlet weak var fontSizeView: UIView!
    @IBOutlet weak var rateUsView: UIView!
    @IBOutlet weak var shareAppView: UIView!
    @IBOutlet weak var moreAppsView: UIView!
    @IBOutlet weak var saveSettingsBtn: UIButton!
    
    @IBOutlet var soundToggle: UISwitch!
    @IBOutlet var vibToggle: UISwitch!
    @IBOutlet var musicToggle: UISwitch!
    
    var soundEnabled = true
    var vibEnabled = true
    var isPlayView = false
    var isMathsQuiz = false
    
    let step:Float=10
    var backgroundMusicPlayer: AVAudioPlayer!
    var parentName = "" //battle modes
    var setting:Setting? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get setting value from user default
        setting = try! PropertyListDecoder().decode(Setting.self, from: (UserDefaults.standard.value(forKey:"setting") as? Data)!)
        soundToggle.isOn = setting!.sound
        vibToggle.isOn = setting!.vibration
        musicToggle.isOn = setting!.backMusic
        
        trayView.alpha = 0
        soundView.roundCorners(corners: [.topLeft,.topRight], radius: 15)
        moreAppsView.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 15)
        saveSettingsBtn.layer.cornerRadius = 15
        trayView.roundCorners(corners: [.topLeft,.topRight,.bottomLeft,.bottomRight], radius: 15)
        showTray(self) //show tray with transition
    }
    @IBAction func showTray(_ sender: Any) {
        if trayView.alpha == 0 {
            let anim = animateView(.fromTop)
            trayView.layer.add(anim, forKey: "CATransition")
            trayView.alpha = 1
        }
    }
    @IBAction func soundSwitch(sender: AnyObject) {
        setting?.sound = soundToggle.isOn
    }
    
    @IBAction func vibSwitch(sender: AnyObject) {
        setting?.vibration = vibToggle.isOn
    }
    
    @IBAction func musicSwitch(sender: AnyObject) {
        setting?.backMusic = musicToggle.isOn
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
       // Font size slider
    @IBAction func sliderButton(_ sender: AnyObject) {
        //get the Slider values from UserDefaults
        let defaultSliderValue = UserDefaults.standard.float(forKey: "fontSize")*3
        
        //create the Alert message with extra return spaces
        let sliderAlert = UIAlertController(title:Apps.FONT_TITLE, message: Apps.FONT_MSG, preferredStyle: .alert)
        
        //create a Slider and fit within the extra message spaces
        let mySlider = UISlider(frame:CGRect(x: 10, y: 100, width: 250, height: 20))
        
        mySlider.minimumValue = 40
        mySlider.maximumValue = 100
        mySlider.isContinuous = true
        mySlider.tintColor = UIColor.green
        mySlider.setValue(defaultSliderValue, animated:true)
        mySlider.addTarget(self, action: #selector(SettingsAlert.sliderValueDidChange(_:)), for: .valueChanged)
        
        sliderAlert.view.addSubview(mySlider)
        //OK button action
        let sliderAction = UIAlertAction(title: Apps.OK, style: .default, handler: { (result : UIAlertAction) -> Void in
            UserDefaults.standard.set(mySlider.value/4, forKey: "fontSize")
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadFont"), object: nil)
        })
        //Add buttons to sliderAlert
        sliderAlert.addAction(sliderAction)
        //present the sliderAlert message
        self.present(sliderAlert, animated: true, completion: nil)
    }
    
    @objc func sliderValueDidChange(_ sender:UISlider!)
    {
        // Use this code below only if you want UISlider to snap to values step by step
        let roundedStepValue = round(sender.value / step) * step
        sender.value = roundedStepValue
        
        let i = CGFloat(roundedStepValue)/3
        
        UserDefaults.standard.set(i, forKey: "size")
    }
    @IBAction func RateUsBtn(_ sender: Any) {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }else if let url = URL(string: Apps.SHARE_APP){
            UIApplication.shared.canOpenURL(url)
        }
    }
    @IBAction func ShareBtn(_ sender: Any) {
        // let str  = Apps.APP_NAME
        let str = Apps.SHARE_APP_TXT
        let shareUrl = Apps.SHARE_APP
        let textToShare = str + "\n" + shareUrl
        let vc = UIActivityViewController(activityItems: [textToShare], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = sender as? UIView //working on iPad
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func MoreAppsBtn(_ sender: Any) {
       
        let url = NSURL(string: Apps.MORE_APP)
        UIApplication.shared.open(url! as URL)
    }
    @IBAction func saveSettings(_ sender: Any) {
        if setting!.backMusic {
            NotificationCenter.default.post(name: Notification.Name("PlayMusic"), object: nil)
        }else{
            NotificationCenter.default.post(name: Notification.Name("StopMusic"), object: nil)
        }
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.setting), forKey: "setting")
        
        //font size
        let size = UserDefaults.standard.integer(forKey: "size")
        UserDefaults.standard.set(size, forKey: "fontSize")
        
        self.dismiss(animated: true, completion: {
            if self.isPlayView{
                NotificationCenter.default.post(name: Notification.Name("ResumeTimer"), object: nil)
            }
        })
        //show animation back before hiding TrayView
        let anim = animateView(.fromBottom)
        trayView.layer.add(anim, forKey: "CATransition")
        trayView.alpha = 0
        self.dismiss(animated: true, completion: nil)
        //save all preferences & settings
    }
    func animateView(_ type: CATransitionSubtype) -> CATransition{
        let animationS:CATransition = CATransition()
        animationS.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        animationS.type = CATransitionType.push
        animationS.subtype = type 
        animationS.duration = 0.50
        return animationS
    }
}
