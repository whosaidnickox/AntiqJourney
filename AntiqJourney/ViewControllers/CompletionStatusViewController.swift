
import UIKit

class CompletionStatusViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstButtonOutlet: UIButton!
    
    let lvl = UserDefaults.standard.value(forKey: "level") as! Int
    var level: Int?
    var isWon: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAlertAppearance()
    }
    
    @IBAction func firstButtonGotClicked(_ sender: UIButton) {
        if let level = level, let isWon = isWon {
            if let gameVC = storyboard?.instantiateViewController(withIdentifier: "GameScreenViewController") as? GameScreenViewController {
                gameVC.level = (isWon && (level < 15)) ? (level + 1) :level
                navigationController?.pushViewController(gameVC, animated: true)
            }
        }
    }
    
    @IBAction func exitGotPressed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func setupAlertAppearance() {
        if let level = level, let isWon = isWon {
            if isWon && (level < 15) && (lvl == level) {
                UserDefaults.standard.setValue(lvl + 1, forKey: "level")
            }
            titleLabel.text = isWon ? "Level Competed" : "Game Over"
            firstButtonOutlet.setTitle(isWon ? "Next Level" : "Try Again", for: .normal)
        }
    }
}
