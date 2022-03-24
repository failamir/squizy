import Foundation
import UIKit
import AVFoundation

//apps setting and default value will be store here and used everywhere
struct Apps{
    static var URL = "http://quizdemo.wrteam.in/api-v2.php"
    static var ACCESS_KEY = "6808"
    
    static let JWT = "set_your_strong_jwt_secret_key"
    
    // MARK: - set values
    static let QUIZ_PLAY_TIME:CGFloat = 25 // set timer value for play quiz
    static let GROUP_BTL_WAIT_TIME:Int = 180//30 // set timer value for players to join group battle
    static let ONETOONE_BTL_WAIT_TIME:Int = 60//60 SECONDS // set timer value for players to join group battle
       
    static let OPT_FT_COIN = 4 // how many coins will be deduct when we use 50-50 lifeline?
    static let OPT_SK_COIN = 4 // how many coins will be deduct when we use SKIP lifeline?
    static let OPT_AU_COIN = 4 // how many coins will be deduct when we use AUDIENCE POLL lifeline?
    static let OPT_RES_COIN = 4 // how many coins will be deduct when we use RESET TIMER lifeline?
    
    static let QUIZ_R_Q_POINTS = 4 // how many points will user get when he select right answer in play area
    static let QUIZ_W_Q_POINTS = 2 // how many points will deduct when user select wrong answer in play area
    static let CONTEST_RIGHT_POINTS = 3 // how many points will user get when he select right answer in Contest
    
    static var REWARD_COIN = "4" //used to add coins to user coins when user watch reward video ad
    
    static var BANNER_AD_UNIT_ID = "ca-app-pub-3940256099942544/2934735716"//"ca-app-pub-9494734299483429/5838705416" //FB ID: "2730369673887525_2730627390528420"
    static var REWARD_AD_UNIT_ID = "ca-app-pub-3940256099942544/1712485313"//"ca-app-pub-9494734299483429/7263467729" //FB ID: "2730369673887525_2730633910527768"
    static var INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-3940256099942544/4411468910"//"ca-app-pub-9494734299483429/1272774440" //FB ID: "2730369673887525_2730640560527103"
    static var APP_OPEN_UNIT_ID = "ca-app-pub-3940256099942544/5662855259"
    static let AD_TEST_DEVICE = ["e61b6b6ac743a9c528bcda64b4ee77a7","8099b28d92fa3eae7101498204255467"]
    
    static var SOCIAL_YT = "https://www.youtube.com"
    static var SOCIAL_FB = "https://www.facebook.com"
    static var SOCIAL_IG = "https://www.instagram.com"
    
    static let RIGHT_ANS_COLOR = UIColor.rgb(35, 176, 75, 0.6)//1) //right answer color
    static let WRONG_ANS_COLOR = UIColor.rgb(237, 42, 42, 0.6)//1) //wrong answer color
   
    static let BASIC_COLOR = UIColor.rgb(29, 108, 186, 1.0)//(0, 194, 217, 1.0)//(57, 129, 156, 1.0)
    static let BASIC_COLOR_CGCOLOR = UIColor.rgb(29, 108, 186, 1.0).cgColor//(0, 194, 217, 1.0)//rgb(57, 129, 156, 1.0)
    static let BLUE_COLOR = UIColor.rgb(45, 131, 208, 1.0)
    
    // MARK: - other colors
    static let defaultOuterColor = Apps.BASIC_COLOR//UIColor.rgb(224, 224, 224,1)
    static let defaultInnerColor = UIColor.rgb(84,193,255,1)
    static let defaultPulseFillColor = UIColor.clear //UIColor.rgb(248, 248, 248,1)
    
    static let GRAY_CGCOLOR = UIColor.rgb(198, 198, 198, 1.0).cgColor
    static let BG1_CGCOLOR = UIColor.rgb(243, 243, 247, 1.0).cgColor
    static let WHITE_ALPHA = UIColor.rgb(255, 255, 255, 0.4)
    
    static let LEVEL_TEXTCOLOR = UIColor.rgb(168, 168, 168, 1)
    
