import UIKit

class MaintenanceAlert: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var GIFView: UIImageView!
    @IBOutlet weak var tryLater: UIButton!
    @IBOutlet weak var lblMsg: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.layer.cornerRadius = 15
        mainView.backgroundColor = UIColor.white
       
        guard let gifImageView = UIImageView.fromGif(frame: GIFView.frame, resourceName: "animation_200") else { return }
        GIFView.addSubview(gifImageView)
        gifImageView.startAnimating()
        GIFView.image?.symbolConfiguration?.configurationWithoutScale()
        
        lblMsg.text = Apps.MAINTENANCE_MSG
        tryLater.setTitle(Apps.TRY, for: .normal)
    }
   
    @IBAction func ExitAppBtn(_ sender: Any) {
        exit(0) //close App
    }
}
