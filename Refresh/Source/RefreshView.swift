import UIKit


private struct Defaults {
    public static let height: CGFloat = 100
    public static let charHeight: CGFloat = 24
    public static let charWidth: CGFloat = 20
    public static let fontSize: CGFloat = 18
    public static let fontName: String = "HelveticaNeue-Bold"
    public static let textColor: UIColor = UIColor.white
    public static let animationDelayTolernace: Double = 0.1
    public static let animationDelay: Double = 0.8
    public static let xLeftDelta: [Double] = [-10, -20, -30, -40, -50, -60, -70 , -80, -90, -100, -120, -140, -160]
    public static let xRightDelta: [Double] = [10, 20, 30, 40, 50, 60, 70 , 80, 90, 100, 120, 140, 160]
}

class RefreshView: UIView {
    
    enum Options {
        case fontName(String)
        case fontSize(CGFloat)
        case text(String)
        case textColor(UIColor)
        case animationDelayTolrenace(Double)
    }
    
    private(set) var text: String!
    private(set) var textColor: UIColor! = Defaults.textColor
    private(set) var fontName: String! = Defaults.fontName
    private(set) var fontSize: CGFloat! = Defaults.fontSize
    private(set) var animationDelayTolernace: Double! = Defaults.animationDelayTolernace
    
    private var textViews: [UILabel] = []
    private var textContainer: UIView!
    private lazy var mazeView = MazeView(frame: self.frame)
    
    convenience init(options: [RefreshView.Options]) {
        let frame = CGRect.init(x: 0, y: 0, width: UIScreen.width, height: Defaults.height)
        self.init(options: options, frame: frame)
    }
    
    init(options: [RefreshView.Options], frame: CGRect) {
        super.init(frame: frame)
        self.setOptions(options)
        self.frame.size.width = fontSize * CGFloat(self.text.length)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupUI() {
        self.createTextContainer()
        self.createTextViews()
        self.setupMazeView()
    }
    
    private func createTextContainer() {
        self.textContainer = UIView(frame: self.frame)
        self.addSubview(self.textContainer)
    }
    
    private func createTextViews() {
        let charHeight = min(self.frame.size.height, max(Defaults.charHeight, fontSize)) + 10
        let charWidth = max(Defaults.charWidth, fontSize)
        var xValue: CGFloat = 0
        
        text.forEach { char in
            let frame = CGRect(x: xValue, y: (self.frame.size.height - charHeight) / 2, width: charWidth, height: charHeight)
            
            let label = Init(UILabel(frame: frame)) { [unowned self] in
                $0.text = char.toString()
                $0.textColor = self.textColor
                $0.textAlignment = .center
                $0.font = UIFont(name: self.fontName, size: self.fontSize)
                $0.alpha = 0.0
            }
            
            self.textViews.append(label)
            self.textContainer.addSubview(label)
            xValue += charWidth
        }
    }
    
    private func setupMazeView() {
        self.addSubview(self.mazeView)
        self.mazeView.alpha = 0.0
    }
    
    private func showMazeView() {
        self.mazeView.alpha = 1.0
        self.mazeView.show()
    }
    
    private func hideMazeView() {
        self.mazeView.alpha = 1.0
        self.mazeView.hide()
    }
    
    func showLetters() {
        self.textViews.forEach{ $0.layer.removeAllAnimations()}
        createTextAnimations(direction: .forward)
    }
    
    func hideLetters() {
        self.textViews.forEach{ $0.layer.removeAllAnimations()}
        createTextAnimations(direction: .backward)
    }
    
    private func createTextAnimations(direction: AnimationDirection) {
        self.textContainer.alpha = 1.0
        self.textViews.forEach{ $0.alpha = direction == .forward ? 1.0 : 0.0}
        
        let midIndex = Int(textViews.count / 2)
        let leftTextView = textViews[0...midIndex]
        let rightTextView = textViews[midIndex+1...textViews.count-1].reversed()
        
        let animations = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.createTextAnimations(for: Array(leftTextView), xDelta: Defaults.xLeftDelta, direction: direction)
            strongSelf.createTextAnimations(for: Array(rightTextView), xDelta: Defaults.xRightDelta, direction: direction)
        }
        
        let onCompletionAnimations = {
            let timingFunction = CAMediaTimingFunction(name: .easeOut)
            guard direction == .backward else  {
                self.textContainer.alpha = 0.0
                return
            }
            let scaleAnimation = self.textContainer.createScaleAnimation([1, 0.5], timingFunction: timingFunction, direction: .forward)
            let opacityAnimation = self.textContainer.createOpacityAnimation([1, 0.0], timingFunction: timingFunction, direction: .forward)
            let translationXAnimation = self.textContainer.createtranslationYAnimation([0, -40], timingFunction: timingFunction, direction: .forward)
            
            
            doAnimationGroup({
                let group = Init(CAAnimationGroup()) {
                    $0.animations = [translationXAnimation, opacityAnimation, scaleAnimation]
                    $0.isRemovedOnCompletion = false
                    $0.beginTime = CACurrentMediaTime() + 0.2
                    $0.duration = 0.8
                }
                self.textContainer.layer.add(group, forKey: "group")
            }, onCompletion: {
                self.textContainer.alpha = 0.0
            })
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(direction == .forward ? 850 : 550)) {
            if direction == .forward {
                self.showMazeView()
            } else {
                self.hideMazeView()
            }
        }
        doAnimationGroup(animations, onCompletion: onCompletionAnimations)
    }
    
    private func createTextAnimations(for views: [UIView], xDelta: [Double], direction: AnimationDirection) {
        var delay = Defaults.animationDelay
        let delayTolerance = Defaults.animationDelayTolernace
        let beginTime = CACurrentMediaTime()
        let timingFunction = CAMediaTimingFunction(name: .easeIn)
        
        views.forEach { view in
            let scaleAnimation = view.createScaleAnimation([1, 1.3, 1.6], timingFunction: timingFunction, direction: direction)
            let opacityAnimation = view.createOpacityAnimation([1, 0.4, 0.2], timingFunction: timingFunction, direction: direction)
            let translationXAnimation = createtranslationXAnimation(xDelta, timingFunction: timingFunction, direction: direction)
            
            doAnimationGroup({
                let group = Init(CAAnimationGroup()) {
                    $0.animations = [translationXAnimation, opacityAnimation, scaleAnimation]
                    $0.isRemovedOnCompletion = false
                    $0.beginTime = beginTime + delay
                }
                view.layer.add(group, forKey: "group")
            }, onCompletion: {
                
                view.alpha = direction == .forward ? 0.0 : 1.0
            })
            
            delay += delayTolerance
        }
    }
    
    func setOptions(_ options: [RefreshView.Options]) {
        options.forEach { option in
            switch option {
            case .fontName(let name):
                self.fontName = name
            case .fontSize(let size):
                self.fontSize = size
            case .text(let text):
                self.text = text
            case .textColor(let color):
                self.textColor = color
            case .animationDelayTolrenace(let value):
                self.animationDelayTolernace = value
            }
        }
    }
}
