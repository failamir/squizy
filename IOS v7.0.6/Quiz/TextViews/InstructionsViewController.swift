import UIKit

class InstructionsViewController: UIViewController {

    @IBOutlet var txtView: UITextView!

    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.txtView.backgroundColor = .white
       //get data from server
        if(Reachability.isConnectedToNetwork()){
            self.Loader = self.LoadLoader(loader: self.Loader)
            let apiURL = ""
            self.getAPIData(apiName: "get_instructions", apiURL: apiURL,completion: LoadData)
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
                let attributedString = try? NSMutableAttributedString(data: htmlData ?? Data(),
                                                                      options: options,
                                                                      documentAttributes: nil)
                self.txtView.attributedText = attributedString
                if deviceStoryBoard == "Ipad"{
                    self.txtView.font = .systemFont(ofSize:30)
                } 
            }
        });
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            self.navigationController?.popToViewController( (self.navigationController?.viewControllers[1]) as! HomeScreenController, animated: true)
        }
    }
}
