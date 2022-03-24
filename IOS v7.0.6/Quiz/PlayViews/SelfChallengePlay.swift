import Foundation
import UIKit
import AVFoundation

class SelfChallengePlay: UIViewController, UIScrollViewDelegate  {
    
    @IBOutlet weak var titleBar: UILabel!
    @IBOutlet var lblQuestion: UITextView!
    @IBOutlet var question: UITextView!
    
    @IBOutlet var btnA: UIButton!
    @IBOutlet var btnB: UIButton!
    @IBOutlet var btnC: UIButton!
    @IBOutlet var btnD: UIButton!
    @IBOutlet var btnE: UIButton!
        
    //@IBOutlet weak var bookmarkBtn: UIButton!
    
    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet var mainQuestionView: UIView!
    @IBOutlet var speakBtn: UIButton!
    @IBOutlet var zoomBtn: UIButton!
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var zoomScroll: UIScrollView!
    @IBOutlet var view1: UIView!
    
    @IBOutlet var leftView: UIView!
    @IBOutlet var centerView: UIView!
    @IBOutlet var rightView: UIView!
    @IBOutlet var secondChildView: UIView!
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var questionView: UIView!
    
    var seconds = 0
    var score: Int = 0
    
    var timer: Timer!
    var player: AVAudioPlayer?
    
    // Is an ad being loaded.
    var adRequestInProgress = false
    
    var falseCount = 0
    var trueCount = 0
    
    @IBOutlet weak var mainQuesCount: UILabel!
    
    @IBOutlet var verticalView: UIView!
    
    var jsonObj : NSDictionary = NSDictionary()
    var quesData: [QuestionWithE] = []
    var reviewQues:[ReQuestionWithE] = []
    var BookQuesList:[QuestionWithE] = []
    
    var currentQuestionPos = 0
   
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    
    var level = 0
    var catID = 0
    var questionType = "sub"
    var zoomScale:CGFloat = 1
    
    var opt_ft = false
    var opt_sk = false
    var opt_au = false
    var opt_re = false
    
    var callLifeLine = ""
    let speechSynthesizer = AVSpeechSynthesizer()
    var quizPlayTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //lblQuestion.backgroundColor = .white
        if Apps.opt_E == true {
            btnE.isHidden = false
            buttons = [btnA,btnB,btnC,btnD,btnE]
        }else{
            btnE.isHidden = true
            buttons = [btnA,btnB,btnC,btnD]
        }
       // view1.SetShadow()
        //Google AdMob
//        rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()
//        rewardBasedVideo!.delegate = self
         if Apps.opt_E == true {
            DesignOptionButton(buttons: btnA,btnB,btnC,btnD,btnE)
         }else{
            DesignOptionButton(buttons: btnA,btnB,btnC,btnD)
        }
        bottomView.SetShadow()
        rightView.layer.addBorder(edge: .left, color: UIColor.black , thickness: 2) //Apps.BASIC_COLOR
        leftView.layer.addBorder(edge: .right, color: UIColor.black, thickness: 2) //Apps.BASIC_COLOR
        
//        btnA.setImage(SetOptionView(otpStr: "A").createImage(), for: .normal)
//        btnB.setImage(SetOptionView(otpStr: "B").createImage(), for: .normal)
//        btnC.setImage(SetOptionView(otpStr: "C").createImage(), for: .normal)
//        btnD.setImage(SetOptionView(otpStr: "D").createImage(), for: .normal)
//        btnE.setImage(SetOptionView(otpStr: "E").createImage(), for: .normal)
        /* btnA.addSubview(SetClickedOptionView(otpStr: "A"))
        btnA.layer.masksToBounds = true
        btnB.addSubview(SetClickedOptionView(otpStr: "B"))
        btnB.layer.masksToBounds = true
        btnC.addSubview(SetClickedOptionView(otpStr: "C"))
        btnC.layer.masksToBounds = true
        btnD.addSubview(SetClickedOptionView(otpStr: "D"))
        btnD.layer.masksToBounds = true
        btnE.addSubview(SetClickedOptionView(otpStr: "E"))
        btnE.layer.masksToBounds = true */
        
//        self.topView.addBottomBorderWithColor(color: .gray, width: 1)
        //font
        resizeTextview()
      