    // MARK: - gradient Colors
    let purple1 = UIColor.rgb(158, 89, 225, 1)
    let purple2 = UIColor.rgb(241, 125, 196, 1.0)
    
    let sky1 = UIColor.rgb(67,155,210,1.0)
    let sky2 = UIColor.rgb(115,225,192,1.0)
    
    let orange1 = UIColor.rgb(227,119,67,1.0)
    let orange2 = UIColor.rgb(237,159,63,1.0)
    
    static let blue1 = UIColor.rgb(29,108,186,1.0)
    static let blue2 = UIColor.rgb(84,193,255,1.0)
    
    let pink1 = UIColor.rgb(195,15,142,1.0)
    let pink2 = UIColor.rgb(251,82,147,1.0)
    
    let green1 = UIColor.rgb(60,131,70,1.0)
    let green2 = UIColor.rgb(139,209,136,1.0)
    
    static var arrColors1 = [UIColor(named: "purple1"),UIColor(named: "sky1"),UIColor(named: "blue1"),UIColor(named: "orange1"),UIColor(named: "pink1"),UIColor(named: "green1")]
    static var arrColors2 = [UIColor(named: "purple2"),UIColor(named: "sky2"),UIColor(named: "blue2"),UIColor(named: "orange2"),UIColor(named: "pink2"),UIColor(named: "green2")]

    static var tintArr = ["purple2", "sky2","blue2","orange2","pink2","green2"] //NOTE: arrColors1 & arrColors2 & tintArr - arrays should have same values/count
        
    // MARK: - App Information - set from admin panel
    static var SHARE_APP = "https://itunes.apple.com/in/app/Quiz online App/1467888574?mt=8"
    static var MORE_APP = "itms-apps://itunes.com/apps/89C47N4UTZ"
    static var SHARE_APP_TXT = "Hello"
    static var TOTAL_PLAY_QS = 10 // how many there will be total question in quiz play
    static var TOTAL_BATTLE_QS = 10 // no_of_que for Group and OneToOne Battle
    static var FIXED_QS = 10
    static var ADV_TYPE = "ADMOB"
    
    static var ANS_MODE = "0"
    static var FORCE_UPDT_MODE = "1"
    static var CONTEST_MODE = "1"
    static var DAILY_QUIZ_MODE = "1"
    static var FIX_QUE_LVL = "0"
    static var RANDOM_BATTLE_WITH_CATEGORY = "1"
    static var GROUP_BATTLE_WITH_CATEGORY = "1"
    static var IN_APP_PURCHASE = "0"
    static var LEARNING_MODE = "1"
    static var MATHS_MODE = "1"
    static var TRUE_FALSE_MODE = "1"
    static var APP_MAINTENANCE = "0"
    
    static var screenHeight = CGFloat(0)
    static var screenWidth = CGFloat(0)
    
    // MARK: - variables to store push notification response parameters
    static var nTitle = ""
    static var nMsg = ""
    static var nImg = ""
    static var nMaxLvl = 0
    static var nMainCat = ""
    static var nSubCat = ""
    static var nType = ""
    static var badgeCount = UserDefaults.standard.integer(forKey: "badgeCount")
    
    // MARK: - APis / static values
    static let USERS_DATA = "get_user_by_id"
    static var REFER_CODE = "refer_code"
    static let FRIENDS_CODE = "friends_code"
    static let SYSTEM_CONFIG = "get_system_configurations"
    static let NOTIFICATIONS = "get_notifications"
    static let API_BOOKMARK_GET = "get_bookmark"
    static let API_BOOKMARK_SET = "set_bookmark"
    
    static var opt_E = false
    static var ALL_TIME_RANK:Any = "0"
    static var COINS = "0"
    static var SCORE: Any = "0"
    static var REFER_COIN = "0"// added to friend's coins
    static var EARN_COIN = "0" //added to user's own coins
    
    static var FCM_ID = " "
    
    static var APPEARANCE = "light"
    
