import UIKit

class BookmarkView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var playBookmark: UIButton!
    
    var BookQuesList: [QuestionWithE] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("count of boookmarks BEFORE -- \(BookQuesList.count)")
        //get bookmark list
        if (UserDefaults.standard.value(forKey: "booklist") != nil){
            BookQuesList = try! PropertyListDecoder().decode([QuestionWithE].self,from:(UserDefaults.standard.value(forKey: "booklist") as? Data)!)
        }else{
            getBookmarkData()
        }
        print("count of boookmarks AFtER -- \(BookQuesList.count)")
        
        if BookQuesList.count == 0 {
            playBookmark.isHidden = true
        }
        self.tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        playBookmark.contentMode = .center
        playBookmark.imageView?.contentMode = .scaleAspectFill
        playBookmark.frame.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0))
        playBookmark.layer.cornerRadius = playBookmark.frame.height / 2
        playBookmark.SetShadow()//setCellShadow()
    }
    
    func getBookmarkData(){
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            let userD:User = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            let apiURL = "user_id=\(userD.userID)"
            self.getAPIData(apiName: Apps.API_BOOKMARK_GET, apiURL: apiURL,completion: LoadBookmarkData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    //load Bookmark data here
    func LoadBookmarkData(jsonObj:NSDictionary){
        var BookQuesList: [QuestionWithE] = []
        
        let status = "\(jsonObj.value(forKey: "error") ?? "1")".bool ?? true
        if (status) {
        }else{
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    BookQuesList.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", optionA: "\(val["optiona"]!)", optionB: "\(val["optionb"]!)", optionC: "\(val["optionc"]!)", optionD: "\(val["optiond"]!)", optionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType: "\(val["question_type"] ?? "0")"))
                }
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                UserDefaults.standard.set(try? PropertyListEncoder().encode(BookQuesList), forKey: "booklist")
            }
        });
    }
    
    @IBAction func backButton(_ sender: Any) {
        addPopTransition()
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func playBookButton(_ sender: Any) {
        
        let viewCont = Apps.storyBoard.instantiateViewController(withIdentifier: "BookmarkPlayView") as! BookmarkPlayView
        viewCont.BookQuesList = self.BookQuesList
        addTransition()
        self.navigationController?.pushViewController(viewCont, animated: false)
    }
    
    @IBAction func settingButton(_ sender: Any) {
        let myAlert = Apps.storyBoard.instantiateViewController(withIdentifier:"SettingsAlert")
        myAlert.modalPresentationStyle = .overCurrentContext
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var device_height: CGFloat = 100
        let height:CGFloat = BookQuesList[indexPath.row].image == "" ? device_height : device_height + 45
        return height
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if BookQuesList.count == 0{
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = Apps.NO_BOOKMARK
            noDataLabel.textColor     = Apps.BASIC_COLOR
            noDataLabel.textAlignment = .center
            noDataLabel.font = noDataLabel.font?.withSize(deviceStoryBoard == "Ipad" ? 25 : 15)
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return BookQuesList.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cellIdentifier = BookQuesList[indexPath.row].image != "" ? "BookCell" : "BookCellNoImage"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell  else {
            fatalError("The dequeued cell is not an instance.")
        }
        
        cell.label1Char.roundCorners(corners: [.topLeft,.bottomRight], radius: 11)
        cell.label1Char.text = "\(indexPath.row + 1)"
        cell.label1Char.layer.masksToBounds = true
        cell.qstn.text =  BookQuesList[indexPath.row].question
        if(BookQuesList[indexPath.row].correctAns == "a"){
            cell.ansr.text = "\(Apps.STR_ANSWER) \(BookQuesList[indexPath.row].optionA)"
        }else if(BookQuesList[indexPath.row].correctAns == "b"){
            cell.ansr.text = "\(Apps.STR_ANSWER) \(BookQuesList[indexPath.row].optionB)"
        }else if(BookQuesList[indexPath.row].correctAns == "c"){
            cell.ansr.text = "\(Apps.STR_ANSWER) \(BookQuesList[indexPath.row].optionC)"
        }else if(BookQuesList[indexPath.row].correctAns == "d"){
            cell.ansr.text = "\(Apps.STR_ANSWER) \(BookQuesList[indexPath.row].optionD)"
        }else if(BookQuesList[indexPath.row].correctAns == "e"){
            cell.ansr.text = "\(Apps.STR_ANSWER) \(BookQuesList[indexPath.row].optionE)"
        }
        
        if(BookQuesList[indexPath.row].image != ""){
            DispatchQueue.main.async {
                cell.bookImg.loadImageUsingCache(withUrl: self.BookQuesList[indexPath.row].image)
            }
        }
        
        checkForValues(BookQuesList.count)
        
        cell.tfbtn.tag = indexPath.row
        cell.tfbtn.addTarget(self, action: #selector(RemoveBookmark(_:)), for: .touchUpInside)
        cell.bookView.layer.cornerRadius = 11
        return cell
    }
    
    // remove from bookmark list
    @objc func RemoveBookmark(_ button:UIButton){
        BookQuesList.remove(at: button.tag)
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(BookQuesList), forKey: "booklist")
        tableView.reloadData()
        if BookQuesList.count == 0{
            playBookmark.isHidden = true
        }
        print("count of boookmarks after deletion -- \(BookQuesList.count)")
    }
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
}