        //get bookmark list
        if (UserDefaults.standard.value(forKey: "booklist") != nil){
            BookQuesList = try! PropertyListDecoder().decode([QuestionWithE].self, from:((UserDefaults.standard.value(forKey: "booklist") as? Data)!))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayQuizView.ReloadFont), name: NSNotification.Name(rawValue: "ReloadFont"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayQuizView.ResumeTimer), name: NSNotification.Name(rawValue: "ResumeTimer"), object: nil)

        zoomScroll.minimumZoomScale = 1.0
        zoomScroll.maximumZoomScale = 6.0
        
      //  setGradientBackground()
    
//        self.mainQuestionView.DesignViewWithShadow()
        self.questionView.DesignViewWithShadow()
        
        quesData.shuffle()
        seconds = self.quizPlayTime * 60
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
        
        for ques in self.quesData{
            self.reviewQues.append(ReQuestionWithE.init(id: ques.id, question: ques.question, optionA: ques.optionA, optionB: ques.optionB, optionC: ques.optionC, optionD: ques.optionD, optionE:ques.optionE, correctAns: ques.correctAns, image: ques.image, level: ques.level, note: ques.note, quesType: ques.quesType, userSelect: ""))
        }
        self.loadQuestion()
    }
    
    
   /* var btnY = 0
    func SetButtonHeight(buttons:UIButton...){
        
        var minHeight = 50
        if UIDevice.current.userInterfaceIdiom == .pad{
            minHeight = 90
        }else{
            minHeight = 50
        }
        self.scroll.setContentOffset(.zero, animated: true)
        
        let perButtonChar = 35
        btnY = Int(self.secondChildView.frame.height + self.secondChildView.frame.origin.y + 10)
        
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
    } */
  
    
    @objc func ReloadFont(noti: NSNotification){
        resizeTextview()
    }
    func resizeTextview(){
        
        var getFont = UserDefaults.standard.float(forKey: "fontSize")
        if (getFont == 0){
            getFont = (deviceStoryBoard == "Ipad") ? 28 : 18
        }
        lblQuestion.font = lblQuestion.font?.withSize(CGFloat(getFont))
        question.font = question.font?.withSize(CGFloat(getFont))
        
        lblQuestion.centerVertically()
        question.centerVertically()
        
        btnA.titleLabel?.font = btnA.titleLabel?.font?.withSize(CGFloat(getFont))
        btnB.titleLabel?.font = btnB.titleLabel?.font?.withSize(CGFloat(getFont))
        btnC.titleLabel?.font = btnC.titleLabel?.font?.withSize(CGFloat(getFont))
        btnD.titleLabel?.font = btnD.titleLabel?.font?.withSize(CGFloat(getFont))
        btnE.titleLabel?.font = btnE.titleLabel?.font?.withSize(CGFloat(getFont))
        
        btnA.resizeButton()
        btnB.resizeButton()
        btnC.resizeButton()
        btnD.resizeButton()
        btnE.resizeButton()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return questionImage
    }

    // resume timer when setting alert closed
    @objc func ResumeTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    // Note only works when time has not been invalidated yet
    @objc func resetProgressCount() {
        buttons.forEach{$0.isUserInteractionEnabled = true}
        
        zoomScale = 1
        zoomScroll.zoomScale = 1
        
    }
    
    @objc func incrementCount() {
        self.timerLabel.text = self.secondsToHoursMinutesSeconds(seconds: seconds) //String(format: "%02d", seconds)
        seconds -= 1
        if seconds < 0 {
            self.ShowResultScreen()
        }
    }
    
    @IBAction func settingButton(_ sender: Any) {
//        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
//        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier:"SettingsAlert") as! SettingsAlert
        myAlert.modalPresentationStyle = .overCurrentContext
        myAlert.isPlayView = true
        self.present(myAlert, animated: true, completion: {
             self.timer.invalidate()
        })
    }
    
    @IBAction func backButton(_ sender: Any) {
        let alert = UIAlertController(title: Apps.LEAVE_MSG ,message: Apps.BACK_MSG,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            if self.timer.isValid{
                self.timer.invalidate()
            }
            self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!)
            self.addPopTransition()
            self.navigationController?.popViewController(animated: false)
//            self.navigationController?.popViewController(animated: true)
        }))
        alert.view.tintColor = (Apps.APPEARANCE == "dark") ? UIColor.white : UIColor.black //UIColor.black  // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func speakButton(_ sender: Any) {
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: "\(quesData[currentQuestionPos].question)")
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
        speechUtterance.voice = AVSpeechSynthesisVoice(language: Apps.LANG)
        speechSynthesizer.speak(speechUtterance)
    }
    
    @IBAction func zoomBtn(_ sender: Any) {
        if zoomScroll.zoomScale == zoomScroll.maximumZoomScale {
                   zoomScale = 0
               }
        zoomScale += 1
        zoomScroll.zoomScale = zoomScale
    }
    