    static var storyBoard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
    // MARK: - colors
    static let SKY1 = "sky1"
    static let ORANGE1 = "orange1"
    static let PURPLE1 = "purple1"
    static let GREEN1 = "green1"
    static let BLUE1 = "blue1"
    static let PINK1 = "pink1"
    
    static let SKY2 = "sky2"
    static let ORANGE2 = "orange2"
    static let PURPLE2 = "purple2"
    static let GREEN2 = "green2"
    static let BLUE2 = "blue2"
    static let PINK2 = "pink2"
    
    static let GRP_BTL = "groupbattle"
    static let ONE2ONE_BTL = "onevsone"
    static let RNDM = "random"
    static let CONTEST_IMG = "contest"
    // MARK: - Home ViewController Strings
    static let QUIZ_ZONE = "Quiz Zone"
    static let PLAY_ZONE = "Play Zone"
    static let BATTLE_ZONE = "Battle Zone"
    static let CONTEST_ZONE = "Contest Zone"
    static let IMG_QUIZ_ZONE = "quizzone"
    static let IMG_PLAYQUIZ = "playquiz"
    static let IMG_BATTLE_QUIZ = "battlequiz"
    static let IMG_CONTEST_QUIZ = "contestquiz"
    static let IMG_LEARNING_QUIZ = "learningzone"
    static let IMG_MATHS_QUIZ = "mathszone"
    
    static let LEARNING_PLAY = "Learning Play"
    static let MATHS_PLAY = "Maths Play"
    static let DAILY_QUIZ_PLAY = "Daily Quiz"
    static let RNDM_QUIZ = "Random Quiz"
    static let TRUE_FALSE = "True / False"
    static let SELF_CHLNG = "Self Challenge"
    static let PRACTICE = "Practice"
    static let LEARNING = "Learning Zone"
    static let MATHS = "Maths Zone"
    static let GROUP_BTL = "Group Battle"
    static let ONE_TO_ONE_BTL = "One Vs One Battle"
    static let RNDM_BTL = "Random Battle"
    
