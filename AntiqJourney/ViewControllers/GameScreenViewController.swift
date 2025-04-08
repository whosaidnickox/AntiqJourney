
import UIKit
import SnapKit

class GameScreenViewController: UIViewController {
    @IBOutlet weak var backGameSceneView: UIView!
    @IBOutlet var blackImageViews: [UIImageView]!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var baloonBaseImageView: UIImageView!
    @IBOutlet weak var targetBaseImageView: UIImageView!
    @IBOutlet weak var baloonImageView: UIImageView!
    @IBOutlet weak var targetImageView: UIImageView!
    
    var collisionTimer: CADisplayLink?
    var momentumTimer: CADisplayLink?

    var level: Int?
    let moveStep: CGFloat = 20
    let slowSpeed: CGFloat = 0.7
    let boundaryMargin: CGFloat = 25
    var hasntCompleted = true
    var driftDirection: CGVector = .zero

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        baloonImageView.frame = CGRect(
            x: 50,
            y: backGameSceneView.bounds.height - baloonImageView.frame.height - 30,
            width: 36,
            height: 60
        )
        startCollisionTracking() // Start real-time collision detection
        setupWallsBasedOnLevel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopCollisionTracking()
        stopMomentum()
    }

    private func startCollisionTracking() {
        collisionTimer = CADisplayLink(target: self, selector: #selector(checkCollision))
        collisionTimer?.add(to: .main, forMode: .common)
    }

    private func stopCollisionTracking() {
        collisionTimer?.invalidate()
        collisionTimer = nil
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        backGameSceneView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: backGameSceneView)
        
        // Calculate direction vector (tap location - balloon position)
        let dx = tapLocation.x - baloonImageView.center.x
        let dy = tapLocation.y - baloonImageView.center.y

        // Normalize direction vector to keep movement consistent
        let magnitude = sqrt(dx * dx + dy * dy)
        guard magnitude > 0 else { return } // Avoid divide-by-zero errors

        let direction = CGVector(dx: -dx / magnitude, dy: -dy / magnitude) // Move opposite

        // Move balloon instantly a bit
        let moveDistance: CGFloat = 30
        let newX = baloonImageView.center.x + direction.dx * moveDistance
        let newY = baloonImageView.center.y + direction.dy * moveDistance
        
        self.driftDirection = CGVector(dx: direction.dx * self.slowSpeed, dy: direction.dy * self.slowSpeed)
        self.startMomentum()
    }

    /// Keeps the balloon moving slightly in the last swipe direction
    private func startMomentum() {
        stopMomentum() // Stop existing slow movement

        momentumTimer = CADisplayLink(target: self, selector: #selector(applyMomentum))
        momentumTimer?.add(to: .main, forMode: .common)
    }

    private func stopMomentum() {
        momentumTimer?.invalidate()
        momentumTimer = nil
    }

    @objc private func applyMomentum() {
        var newFrame = baloonImageView.frame
        
        // Apply slow drifting movement
        newFrame.origin.x += driftDirection.dx
        newFrame.origin.y += driftDirection.dy

        // Keep inside boundaries
        if newFrame.minX <= boundaryMargin || newFrame.maxX >= backGameSceneView.bounds.width - boundaryMargin {
            driftDirection.dx = 0
        }
        if newFrame.minY <= boundaryMargin || newFrame.maxY >= backGameSceneView.bounds.height - boundaryMargin {
            driftDirection.dy = 0
        }

        baloonImageView.frame = newFrame

        // Apply small vibration effect
        let vibrationOffset = CGFloat.random(in: -0.3...0.3) // Slight random movement
        baloonImageView.transform = CGAffineTransform(translationX: vibrationOffset, y: vibrationOffset)

        checkCollision()
    }

    @objc private func checkCollision() {
        for barrier in blackImageViews {
            if isColliding(baloonImageView, with: barrier) {
                pushToCompletion(isWon: false)
                stopCollisionTracking()
                stopMomentum()
                return
            }
        }

        if baloonImageView.frame.intersects(targetImageView.frame) {
            pushToCompletion(isWon: true)
            stopCollisionTracking()
            stopMomentum()
        }
    }
    
    private func isColliding(_ balloon: UIView, with barrier: UIView) -> Bool {
        guard let barrierLayer = barrier.layer.presentation(),
              let balloonLayer = balloon.layer.presentation() else { return false }

        // Get frames
        let barrierFrame = barrierLayer.frame
        let balloonFrame = balloonLayer.frame

        // Check basic intersection first
        guard barrierFrame.intersects(balloonFrame) else { return false }

        // Calculate depth of overlap in both x and y directions
        let xOverlap = min(balloonFrame.maxX, barrierFrame.maxX) - max(balloonFrame.minX, barrierFrame.minX)
        let yOverlap = min(balloonFrame.maxY, barrierFrame.maxY) - max(balloonFrame.minY, barrierFrame.minY)

        // Check if the overlap is deeper than 15 points in either direction
        if barrier.tag != 1 {
            if xOverlap >= 30 || yOverlap >= 30 {
                print("Collision detected: Balloon moved 15 points inside the barrier!")
                return true
            }
        } else {
            if xOverlap >= 0 || yOverlap >= 0 {
                print("Collision detected: Balloon moved 15 points inside the barrier!")
                return true
            }
        }

        return false
    }

    func pushToCompletion(isWon: Bool) {
        if hasntCompleted {
            hasntCompleted = false
            if let completionVC = storyboard?.instantiateViewController(withIdentifier: "CompletionStatusViewController") as? CompletionStatusViewController {
                completionVC.isWon = isWon
                completionVC.level = level
                navigationController?.pushViewController(completionVC, animated: true)
            }
        }
    }

    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func restartGameGotClicked(_ sender: UIButton) {
        if let mainGameVC = storyboard?.instantiateViewController(withIdentifier: "GameScreenViewController") as? GameScreenViewController {
            mainGameVC.level = level
            navigationController?.pushViewController(mainGameVC, animated: true)
        }
    }
}
extension GameScreenViewController{
    private func setupWallsBasedOnLevel() {
        guard let level = level else { return }
        switch level {
        case 0:
            print("Initial setup is done for level 0")
        case 1:
            wallSetupInFirstLevel()
        case 2:
            wallSetupInSecondLevel()
        case 3:
            wallSetupInThirdLevel()
        case 4:
            wallSetupInFourthLevel()
        case 5:
            wallSetupInFifthLevel()
        case 6:
            wallSetupInSixthLevel()
        case 7:
            wallSetupInSeventhLevel()
        case 8:
            wallSetupInEighthLevel(isTenth: false)
        case 9:
            wallSetupInThirdLevel()
        case 10:
            wallSetupInEighthLevel(isTenth: true)
        case 11:
            wallSetupInSixthLevel()
        case 12:
            wallSetupInThirdLevel()
        case 13:
            wallSetupInEighthLevel(isTenth: false)
        case 14:
            wallSetupInSeventhLevel()
        case 15:
            wallSetupInFifthLevel()
        default:
            print("Initial setup is done for level default as level 0")
        }
    }
    