//    @IBAction func BookMark(_ sender: Any) {
//
//        if(self.bookmarkBtn.tag == 0){
//            let reQues = quesData[currentQuestionPos]
//            self.BookQuesList.append(QuestionWithE.init(id: reQues.id, question: reQues.question, optionA: reQues.optionA, optionB: reQues.optionB, optionC: reQues.optionC, optionD: reQues.optionD, optionE: reQues.optionE, correctAns: reQues.correctAns, image: reQues.image, level: reQues.level, note: reQues.note, quesType: reQues.quesType))
//            bookmarkBtn.setBackgroundImage(UIImage(named: "book-on"), for: .normal)
//            bookmarkBtn.tag = 1
//            self.SetBookmark(quesID: reQues.id, status: "1", completion: {})
//        }else{
//            let reQues = quesData[currentQuestionPos]
//            BookQuesList.removeAll(where: {$0.id == quesData[currentQuestionPos].id && $0.correctAns == quesData[currentQuestionPos].correctAns})
//            bookmarkBtn.setBackgroundImage(UIImage(named: "book-off"), for: .normal)
//            bookmarkBtn.tag = 0
//            self.SetBookmark(quesID: reQues.id, status: "0", completion: {})
//        }
//
//        UserDefaults.standard.set(try? PropertyListEncoder().encode(BookQuesList), forKey: "booklist")
//
//    }
    
    func clearColor(views:UIView...){
        
        //let singleQues = quesData[currentQuestionPos]
//        if singleQues.quesType == "2"{
//            btnA.setImage(SetOptionView(otpStr: "o").createImage(), for: .normal)
//            btnB.setImage(SetOptionView(otpStr: "o").createImage(), for: .normal)
//        }else{
          /*  btnA.setImage(SetOptionView(otpStr: "A").createImage(), for: .normal)
            btnB.setImage(SetOptionView(otpStr: "B").createImage(), for: .normal)
            btnC.setImage(SetOptionView(otpStr: "C").createImage(), for: .normal)
            btnD.setImage(SetOptionView(otpStr: "D").createImage(), for: .normal)
            btnE.setImage(SetOptionView(otpStr: "E").createImage(), for: .normal) */
            btnA.addSubview(SetClickedOptionView(otpStr: "A"))
            btnA.layer.masksToBounds = true
            btnB.addSubview(SetClickedOptionView(otpStr: "B"))
            btnB.layer.masksToBounds = true
            btnC.addSubview(SetClickedOptionView(otpStr: "C"))
            btnC.layer.masksToBounds = true
            btnD.addSubview(SetClickedOptionView(otpStr: "D"))
            btnD.layer.masksToBounds = true
            btnE.addSubview(SetClickedOptionView(otpStr: "E"))
            btnE.layer.masksToBounds = true
//        }
      
        for view in views{
            view.isHidden = false
            view.backgroundColor = UIColor.white//UIColor.white.withAlphaComponent(0.8)// Apps.BASIC_COLOR //
//            view.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
        }
    }
    
    
    @IBAction func SubmitForResult(_ sender: Any) {
        let alert = UIAlertController(title: Apps.SUBMIT_TEST,message: "",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            self.ShowResultScreen()
        }))
        
        alert.view.tintColor = (Apps.APPEARANCE == "dark") ? UIColor.white : UIColor.black //UIColor.black  // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func PrevBtn(_ sender: Any) {
        self.currentQuestionPos -= 1
        if self.currentQuestionPos >= 0{
            self.loadQuestion()
        }else{
            self.currentQuestionPos = 0
        }
    }
   
    @IBAction func ShowAttemp(_ sender: Any){
//        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier: "SelfAttempAlertView") as! SelfAttempAlertView
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        myAlert.bottomAlertData  = self.bottomAlertData
        myAlert.noOfQues = self.quesData.count
        self.present(myAlert, animated: true, completion: nil)
    }
  
    
    @IBAction func NextBtn(_ sender: Any) {
           
        self.currentQuestionPos += 1
        if self.currentQuestionPos < self.quesData.count{
            self.loadQuestion()
        }else{
            self.currentQuestionPos = self.quesData.count - 1
        }
    }
    // set question vcalue and its answer here
    @objc func loadQuestion() {
        // Show next question
        
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!)
        resetProgressCount() // reset timer
