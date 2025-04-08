
import UIKit

class LevelChoicesViewController: UIViewController {
    @IBOutlet weak var soundButtonOutlet: UIButton!
    @IBOutlet var levelButtonsOutletCollection: [UIButton]!
    let lvl = UserDefaults.standard.value(forKey: "level") as! Int
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupButtons()
    }
    
    @IBAction func dismissViewGotClicked(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func soundGotTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            sender.setBackgroundImage(UIImage(resource: .soundDisabled), for: .normal)
        } else {
            sender.tag = 0
            sender.setBackgroundImage(UIImage(resource: .soundEnabled), for: .normal)
        }
    }
    
    @IBAction func levelGotSelected(_ sender: UIButton) {
        if let mainGameVC = storyboard?.instantiateViewController(withIdentifier: "GameScreenViewController") as? GameScreenViewController {
            mainGameVC.level = sender.tag
            navigationController?.pushViewController(mainGameVC, animated: true)
        }
    }
    
    func setupButtons() {
        for levelBtn in levelButtonsOutletCollection {
            if levelBtn.tag <= lvl {
                levelBtn.isUserInteractionEnabled = true
                levelBtn.setTitleColor(.white, for: .normal)
            } else {
                levelBtn.isUserInteractionEnabled = false
                levelBtn.setTitleColor(.white.withAlphaComponent(0.3), for: .normal)
            }
        }
    }
}