    private func wallSetupInFirstLevel() {
        let firstRotatingImage = UIImageView(image: .barier0)
        let secondRotatingImage = UIImageView(image: .barier1)
        blackImageViews.append(firstRotatingImage)
        blackImageViews.append(secondRotatingImage)
        backGameSceneView.addSubview(firstRotatingImage)
        firstRotatingImage.snp.makeConstraints { make in
            make.top.equalTo(backGameSceneView.snp.centerY).offset(-40)
            make.leading.equalToSuperview().inset(230)
            make.height.equalTo(90)
            make.width.equalTo(30)
        }
        let firstRotator = RotatingView(view: firstRotatingImage, anchorAtTop: true)
        
        backGameSceneView.addSubview(secondRotatingImage)
        secondRotatingImage.snp.makeConstraints { make in
            make.top.equalTo(backGameSceneView.snp.centerY).offset(-40)
            make.trailing.equalToSuperview().inset(240)
            make.height.equalTo(90)
            make.width.equalTo(30)
        }
        let secondRotator = RotatingView(view: secondRotatingImage, anchorAtTop: false)
        firstRotator.startRotating()
        secondRotator.startRotating()
    }
    
    private func wallSetupInSecondLevel() {
        leftImageView.image = UIImage(resource: .blackLeft)
        rightImageView.image = UIImage(resource: .blackLeft)
        leftImageView.tag = 1
        rightImageView.tag = 1
        blackImageViews.append(leftImageView)
        blackImageViews.append(rightImageView)
    }
    private func wallSetupInThirdLevel() {
        wallSetupInSecondLevel()
        wallSetupInFirstLevel()
    }
    
