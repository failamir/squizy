import Foundation
import UIKit

class TermsService: UIViewController{
    @IBOutlet var txtView: UITextView!
    
    var isLoginPage = false
    var isInApp = false
    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtView.backgroundColor = .white
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            let apiURL = ""
            self.getAPIData(apiName: "get_terms_conditions_settings", apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    
    //load data here
    func LoadData(jsonObj:NSDictionary){
        var htmlData = ""
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.Loader.dismiss(animated: true, completion: {
                self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
            })
        }else{
            //get data for category
            if let data = jsonObj.value(forKey: "data") as? String {
                htmlData = data
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                let htmlData = NSString(string: htmlData).data(using: String.Encoding.unicode.rawValue)
                let options = [NSAttributedString.DocumentReadingOptionKey.documentType:
                    NSAttributedString.DocumentType.html]
                let attributedString = try? NSMutableAttributedString(data: htmlData ?? Data(), options: options, documentAttributes: nil)
                self.txtView.attributedText = attributedString
                if deviceStoryBoard == "Ipad"{
                    self.txtView.font = .systemFont(ofSize:30)
                } 
            }
        });
    }
    
    @IBAction func backButton(_ sender: Any) {
        if (isInApp == true) {
            addPopTransition()
            self.navigationController?.popViewController(animated: false)
//            self.navigationController?.popViewController(animated: true)
        }else if UserDefaults.standard.bool(forKey: "isLogedin")  || (isLoginPage == true) {
            addPopTransition()
            self.navigationController?.popToRootViewController(animated: false) //true
        }else{
//              self.navigationController?.popViewController(animated: true)
           // let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
           // let viewCont = storyboard.instantiateViewController(withIdentifier: "ViewController") as! HomeScreenController
            addPopTransition()
            self.navigationController?.popToViewController( (self.navigationController?.viewControllers[1]) as! HomeScreenController, animated: false) //true //viewCont
        }
    }
}