    static let CONTEST_PLAY_TEXT = "Contest Play"
    static let JOIN_NOW = "Join Now"
    // MARK: - strings to Translate
    static let APP_NAME = "Quiz (v7.0.6)"
    static var SHARE_MSG = "I have earned coins using this Quiz app. you can also earn coin by downloading app from below link and enter referral code while login - "
    static let NO_NOTIFICATION = "Notifications not available"
    static let COMPLETE_LEVEL = "Congratulations !! \n VICTORY"
    static let NOT_COMPLETE_LEVEL = "Better Luck next Time \n DEFEAT"
    static let PLAY_AGAIN = "Play Again"
    static let NOT_ENOUGH_QUESTION_TITLE = "Not Enough Question"
    static let NO_ENOUGH_QUESTION_MSG = "This level does not have enough question to play quiz"
    static let COMPLETE_ALL_QUESTION = "You have Completed All Questions !!"
    static let LEVET_NOT_AVAILABEL = "Level not available"
    static let STATISTICS_NOT_AVAIL = "Data not available"
    static let SKIP = "SKIP"
    static let MSG_ENOUGH_COIN = "Not Enough Coins !"
    static let NEED_COIN_MSG1 = "You don't have enough coins. You need atleast"
    static let NEED_COIN_MSG2 = "coins to use this lifeline."
    static let NEED_COIN_MSG3 = "Watch a short video & get free coins."
    static let WATCH_VIDEO = "WATCH NOW"
    static let EXIT_APP_MSG = "Do you really want to quit?"
    static let EXIT_PLAY = "Do you want to exit the Quiz?"
    static let NO_INTERNET_TITLE = "No Internet!"
    static let NO_INTERNET_MSG = "Please check you internet connection!"
    static let LEVEL_LOCK = "This level in lock for you"
    static let LOGOUT_TITLE = "LOGOUT"
    static let LOGOUT_MSG = "Are you sure!! \n You really want to log out?"
    static let REMOVE_ACC_TITLE = "Remove Your Account ⚠️"
    static let REMOVE_ACC_MSG = "\nThis Action Can't be Undone❗️\nAll your Progress and Data Will be Lost.\n Are you sure❗️\nYou really want to Remove your Account⁉️"
    static let LIFELINE_ALREDY_USED_TITLE = "Life Line"
    static let LIFELINE_ALREDY_USED = "Already use"
    static let YES = "YES"
    static let NO = "NO"
    static let DONE = "Done"
    static let OOPS = "Oops!"
    static let ROBOT = "Robot"
    static let BACK = "Back"
    static let SHOW_ANSWER = "Show Answer"
    static let LEVEL = "Level :"
    static let TRUE_ANS = "True Ans:"
    static let MATCH_DRAW = "Match Draw!"
    static let REPORT_QUESTION = "Report Question"
    static let TYPE_MSG = "Type a message"
    static let SUBMIT = "Submit"
    static let CANCEL = "Cancel"
    static let FROM_LIBRARY = "Gallery"
    static let TAKE_PHOTO = "Camera"
    static let NO_BOOKMARK = "Questions not available"
    static let LEAVE_MSG = "Are you sure , You want to leave ?"
    static let ERROR = "Error"
    static let ERROR_MSG = "Error while fetching data"
    static let MSG_NM = "Please Enter Name"
    static let MSG_ERR = "Error Creating User"
    static let PROFILE_UPDT = "Profile Update"
    static let WARNING = "Warning"
    static let WAIT = "Please wait...⏳"
    static let DISMISS = "Dismiss"
    static let OK = "OK"
    static let OKAY = "OKAY"
    static let HELLO = "Hello,"
    static let USER = "User"
    static let INVALID_QUE = "Invalid Question"
    static let INVALID_QUE_MSG = " This Question has wrong value."
    static let ENTER_MAILID = "Please enter email id."
    // MARK: - REVIEW
    static let EXTRA_NOTE = "Extra Note"
    static let UN_ATTEMPTED = "Un-Attempted"
    // MARK: - RESET PASSWORD
    static let RESET_FAILED = "Reset Failed"
    static let RESET_TITLE = "To Reset Password, Email sent successfully"
    static let RESET_MSG = "Check your mail"
    // MARK: - ALERT MSG
    static let NO_DATA_TITLE = "No Data"
    static let NO_DATA = "Data Not Found !!!"
    static let NOT_LOGGED_IN = "Please Login First"
    static let NOT_LOGGED_IN_MSG = "To make sure it's You and Not AnyOne else trying to delete your Account !"
    //remove following 2 lines incase you don't want to use Reward Ads in Your App //RemoveAds
    static let REWARD_AD_NOT_PRESENT_TITLE = "Rewarded ad isn't available yet."
    static let REWARD_AD_NOT_PRESENT_MSG = "The rewarded ad cannot be shown at this time"
    // MARK: - LOGIN ALERTS
    static let APPLE_LOGIN_TITLE =  "Not Supported"
    static let APPLE_LOGIN_MSG = "Apple sign in not supported in your device. try another sign method"
     static let VERIFY_MSG = "Please Verify Email First & Go Ahead !"
     static let VERIFY_MSG1 = "User verification email sent"
     static let CORRECT_DATA_MSG = "Please enter correct username and password"
    // MARK: - REFER CODE
    static let REFER_CODE_COPY = "Refer Code Copied to Clipboard"
    static let REFER_MSG1 = "Refer a Friend, and you will get"
    static let REFER_MSG2 = "coins each time your referral code is used."
    static let REFER_MSG3 = "coins by using your referral code "
    // MARK: - SELF CHALLENGE
    static let ALERT_TITLE = "Select Number Of Questions"
    static let ALERT_TITLE1 = "Select Quiz Play time"
    static let BACK_MSG = "You haven't submitted this test yet."
    static let SUBMIT_TEST = "You want to submit this test?"
    static let RESULT_TXT = "you have completed challenge \n in"
    static let SECONDS = "Sec"
    static let CHLNG_TIME = "Challenge time:"
    // MARK: - FONT
    static let FONT_TITLE =  "Font Size"
    static let FONT_MSG = "Increase/Decrease Font Size\n\n\n\n\n\n"
    // MARK: - IMAGE
    static let IMG_TITLE =  "Choose Image"
    static let NO_CAMERA = "You don't have camera"
    // MARK: - BATTLE
    static let GAME_OVER = "The Game Is over! Play Again "
    static let WIN_BATTLE = "you win the Battle"
    static let CONGRATS = "Congratulations!!"
    static let OPP_WIN_BATTLE = "win the Battle"
    static let LOSE_BATTLE = "Better Luck Next Time"
    static let REBATTLE = "RE-BATTLE"
    static let VICTORY = "VICTORY"
    static let DEFEAT = "DEFEAT"
    static let WINNER = "Winner"
    static let LOSER = "You Lost"
    // MARK: - SHARE TEXT-SELF CHALLENGE
    static let SELF_CHALLENGE_SHARE1 = "I have finished"
    static let SELF_CHALLENGE_SHARE2 = "minute self challenge in"
    static let SELF_CHALLENGE_SHARE3 = "minute in Quiz"
    // MARK: - SHARE QUIZ PLAY RESULT
    static let SHARE1 = "I have completed level"
    static let SHARE2 = "with score"
    static let SHARE_BATTLE_WON = "I Won against"
    static let SHARE_BATTLE_LOST = "I Lost against"
    // MARK: - apps update info string
    static let UPDATE_TITLE = "New Update Available!!"
    static let UPDATE_MSG = "New Update is available for App, to get more functionality and good experiance please Update App"
    static let UPDATE_BUTTON = "Update Now"
    static let DAILY_QUIZ = "Daily Quiz"
    static let DAILY_QUIZ_TITLE = "Play Again"
    static let DAILY_QUIZ_MSG_SUCCESS = "Daily Quiz Completed"
    static let DAILY_QUIZ_MSG_FAIL = "Daily Quiz Fail"
    static let DAILY_QUIZ_SHARE_MSG = "I have completed daily quiz with score "
    static let RANDOM_QUIZ_MSG_SUCCESS = "Random Quiz Completed"
    static let RANDOM_QUIZ_MSG_FAIL = "Random Quiz Fail"
    static let RANDOM_QUIZ_SHARE_MSG = "I have completed Random quiz with score "
    static let TF_QUIZ_MSG_SUCCESS = "TRUE/FALSE Quiz Completed"
    static let TF_QUIZ_MSG_FAIL = "TRUE/FALSE Quiz Fail"
    static let TF_QUIZ_SHARE_MSG = "I have completed TRUE/FALSE Quiz with score "
    static let LEARNING_QUIZ_MSG_SUCCESS = "Your Learning Completed !! You are Now ready to Play Quiz !!!"
    static let LEARNING_QUIZ_MSG_FAIL = "Learning Fail"
    static let LEARNING_QUIZ_SHARE_MSG = "I have completed my Learning quiz with score "
    static let MATHS_QUIZ_MSG_SUCCESS = "Maths Quiz Completed"
    static let MATHS_QUIZ_MSG_FAIL = "Maths Quiz Fail"
    static let MATHS_QUIZ_SHARE_MSG = "I have completed my Maths quiz with score "
    
