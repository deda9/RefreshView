import UIKit

private struct Defaults {
    public static let largeCircleRaduis: CGFloat = 30.0
    public static let meduimCircleRaduis: CGFloat = 20.0
    public static let smallCircleRaduis: CGFloat = 10.0
    public static let lineWidth: CGFloat = 4
    public static let animationDuration: Double = 0.5
}

protocol MazeViewDelegate: class {
    func mazeView(view: MazeView, onFinishHiding: Bool)
    func mazeView(view: MazeView, onStartHiding: Bool)
    func mazeView(view: MazeView, onStartShowing: Bool)
    func mazeView(view: MazeView, onFinishShowing: Bool)
}

extension MazeViewDelegate {
    func mazeView(view: MazeView, onFinishHiding: Bool) {}
    func mazeView(view: MazeView, onStartHiding: Bool) {}
    func mazeView(view: MazeView, onStartShowing: Bool) {}
    func mazeView(view: MazeView, onFinishShowing: Bool) {}
}

class MazeView: UIView {
    
    weak var delegate: MazeViewDelegate?
    var layers: [CALayer]  = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        createLargeCircle()
        createMeduimCircle()
        createSmallCircle()
    }
    
    func hide() {
        delegate?.mazeView(view: self, onStartHiding: true)
        
        let animations = { [weak self] in
            guard let stongSelf = self else {
                return
            }
            stongSelf.layers.forEach {
                $0.createAnimation(clockwise: randomTrue(), duration: Defaults.animationDuration, show: false)
            }
        }
        
        let onCompletion = { [weak self] in
            guard let stongSelf = self else {
                return
            }
            stongSelf.alpha = 0
            stongSelf.delegate?.mazeView(view: stongSelf, onFinishHiding: true)
        }
        
        doAnimationGroup(animations, onCompletion: onCompletion)
    }
    
    func show() {
        delegate?.mazeView(view: self, onStartShowing: true)
        
        self.alpha = 1
        
        let animations = { [weak self] in
            guard let stongSelf = self else {
                return
            }
            stongSelf.layers.forEach {
                $0.createAnimation(clockwise: randomTrue(), duration: Defaults.animationDuration, show: true)
            }
        }
        
        let onCompletion = { [weak self] in
            guard let stongSelf = self else {
                return
            }
            stongSelf.layers.forEach {
                $0.createRotateAnimation(clockwise: randomTrue(), duration: Defaults.animationDuration)
            }
            stongSelf.delegate?.mazeView(view: stongSelf, onFinishShowing: true)
        }
        doAnimationGroup(animations, onCompletion: onCompletion)
    }
}

fileprivate extension MazeView {
    @discardableResult
    func createLargeCircle() -> CALayer {
        let startAngle: CGFloat = 0.0
        let endAngle = CGFloat(2 * Double.pi)
        let radius: CGFloat = Defaults.largeCircleRaduis
        let center = CGPoint(x: radius, y: radius)
        let layer = self.createCircle(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, dash: [40, 20])
        layer.position = self.center
        layers.append(layer)
        return layer
    }
    
    @discardableResult
    func createMeduimCircle() -> CALayer {
        let startAngle: CGFloat = 0.0
        let endAngle = CGFloat(2 * Double.pi)
        let radius: CGFloat = Defaults.meduimCircleRaduis
        let center = CGPoint(x: radius, y: radius)
        let layer = self.createCircle(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, dash: [10, 3, 30, 7, 20, 8])
        layer.position = self.center
        layers.append(layer)
        return layer
    }
    
    @discardableResult
    func createSmallCircle() -> CALayer {
        let startAngle = CGFloat(-3 * Double.pi / 4)
        let endAngle = CGFloat(-Double.pi / 4)
        let radius: CGFloat = Defaults.smallCircleRaduis
        let center = CGPoint(x: radius, y: radius)
        let layer = self.createCircle(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle)
        layer.position = self.center
        layers.append(layer)
        return layer
    }
    
    func createCircle(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, dash: [NSNumber]? = nil) -> CALayer {
        let path = Init(UIBezierPath()) {
            $0.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
        
        let layer = Init(CAShapeLayer()) {
            $0.fillColor = nil
            $0.lineWidth = Defaults.lineWidth
            $0.strokeColor = UIColor.white.cgColor
            $0.path = path.cgPath
            $0.frame = CGRect(x: 0, y: 0, width: 2 * radius, height: 2 * radius)
            $0.lineDashPattern = dash
        }
        
        self.layer.addSublayer(layer)
        return layer
    }
}