//        if Apps.opt_E == true {
//            clearColor(views: btnA,btnB,btnC,btnD,btnE)
//            // enabled options button
//            MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD,btnE)
//        }else{
//            clearColor(views: btnA,btnB,btnC,btnD)
//            // enabled options button
//            MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD)
//        }
        if(currentQuestionPos  < quesData.count ) {
            if(quesData[currentQuestionPos].image == ""){
                // if question dose not contain images
                question.text = quesData[currentQuestionPos].question
//                question.stringFormation(quesData[currentQuestionPos].question)
                question.centerVertically()
                //hide some components
                lblQuestion.isHidden = true
                questionImage.isHidden = true
               // zoomBtn.isHidden = true
                question.isHidden = false
            }else{
                // if question has image
                lblQuestion.text = quesData[currentQuestionPos].question
//                lblQuestion.stringFormation(quesData[currentQuestionPos].question)
                lblQuestion.centerVertically()
                questionImage.loadImageUsingCache(withUrl: quesData[currentQuestionPos].image)
                questionImage.layer.cornerRadius = 11
                //show some components
                lblQuestion.isHidden = false
                questionImage.isHidden = false
             //   zoomBtn.isHidden = false
                question.isHidden = true
            }
         if(quesData[currentQuestionPos].optionE == "")
         {
             Apps.opt_E = false
         }else{
             Apps.opt_E = true
         }
         if Apps.opt_E == true {
             clearColor(views: btnA,btnB,btnC,btnD,btnE)
             btnE.isHidden = false
             buttons = [btnA,btnB,btnC,btnD,btnE]
             DesignOptionButton(buttons: btnA,btnB,btnC,btnD,btnE)
//             self.SetViewWithShadow(views: btnA,btnB, btnC, btnD, btnE)
             // enabled options button
             MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD,btnE)
         }else{
             clearColor(views: btnA,btnB,btnC,btnD)
             btnE.isHidden = true
             buttons = [btnA,btnB,btnC,btnD]
             DesignOptionButton(buttons: btnA,btnB,btnC,btnD)
//             self.SetViewWithShadow(views: btnA,btnB, btnC, btnD)
             // enabled options button
             MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD)
         }            
           self.SetButtonOption(options: quesData[currentQuestionPos].optionA,quesData[currentQuestionPos].optionB,quesData[currentQuestionPos].optionC,quesData[currentQuestionPos].optionD,quesData[currentQuestionPos].optionE,quesData[currentQuestionPos].correctAns)
           // mainQuesCount.roundCorners(corners: [ .bottomRight], radius: 5)
            mainQuesCount.text = "\(currentQuestionPos + 1) / \(Apps.TOTAL_PLAY_QS)" //"\(currentQuestionPos + 1)"