    static let PLAYED_ALREADY = "Already Played"
    static let PLAYED_MSG = "You have played Daily Quiz already Today. Please Play again Tomorrow !"
    
    static let NO_QSTN = "No Quiz Today"
    static let NO_QSTN_MSG = "There's No Daily Quiz Today. Please Try again Tomorrow !"
    
    static let STR_QUE = "Que"
    static let VALUES = "Available Categories"
    static let STR_CATEGORY = "Category"
    static let STR_ANSWER = "Answer:"
    // MARK: - leaderboard Filters / options
    static let ALL = "All"
    static let MONTHLY = "Monthly"
    static let DAILY = "Daily"
    // MARK: - CONTEST
    static let SHARE_CONTEST = "I have completed Contest With Score"
    static let MSG_CODE = "Please Enter Code"
    static let NO_COINS_TTL = "You don't have enough coins"
    static let NO_COINS_MSG = "Earn Coin and Join Contest"
    static let PLAY_BTN_TITLE = "Play"
    static let LB_BTN_TITLE = "Leaderboard"
    static let STR_COINS = "coins"
    static let STR_ENDS_ON = "Ends On"
    static let STR_ENDING_ON = "Ending On"
    static let STR_STARTS_ON = "Starts On "
    // MARK: - MOBILE LOGIN
    static let MSG_CC = "Please Enter Country Code in correct Format"
    static let MSG_NUM = "Please Enter Phone Number in correct Format"
    // MARK: - USER STATUS
    static let DEACTIVATED = "Account Deactivated"
    static let DEACTIVATED_MSG = "Your account is Deactivated by Admin"
    // MARK: - BATTLE MODES
    static let ROOM_NAME = "OnlineUser"
    static let PRIVATE_ROOM_NAME = "PrivateRoom"
    static let PUBLIC_ROOM_NAME = "PublicRoom"
    
