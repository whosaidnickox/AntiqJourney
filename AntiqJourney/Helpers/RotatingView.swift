
import UIKit

class RotatingView {
    private var view: UIView
    private var anchorAtTop: Bool
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval?

    init(view: UIView, anchorAtTop: Bool) {
        self.view = view
        self.anchorAtTop = anchorAtTop
    }

    func startRotating(duration: TimeInterval = 8.0) {
        let anchorX: CGFloat = 0.5
        let anchorY: CGFloat = anchorAtTop ? 0.0 : 1.0

        let oldCenter = view.center
        view.layer.anchorPoint = CGPoint(x: anchorX, y: anchorY)
        view.center = oldCenter

        displayLink = CADisplayLink(target: self, selector: #selector(updateRotation))
        displayLink?.add(to: .main, forMode: .common)
        startTime = CACurrentMediaTime()
    }
    
    func startRotatingFaster() {
        let anchorX: CGFloat = 0.5
        let anchorY: CGFloat = anchorAtTop ? 0.0 : 1.0

        let oldCenter = view.center
        view.layer.anchorPoint = CGPoint(x: anchorX, y: anchorY)
        view.center = oldCenter

        displayLink = CADisplayLink(target: self, selector: #selector(updateRotation))
        displayLink?.add(to: .main, forMode: .common)
        startTime = CACurrentMediaTime()
    }
    
    func startRotatingAroundCenter(duration: TimeInterval = 8.0) {
        setAnchorPoint(CGPoint(x: 0.5, y: 0.5)) // Set anchor to center
        startTime = CACurrentMediaTime()

        displayLink = CADisplayLink(target: self, selector: #selector(updateRotation))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateRotation() {
        guard let startTime = startTime else { return }
        let elapsed = CACurrentMediaTime() - startTime
        let angle = CGFloat(elapsed / 8.0 * (2 * .pi)) // Full rotation in 6 sec
        view.transform = CGAffineTransform(rotationAngle: angle)
    }

    func stopRotating() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    private func setAnchorPoint(_ point: CGPoint) {
        let oldCenter = view.center
        view.layer.anchorPoint = point
        view.center = oldCenter
    }
}
