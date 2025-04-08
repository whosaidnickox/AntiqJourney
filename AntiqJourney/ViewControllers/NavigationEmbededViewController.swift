
import UIKit

class NavigationEmbededViewController: UIViewController {
    @IBOutlet weak var soundButton: UIButton!
    let main = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func soundGotClicked(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            sender.setBackgroundImage(UIImage(resource: .soundDisabled), for: .normal)
        } else {
            sender.tag = 0
            sender.setBackgroundImage(UIImage(resource: .soundEnabled), for: .normal)
        }
    }
    
    @IBAction func playGotPressed(_ sender: UIButton) {
        if let levelsNavigation = main.instantiateViewController(withIdentifier: "LevelChoicesViewController") as? LevelChoicesViewController {
            navigationController?.pushViewController(levelsNavigation, animated: true)
        }
    }
}