//            //check current question is in bookmark list or not
//            if(BookQuesList.contains(where: {$0.id == quesData[currentQuestionPos].id && $0.correctAns == quesData[currentQuestionPos].correctAns})){
//                self.bookmarkBtn.setBackgroundImage(UIImage(named: "book-on"), for: .normal)
//                self.bookmarkBtn.tag = 1
//            }else{
//                self.bookmarkBtn.setBackgroundImage(UIImage(named: "book-off"), for: .normal)
//                self.bookmarkBtn.tag = 0
//            }
        } else {
            //self.ShowResultScreen()
        }
    }
    
    func ShowResultScreen(){
        timer.invalidate()
        if self.quesData.count != self.reviewQues.count{
            for ques in self.quesData{
                if self.reviewQues.contains(where: {$0.id == ques.id}){
                }else{
                    self.reviewQues.append(ReQuestionWithE.init(id: ques.id, question: ques.question, optionA: ques.optionA, optionB: ques.optionB, optionC: ques.optionC, optionD: ques.optionD, optionE:ques.optionE, correctAns: ques.correctAns, image: ques.image, level: ques.level, note: ques.note, quesType: ques.quesType, userSelect: ""))
                }
            }
        }
        // If there are no more questions show the results
        let storyBoard:UIStoryboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let resultView = storyBoard.instantiateViewController(withIdentifier: "SelfPlayResultView") as! SelfPlayResultView
        
        resultView.totalTime = self.quizPlayTime * 60
        resultView.completedTime = self.seconds
        resultView.quesCount = self.quesData.count
        resultView.ReviewQues = self.reviewQues
        self.addTransition()
        self.navigationController?.pushViewController(resultView, animated: false)
//        self.navigationController?.pushViewController(resultView, animated: true)
    }
    // set button option's
    var buttons:[UIButton] = []
    func SetButtonOption(options:String...){
        clickedButton.removeAll()
        var temp : [String]
        if options.contains("") {
             print("true - \(options)")
             temp = ["a","b","c","d"]
             self.buttons = [btnA,btnB,btnC,btnD]
         }else{
               print("false - \(options)")
               temp = ["a","b","c","d","e"]
               self.buttons = [btnA,btnB,btnC,btnD,btnE]
         }
//        if Apps.opt_E == true {
//             temp = ["a","b","c","d","e"]
//        }else{
//             temp = ["a","b","c","d"]
//        }
       let ans = temp
        if ans.contains("\(options.last!.lowercased())") { //last is answer here
        }else{
            self.ShowAlert(title: Apps.INVALID_QUE, message: Apps.INVALID_QUE_MSG)
        }
      let singleQues = quesData[currentQuestionPos]
       if singleQues.quesType == "2"{
           
           clearColor(views: btnA,btnB)
           MakeChoiceBtnDefault(btns: btnA,btnB)
           
           btnC.isHidden = true
           btnD.isHidden = true

           self.buttons = [btnA,btnB]
           //btnE.isHidden = true
            temp = ["a","b"]
         /*  self.buttons.forEach{
               // $0.setImage(SetOptionView(otpStr: "o").createImage(), for: .normal)
//                  $0.setImage(SetOptionView(otpStr: ($0.accessibilityLabel?.uppercased())!).createImage(), for: .normal)
               $0.addSubview(SetClickedOptionView(otpStr: ($0.accessibilityLabel?.uppercased())!))
           } */
       }else{
           btnC.isHidden = false
           btnD.isHidden = false
       }
        var index = 0
        var userSelectedAns = ""
        if  let tm = self.reviewQues.first(where: {$0.id == self.quesData[self.currentQuestionPos].id}){
            userSelectedAns = tm.userSelect
        }
        
        var i = 0
        for button in buttons{
            if userSelectedAns != "" && userSelectedAns == options[index]{
//                if singleQues.quesType == "2"{
//                    button.setImage(SetClickedOptionView(otpStr: "o").createImage(), for: .normal)
//                }else{
               // button.addSubview(SetClickedOptionView(otpStr: temp[i]))
               // button.layer.masksToBounds = true
                button.setOptionBorder()
                i += 1
                   // button.setImage(SetClickedOptionView(otpStr: temp[index]).createImage(), for: .normal)
//                }
            }else{
                button.layer.borderWidth = 0 //remove border from others
                i += 1
            }
            button.setTitle(options[index], for: .normal)
            button.addTarget(self, action: #selector(ClickButton), for: .touchUpInside)
            button.addTarget(self, action: #selector(ButtonDown), for: .touchDown)
            index += 1
        }
        SetButtonHeight(buttons:btnA,btnB,btnC,btnD,btnE,view:secondChildView,scroll:scroll)//self.SetButtonHeight(buttons: btnA,btnB,btnC,btnD,btnE)
    }
    
    // option buttons click action
    var bottomAlertData:[Int] = []
    @objc func ClickButton(button:UIButton){
        
        self.PlaySound(player: &audioPlayer, file: "click") // play sound "selfClick"
        self.Vibrate() // make device vibrate
        
        //let singleQues = quesData[currentQuestionPos]
        
        buttons.forEach{
            $0.isUserInteractionEnabled = false
//            if singleQues.quesType == "2"{
//                $0.setImage(SetOptionView(otpStr: "o").createImage(), for: .normal)
//            }else{
               // $0.setImage(SetOptionView(otpStr: ($0.accessibilityLabel?.uppercased())!).createImage(), for: .normal)
            $0.addSubview(SetClickedOptionView(otpStr:($0.accessibilityLabel?.uppercased())!))
            $0.layer.masksToBounds = true
//            }
            $0.layer.borderWidth = 0
        }
//        if singleQues.quesType == "2"{
//            button.setImage(self.SetClickedOptionView(otpStr: "o").createImage(), for: .normal)
//        }else{
            //button.setImage(self.SetClickedOptionView(otpStr: (button.accessibilityLabel?.uppercased())!).createImage(), for: .normal)
//        button.addSubview(SetClickedOptionView(otpStr:(button.accessibilityLabel?.uppercased())!))
//        button.layer.masksToBounds = true
        //set border for Selected Button
        button.setOptionBorder()
//        }
      
        if clickedButton.first?.title(for: .normal) == button.title(for: .normal){
            if button.tag == 1{
               // rightAnswer(btn: button)
            }else{
               // wrongAnswer(btn: button)
            }
            AddToReview(opt: button.title(for: .normal)!)
            if !self.bottomAlertData.contains(self.currentQuestionPos + 1){
                self.bottomAlertData.append(self.currentQuestionPos + 1)
            }
        }
        
        buttons.forEach{
            $0.isUserInteractionEnabled = true
        }
    }
    
    var clickedButton:[UIButton] = []
    @objc func ButtonDown(button:UIButton){
        clickedButton.append(button)
    }
    
    // set default to four choice button
    func MakeChoiceBtnDefault(btns:UIButton...){
        for btn in btns {
            btn.isEnabled = true
            btn.resizeButton()
            btn.subviews.forEach({
                if($0.tag == 11){
                    $0.removeFromSuperview()
                }
                //find if there is any circular progress on option button and remove it
                for calayer in (btn.layer.sublayers)!{
                    if calayer.name == "circle" {
                        calayer.removeFromSuperlayer()
                    }
                }
            })
        }
    }
    
    // Set the background as gradient
   /* func setGradientBackground() {
        let colorTop =  Apps.BG1_CGCOLOR
        let colorBottom = UIColor.white.cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop, colorBottom]
        gradientLayer.locations = [ 0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    } */
    
    // add question to review array for later review it
    func AddToReview(opt:String){
        if  var tm = self.reviewQues.first(where: {$0.id == self.quesData[self.currentQuestionPos].id}){
            let index = self.reviewQues.firstIndex(where: {$0.id == tm.id})
            tm.userSelect = opt
            self.reviewQues[index!] = tm
            return
        }
        let ques = quesData[currentQuestionPos]
        reviewQues.append(ReQuestionWithE.init(id: ques.id, question: ques.question, optionA: ques.optionA, optionB: ques.optionB, optionC: ques.optionC, optionD: ques.optionD, optionE:ques.optionE, correctAns: ques.correctAns, image: ques.image, level: ques.level, note: ques.note, quesType: ques.quesType, userSelect: opt))
    }
}

