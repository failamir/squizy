import UIKit

class QuizCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var simpleView: UIView!
//Quiz Zone
    @IBOutlet weak var catTitle: UILabel!
    @IBOutlet weak var noOfQues: UILabel!
    @IBOutlet weak var numOfsubCat: UILabel!
    //play Zone and Learning Zone
    @IBOutlet weak var txtPlayJoinNow: UILabel!    
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var lockImgRight: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    //contest and battle Zone and Learning Zone
    @IBOutlet weak var rightImgFill: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//         lockImgRight.image =  UIImage(named: "unlock")
//         lockImgRight.alpha = 0
//         image2.alpha = 0
//         txtPlayJoinNow.alpha = 0
//         playIcon.alpha = 0
        // rightImgFill.alpha = 0
    }
}
