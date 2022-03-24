import Foundation
import UIKit
import WebKit

class LearningView: UIViewController{
    
    @IBOutlet var txtView: UITextView!
    @IBOutlet var titleText: UILabel!

    var learningData:[LearningData] = []
    var quesData:[QuestionWithE] = []
    var learning_id = 0
    var selected_ch = 0
    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        print(learningData)
        self.titleText.text = self.learningData[self.selected_ch].title//it will be selected from previous view like subCat.
        
        let htmlData = NSString(string: self.learningData[self.selected_ch].detail).data(using: String.Encoding.unicode.rawValue)
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
 
    @IBAction func playButton(_ sender: Any) {
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            let apiURL = "learning_id=\(self.learningData[self.selected_ch].id)"
            self.getAPIData(apiName: "get_questions_by_learning", apiURL: apiURL,completion: getData)
        }
    }
    func getData(jsonObj:NSDictionary){
        print("Learning Response- ",jsonObj) //.value(forKey: "data")
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.Loader.dismiss(animated: true, completion: {
                self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
            })
        }else{
            let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
            viewCont.playType = "learning"
            viewCont.questionType = "learning"//instead of main/sub - to change paramter of structure accordingly [no level number, max level,etc. stuff in learning]
            //also pass chapter name to display as title there in play area
            viewCont.nameOfChapter = self.learningData[self.selected_ch].title
            viewCont.catID = Int(self.learningData[self.selected_ch].id) ?? 0
            
            //get data for category
            self.quesData.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    self.quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", optionA: "\(val["optiona"]!)", optionB: "\(val["optionb"]!)", optionC: "\(val["optionc"]!)", optionD: "\(val["optiond"]!)", optionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "", level: "", note: "", quesType: "\(val["question_type"]!)"))
                }
                Apps.TOTAL_PLAY_QS = data.count
                print(Apps.TOTAL_PLAY_QS)
                
                    viewCont.quesData = self.quesData
                    DispatchQueue.main.async {
                        self.Loader.dismiss(animated: true,completion: nil)
                        self.addTransition()
                        self.navigationController?.pushViewController(viewCont, animated: false)
                    }
            }else{
            }
        }
    }
    @IBAction func backButton(_ sender: Any) {
            self.navigationController?.popToRootViewController(animated: true)
    }
}
