import UIKit
import AVFoundation

protocol CellSelectDelegate {
    func didCellSelected(_ type: String,_ rowIndex: Int)
}

class HomeTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var titleLabel: UILabel!    
    @IBOutlet weak var leftImg: UIImageView!    
    @IBOutlet weak var viewAllButton: UIButton!
    
   // var homeScreen = HomeScreenController()
    
    var arrColors1 = [UIColor(named: Apps.PURPLE1),UIColor(named: Apps.SKY1),UIColor(named: Apps.ORANGE1),UIColor(named: Apps.BLUE1),UIColor(named: Apps.PINK1),UIColor(named: Apps.GREEN1)]
    var arrColors2 = [UIColor(named: Apps.PURPLE2),UIColor(named: Apps.SKY2),UIColor(named: Apps.ORANGE2),UIColor(named: Apps.BLUE2),UIColor(named: Apps.PINK2),UIColor(named: Apps.GREEN2)]
    
    var tintArr = [Apps.PURPLE2,Apps.SKY2,Apps.ORANGE2,Apps.BLUE2,Apps.PINK2,Apps.GREEN2] //NOTE: arrColors1 & arrColors2 & tintArr - arrays should have same values/count
    /*
     var arrColors2 = [UIColor(named: Apps.SKY1),UIColor(named: Apps.ORANGE1),UIColor(named: Apps.PURPLE1),UIColor(named: Apps.GREEN1),UIColor(named: Apps.BLUE1),UIColor(named: Apps.PINK1)]
     var arrColors1 = [UIColor(named: Apps.SKY2),UIColor(named: Apps.ORANGE2),UIColor(named: Apps.PURPLE2),UIColor(named: Apps.GREEN2),UIColor(named: Apps.BLUE2),UIColor(named: Apps.PINK2)]
     
     var tintArr = ["sky2","orange2","purple2","green2","blue2","pink2"] //NOTE: arrColors1 & arrColors2 & tintArr - arrays should have same values/count
     */
    var playZoneData = [Apps.DAILY_QUIZ_PLAY,Apps.RNDM_QUIZ,Apps.TRUE_FALSE,Apps.SELF_CHLNG] //,Apps.PRACTICE
    let battleData = [Apps.GROUP_BTL,Apps.ONE_TO_ONE_BTL,Apps.RNDM_BTL]
    let battleImgData = [Apps.GRP_BTL,Apps.ONE2ONE_BTL,Apps.RNDM]
        
    //var catData = ["Best Quiz","General Knowledge","Sports","Best Quiz","General Knowledge","Sports","Best Quiz","General Knowledge","Sports"]
    
    var numOfColumns = 7
    
    var initialCatData:[Category] = []
    
    var audioPlayer : AVAudioPlayer!
    var cellDelegate:CellSelectDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        if Apps.DAILY_QUIZ_MODE == "0"{
//            playZoneData.removeFirst()
        if Apps.DAILY_QUIZ_MODE == "0"{ //daily quiz mode is disabled
              if playZoneData.contains(Apps.DAILY_QUIZ_PLAY) == true  {
                  playZoneData.removeFirst()
              }
          }else{ //daily quiz mode is enabled
              //chk if daily quiz play is there in arr - If Not, then add it
              if playZoneData.contains(Apps.DAILY_QUIZ_PLAY) == false  {
                  playZoneData.insert(Apps.DAILY_QUIZ_PLAY, at: 0)
              }
        }
        //trueFalse Enable/Disable mode
        if Apps.TRUE_FALSE_MODE == "0"{ // True/False quiz mode is disabled
              if playZoneData.contains(Apps.TRUE_FALSE) == true  {
                  playZoneData.remove(at: 2) //as it's index is 2 in playZoneData array
              }
          }else{ //daily quiz mode is enabled
              //chk if daily quiz play is there in arr - If Not, then add it
              if playZoneData.contains(Apps.TRUE_FALSE) == false  {
                  playZoneData.insert(Apps.TRUE_FALSE, at: 2) //as it's index is 2 in playZoneData array
              }
        }
        //trueFalse Enable/Disable mode
        
//        if (UserDefaults.standard.value(forKey: "categories") != nil){
//                initialCatData = try! PropertyListDecoder().decode([Category].self,from:(UserDefaults.standard.value(forKey: "categories") as? Data)!)
//                numOfColumns = initialCatData.count
//        }else{
//            print("cat data not loaded")
//            numOfColumns = 0
//        }
//        print("value of cat - \(initialCatData.count)")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        
        getCatData()
        collectionView.setNeedsDisplay()
        collectionView.reloadData()
        checkForValues()
        
    }
    override func layoutSubviews() {
        collectionView.setNeedsDisplay()
        collectionView.reloadData()
    }
    func checkForValues(){
        if arrColors1.count < numOfColumns{
            let dif = numOfColumns - (arrColors1.count - 1)
            print(dif)
            for i in 0...dif{
                arrColors1.append(arrColors1[i])
                arrColors2.append(arrColors2[i])
                tintArr.append(tintArr[i])
            }
        }
    }
    
    func getCatData(){
        print("reloaded CollectionView data")
        if (UserDefaults.standard.value(forKey: "categories") != nil){
                initialCatData.removeAll()
                initialCatData = try! PropertyListDecoder().decode([Category].self,from:(UserDefaults.standard.value(forKey: "categories") as? Data)!)
            print("catData count in tblViewCell - \(initialCatData.count)")
                numOfColumns = initialCatData.count
        }else{
            print("cat data not loaded")
            numOfColumns = 0
        }
        print("value of cat - \(initialCatData.count)")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       // print("titleLabel text in number of sections- \(String(describing: titleLabel.text))")
        if titleLabel.text == Apps.PLAY_ZONE {
            return playZoneData.count//4
        }else if titleLabel.text == Apps.QUIZ_ZONE {
            return numOfColumns
        }else if titleLabel.text == Apps.BATTLE_ZONE {
            return battleData.count
        }else{
            return 1
        }
//        switch (titleLabel.text) {
//        case Apps.PLAY_ZONE:
//            print("play zone")
//            return 5
//        break
//        case Apps.BATTLE_ZONE:
//            print("battle zone")
//            return 1//2
//        break
//        case Apps.CONTEST_ZONE:
//            return 1
//        break
//        default:
//            print("default noOfSections chk -- \(String(describing: titleLabel.text))")
//            return numOfColumns
//        break
//        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cellIdentifier = "QuizZone"
        if titleLabel.text == Apps.MATHS{
            cellIdentifier = "MathsZone"
        }
        if titleLabel.text == Apps.LEARNING{
            cellIdentifier = "LearningZone"
        }
        if titleLabel.text == Apps.QUIZ_ZONE{
            cellIdentifier = "QuizZone"
        }
        if titleLabel.text == Apps.PLAY_ZONE{
            cellIdentifier = "PlayZone"
        }
        if titleLabel.text == Apps.BATTLE_ZONE{
            cellIdentifier = "BattleZone"
        }
        if titleLabel.text == Apps.CONTEST_ZONE{
            cellIdentifier = "ContestZone"
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! QuizCollectionViewCell
        //print("titleLabel text - \(String(describing: titleLabel.text)) -cellIdentifier- \(cellIdentifier)")
        switch cellIdentifier {
        case "MathsZone":
            cell.catTitle.text = Apps.MATHS_PLAY
            cell.simpleView.setGradientLayer(arrColors1[indexPath.row + 5] ?? UIColor.blue,arrColors2[indexPath.row + 5] ?? UIColor.cyan)
           // cell.SetShadow()
            cell.setCellShadow()
        break
        case "LearningZone":
            cell.catTitle.text = Apps.LEARNING_PLAY
            cell.simpleView.setGradientLayer(arrColors1[indexPath.row + 3] ?? UIColor.blue,arrColors2[indexPath.row + 3] ?? UIColor.cyan)
            cell.setCellShadow()
        break
        case "PlayZone":
               // cell.catTitle.frame = CGRect(x: 20, y: 0, width: 300, height: 55)
                cell.catTitle.text = "\(playZoneData[indexPath.row])"
//                cell.lockImgRight.alpha = 1
//                cell.image2.alpha = 1
//                cell.playIcon.alpha = 1
//                cell.txtPlayJoinNow.alpha = 1
//                cell.noOfQues.alpha = 0
//                cell.numOfsubCat.alpha = 0
                cell.simpleView.setGradientLayer(arrColors1[indexPath.row + 1] ?? UIColor.blue,arrColors2[indexPath.row + 1] ?? UIColor.cyan)
             //   cell.simpleView.setGradientLayer(arrColors1[indexPath.row + 2] ?? UIColor.blue,arrColors2[indexPath.row + 2] ?? UIColor.cyan)
                cell.setCellShadow()
            break
            case "QuizZone":
               // print("indexpath rowvalue -\(indexPath.row)")
                cell.catTitle.text = initialCatData[indexPath.row].name//catData[indexPath.row]
                cell.noOfQues.layer.cornerRadius = CGFloat(cell.noOfQues.frame.height / 2)
                cell.noOfQues.layer.masksToBounds = true
                cell.noOfQues.text = "\(initialCatData[indexPath.row].noOfQues) \(Apps.STR_QUE)"//"11 Ques"
                cell.noOfQues.backgroundColor = UIColor.white.withAlphaComponent(0.4)
                cell.numOfsubCat.layer.cornerRadius = CGFloat(cell.noOfQues.frame.height / 2)
                cell.numOfsubCat.layer.masksToBounds = true
                cell.numOfsubCat.text = "\(initialCatData[indexPath.row].noOf) \(Apps.STR_CATEGORY)"//"0 Category"
                cell.numOfsubCat.backgroundColor = UIColor.white.withAlphaComponent(0.4)
                cell.simpleView.setGradientLayer(arrColors1[indexPath.row] ?? UIColor.blue,arrColors2[indexPath.row] ?? UIColor.cyan)
                cell.setCellShadow()
                break
            case "BattleZone": // Apps.BATTLE_ZONE
                cell.catTitle.text = "\(battleData[indexPath.row])"
                cell.rightImgFill.image = UIImage(named: battleImgData[indexPath.row])
//                cell.rightImgFill.alpha = 1
//                cell.playIcon.alpha = 1
//                cell.txtPlayJoinNow.alpha = 1
//                cell.noOfQues.alpha = 0
//                cell.numOfsubCat.alpha = 0
                cell.simpleView.setGradientLayer(arrColors1[indexPath.row + 3] ?? UIColor.blue,arrColors2[indexPath.row + 3] ?? UIColor.cyan)
                //cell.simpleView.setGradientLayer(arrColors1[indexPath.row + 1] ?? UIColor.blue,arrColors2[indexPath.row + 1] ?? UIColor.cyan)
                cell.setCellShadow()
            break
            case "ContestZone":
                cell.catTitle.text = Apps.CONTEST_PLAY_TEXT
//                cell.rightImgFill.image = UIImage(named: Apps.CONTEST_IMG)
//                cell.rightImgFill.alpha = 1
//                cell.playIcon.alpha = 1
//                cell.txtPlayJoinNow.alpha = 1
                //cell.txtPlayJoinNow.text = Apps.JOIN_NOW
                /*if deviceStoryBoard == "Ipad"{
                    cell.txtPlayJoinNow.frame = CGRect(x: 80, y: 100, width: 85, height: 30)
                    cell.playIcon.frame = CGRect(x: 40, y: 100, width: 30, height: 30)
                }else{
                    cell.txtPlayJoinNow.frame = CGRect(x: 60, y: 80, width: 85, height: 30)
                    cell.playIcon.frame = CGRect(x: 20, y: 80, width: 30, height: 30)
                }*/
                
//                cell.noOfQues.alpha = 0//.text = "100 Ques"
//                cell.numOfsubCat.alpha = 0//.text = "10 Subcategories"
            cell.simpleView.setGradientLayer(arrColors1[indexPath.row + 2] ?? UIColor.blue,arrColors2[indexPath.row + 2] ?? UIColor.cyan)
//                cell.simpleView.setGradientLayer(arrColors1[indexPath.row + 5] ?? UIColor.blue,arrColors2[indexPath.row + 5] ?? UIColor.cyan) //2
            cell.setCellShadow()
            break
            default:
//                cell.catTitle.text = "category \(indexPath.row)"
//                cell.noOfQues.text = "11 Ques"
//                cell.noOfQues.backgroundColor = UIColor.white.withAlphaComponent(0.4)
//                cell.numOfsubCat.text = "0 Category"
//                cell.numOfsubCat.backgroundColor = UIColor.white.withAlphaComponent(0.4)
                cell.simpleView.setGradientLayer(arrColors1[indexPath.row] ?? UIColor.blue,arrColors2[indexPath.row] ?? UIColor.cyan)
                cell.setCellShadow()
            break
        }
            return cell
    }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            if (titleLabel.text == Apps.PLAY_ZONE) || (titleLabel.text == Apps.QUIZ_ZONE) {
                return -7//5 //-8
//            }else if (titleLabel.text == Apps.QUIZ_ZONE) {
//                return -7//8
            }else{
                return 1
            }
        }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if (titleLabel.text == Apps.BATTLE_ZONE) {
            return UIEdgeInsets(top: 4.5, left: 0, bottom: 4, right: 0)
        }else if (titleLabel.text == Apps.PLAY_ZONE) {
            return UIEdgeInsets(top: 4.5, left: 0, bottom: 4, right: 0) //3,3
        }else{
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //print("size chk -- \(titleLabel.text!)")
            switch (titleLabel.text) {
            case Apps.PLAY_ZONE:
              //  collectionView.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 10)
                let hh =  deviceStoryBoard == "Ipad" ? collectionView.frame.size.height + 80 :collectionView.frame.size.height - 40//30
                let height = deviceStoryBoard == "Ipad" ? (hh / 2.50) - 2 : (hh / 1.80) - 2 //(hh / 1.80) - 2   //1.85//2
                let deductionVal:CGFloat = deviceStoryBoard == "Ipad" ? 160 : 80//50//100
                let width = collectionView.frame.size.width - deductionVal//100
                return CGSize(width: width, height: height)
            case Apps.BATTLE_ZONE:
                let height = (collectionView.frame.size.height / 3) - 3
                let width = collectionView.frame.size.width + 10//- 20
                /* //for 2 sections instead of 3 there
                 let height = (collectionView.frame.size.height / 2) - 3
                 let width = collectionView.frame.size.width + 10//- 20
                 */
               // print("chk -- \(String(describing: titleLabel.text))")
                return CGSize(width: width, height: height)
            case Apps.QUIZ_ZONE:
                let deductionVal:CGFloat = deviceStoryBoard == "Ipad" ? 200 : 80
                let width = collectionView.frame.size.width - deductionVal
                let height = deviceStoryBoard == "Ipad" ? collectionView.frame.size.height - 20 :collectionView.frame.size.height - 40
                return CGSize(width: width, height: height)
//                let testWidth = deviceStoryBoard == "Ipad" ? collectionView.frame.size.width - 120 : collectionView.frame.size.width - 20
//                return CGSize(width: testWidth, height: collectionView.frame.size.height - 20)
            case Apps.LEARNING:
                if Apps.LEARNING_MODE == "0"{
                    return CGSize(width: collectionView.frame.size.width + 10, height: collectionView.frame.size.height - 20)
                }else{
                    return CGSize(width: collectionView.frame.size.width + 10, height: collectionView.frame.size.height - 20)
                }
            case Apps.MATHS:
                if Apps.MATHS_MODE == "0"{
                    return CGSize(width: collectionView.frame.size.width + 10, height: collectionView.frame.size.height - 20)
                }else{
                    return CGSize(width: collectionView.frame.size.width + 10, height: collectionView.frame.size.height - 20)
                }
            case Apps.CONTEST_ZONE:
                return CGSize(width: collectionView.frame.size.width + 10, height: collectionView.frame.size.height - 20)
            default:
                print("default chk -- \(String(describing: titleLabel.text))")
                return CGSize(width: collectionView.frame.size.width + 10, height: collectionView.frame.size.height - 20)
                //CGSize(width: collectionView.frame.size.width - 20, height: collectionView.frame.size.height - 20)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     /*   var cellName = "categoryview" //identifier of ViewController
        print(indexPath.row)
//        print(titleLabel.text)        
        if titleLabel.text == Apps.BATTLE_ZONE {
            cellName = "battlezone-\(indexPath.row)"
        }
        if titleLabel.text == Apps.PLAY_ZONE {
            //playZoneData
            cellName = "playzone-\(indexPath.row)"
        }
        if titleLabel.text == Apps.QUIZ_ZONE {
            if initialCatData[indexPath.row].noOf == "0" {
                cellName = "LevelView"
            }else{
                cellName = "subcategoryview"
            }
        }
        if titleLabel.text == Apps.CONTEST_ZONE {
            cellName = "ContestView"
        }
        if titleLabel.text == Apps.LEARNING {
            //playZoneData
            cellName = "learningzone"
        }
        
        self.cellDelegate?.didCellSelected(cellName, indexPath.row) */
        var cellName = "categoryview" //identifier of ViewController
        print(indexPath.row)
        if titleLabel.text == Apps.BATTLE_ZONE {
            cellName = "battlezone-\(indexPath.row)"
        }
        if titleLabel.text == Apps.PLAY_ZONE {
            //playZoneData
            var indexVal = indexPath.row
            print("value of curr cell clicked -- \(playZoneData[indexPath.row])")
            switch playZoneData[indexPath.row]{ //indexPath.row
            case Apps.DAILY_QUIZ_PLAY:
                indexVal = 0
            break
            case Apps.RNDM_QUIZ:
                indexVal = 1
            break
            case Apps.TRUE_FALSE:
                indexVal = 2
            break
            case Apps.SELF_CHLNG:
                indexVal = 3
            break
            default:
                indexVal = 3
            break
            }
            cellName = "playzone-\(indexVal)"
        }
        if titleLabel.text == Apps.QUIZ_ZONE {
            if initialCatData[indexPath.row].noOf == "0" {
                cellName = "LevelView"
            }else{
                cellName = "subcategoryview"
            }
        }
        if titleLabel.text == Apps.CONTEST_ZONE {
            cellName = "ContestView"
        }
        if titleLabel.text == Apps.LEARNING {
            //LearningZoneData
            cellName = "learningzone"
        }
        if titleLabel.text == Apps.MATHS {
            //maths
            cellName = "mathszone"
        }
        self.cellDelegate?.didCellSelected(cellName, indexPath.row)
    }
}