    private func wallSetupInFourthLevel() {
        wallSetupInSecondLevel()
        let firstRotatingImage = UIImageView(image: .barier2)
        let secondRotatingImage = UIImageView(image: .barier2)
        blackImageViews.append(firstRotatingImage)
        blackImageViews.append(secondRotatingImage)
        backGameSceneView.addSubview(firstRotatingImage)
        firstRotatingImage.tag = 1
        secondRotatingImage.tag = 1
        firstRotatingImage.snp.makeConstraints { make in
            make.width.equalTo(23)
            make.height.equalTo(116)
            make.bottom.equalToSuperview().inset(30)
            make.trailing.equalTo(backGameSceneView.snp.centerX).offset(-40)
        }
        backGameSceneView.addSubview(secondRotatingImage)
        secondRotatingImage.snp.makeConstraints { make in
            make.width.equalTo(23)
            make.height.equalTo(116)
            make.top.equalToSuperview().inset(30)
            make.leading.equalTo(backGameSceneView.snp.centerX).offset(40)
        }
    }
    private func wallSetupInFifthLevel() {
        wallSetupInSecondLevel()
        let firstRotatingImage = UIImageView(image: .barier3)
        let secondRotatingImage = UIImageView(image: .barier3)
        blackImageViews.append(firstRotatingImage)
        blackImageViews.append(secondRotatingImage)
        
        backGameSceneView.addSubview(firstRotatingImage)
        firstRotatingImage.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(230)
            make.centerY.equalToSuperview()
            make.width.equalTo(30)
            make.height.equalTo(150)
        }
        backGameSceneView.addSubview(secondRotatingImage)
        secondRotatingImage.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(200)
            make.centerY.equalToSuperview()
            make.width.equalTo(30)
            make.height.equalTo(150)
        }
        let firstRotator = RotatingView(view: firstRotatingImage, anchorAtTop: false)
        let secondRotator = RotatingView(view: secondRotatingImage, anchorAtTop: false)
        
        firstRotator.startRotatingAroundCenter(duration: 5.0)
        secondRotator.startRotatingAroundCenter()
    }
    
    private func wallSetupInSixthLevel() {
        wallSetupInSecondLevel()
        let firstRotatingImage = UIImageView(image: .barier4)
        let secondRotatingImage = UIImageView(image: .barier4)
        let thirdRotatingImage = UIImageView(image: .barier4)
        blackImageViews.append(firstRotatingImage)
        blackImageViews.append(secondRotatingImage)
        blackImageViews.append(thirdRotatingImage)
        firstRotatingImage.tag = 1
        secondRotatingImage.tag = 1
        thirdRotatingImage.tag = 1
        backGameSceneView.addSubview(firstRotatingImage)
        firstRotatingImage.snp.makeConstraints { make in
            make.width.equalTo(23)
            make.height.equalTo(212)
            make.bottom.equalToSuperview().inset(30)
            make.trailing.equalTo(backGameSceneView.snp.centerX).offset(-150)
        }
        backGameSceneView.addSubview(secondRotatingImage)
        secondRotatingImage.snp.makeConstraints { make in
            make.width.equalTo(23)
            make.height.equalTo(212)
            make.bottom.equalToSuperview().inset(30)
            make.leading.equalTo(backGameSceneView.snp.centerX).offset(150)
        }
        backGameSceneView.addSubview(thirdRotatingImage)
        thirdRotatingImage.snp.makeConstraints { make in
            make.width.equalTo(23)
            make.height.equalTo(212)
            make.top.equalToSuperview().inset(30)
            make.centerX.equalToSuperview()
        }
    }
    private func wallSetupInSeventhLevel() {
        wallSetupInSecondLevel()
        wallSetupInFirstLevel()
        let firstRotatingImage = UIImageView(image: .barier0)
        blackImageViews.append(firstRotatingImage)
        backGameSceneView.addSubview(firstRotatingImage)
        firstRotatingImage.snp.makeConstraints { make in
            make.top.equalTo(backGameSceneView.snp.centerY).offset(-40)
            make.centerX.equalToSuperview()
            make.height.equalTo(90)
            make.width.equalTo(30)
        }
        let firstRotator = RotatingView(view: firstRotatingImage, anchorAtTop: true)
        firstRotator.startRotating(duration: 3.0)
    }
    
    private func wallSetupInEighthLevel(isTenth: Bool) {
        wallSetupInSecondLevel()
        let firstRotatingImage = UIImageView(image: .barier6)
        let secondRotatingImage = UIImageView(image: .barier5)
        blackImageViews.append(firstRotatingImage)
        blackImageViews.append(secondRotatingImage)
        firstRotatingImage.tag = 1
        secondRotatingImage.tag = 1
        backGameSceneView.addSubview(firstRotatingImage)
        firstRotatingImage.snp.makeConstraints { make in
            make.width.equalTo(180)
            make.height.equalTo(95)
            make.bottom.equalToSuperview().inset(30)
            make.centerX.equalToSuperview().offset(isTenth ? 0 : 70)
        }
        backGameSceneView.addSubview(secondRotatingImage)
        secondRotatingImage.snp.makeConstraints { make in
            make.width.equalTo(180)
            make.height.equalTo(95)
            make.top.equalToSuperview().inset(30)
            make.centerX.equalToSuperview().offset(isTenth ? 0 : -70)
        }
    }
}