    static let GAMEROOM_DESTROY_MSG = "Are you sure? You want to destroy Gameroom?"
    static let GAMEROOM_EXIT_MSG = "Are you sure you want to exit the game?"
    static let USER_NOT_JOIN = "User has not joined yet, at least one user must join to get started"
    static let MAX_USER_REACHED = "Maximum User Reached"
    static let NO_PLYR_LEFT = "No Player Left in the Room"
    
    static let SELECT_CATGORY = "Select Category"
    static let NO_OFF_QSN = "Number of questions"
    static let TIMER = "Time"
    
    static let QSTN = "Questions"
    static let QSTNS = "Ques"
    static let MINUTES = "Minutes"
    static let PLYR = "Player"
    static let PLYR2 = "Player 2"
    static let BULLET = "●"
    
    static let BUSY = "busy"
    static let INVITE = "Invite"
    
    static let GAMECODE_INVALID = "GameCode is Invalid"
    static let GAME_CLOSED = "GameRoom is Deactivated Or Game Already Started"
    static let GAMEROOM_ENTERCODE = "Enter GameRoom Code"
    static let MSG_GAMEROOM_SHARE = "Here is My Battle Game Code: "
    
    static let GAMEROOM_CLOSE_MSG = "GameRoom is Deactivated"
    static let GAMEROOM_WAIT_ALERT = "Wait for at least one user to join the game"
    static let STAY_BACK = "STAY BACK"
    static let LEAVE = "LEAVE"
    
    static let NO_USER_JOINED = "No One Joined"
    static let NO_USER_JOINED_MSG = "Looks like No user joined game yet."
    static let EXIT = "EXIT"
    
    static let BTL_WAIT_MSG = "Please wait for other players to Answer all Questions."
    
    static let NO_PLYR = "Player Not Available For Battle!!"
    static let TRY_AGAIN = "Try Again"
    static let PLAY_WITH_ROBOT = "Play With Robot"
    
    static let WAIT_IN_ONE_TO_ONE = "Please wait...Game will start in few Seconds"
    
    // MARK: - Placeholder Text - Login / Sign Up / GameRoomCode
    static let P_EMAIL = " Email"
    static let P_PASSWORD = " Password"
    static let P_PHONENUMBER = "Phone Number"
    static let P_REFERCODE = " Refer Code (Optional)"
    static let P_NAME = " Name"
    static let P_GAMECODE = " Game Code"
    static let P_EMAILTXT = " Enter Email Address"
    static let P_OTP = " Enter OTP"
    
    // MARK: - IAP Strings
    static let COINS_ADDED_MSG = "Coins Added Successfully"
    static let PURCHASE = "Purchase"
    static let RESTORE = "Restore"
    
    static let PURCHASE_COINS = "Purchase Coins"
    
    static let TRANSACTION_FAILED = "Transaction Fail!"
    static let VALIDATION_FAILED = "Validation Failed"
    static let VALIDATION_FAILED_MSG = "In-App Purchase validation Fail"
    
    // MARK: - Site Maintenance String
    static var MAINTENANCE_MSG = "App is Under Maintenance.!"
    static let TRY = "Try Again After Sometime"
    //  MARK: - Language
    static let LANG = "en-US"
}
