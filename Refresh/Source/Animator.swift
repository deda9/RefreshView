
import UIKit

enum AnimationDirection {
    case forward
    case backward
}

func doAnimationGroup(_ block: () -> Void, onCompletion: @escaping () -> Void) {
    CATransaction.begin()
    CATransaction.setCompletionBlock {
        onCompletion()
    }
    block()
    CATransaction.commit()
}

extension UIView {
    func createScaleAnimation(_ values: [Double],
                              timingFunction: CAMediaTimingFunction,
                              direction: AnimationDirection) -> CAAnimation {
        return createAnimation(keyPath: "transform.scale", values: values, timingFunction: timingFunction, direction: direction)
    }
    
    func createOpacityAnimation(_ values: [Double],
                                timingFunction: CAMediaTimingFunction,
                                direction: AnimationDirection) -> CAAnimation {
        return createAnimation(keyPath: "opacity", values: values, timingFunction: timingFunction, direction: direction)
    }
    
    func createtranslationXAnimation(_ values: [Double],
                                     timingFunction: CAMediaTimingFunction,
                                     direction: AnimationDirection) -> CAAnimation {
        return createAnimation(keyPath: "transform.translation.x", values: values, timingFunction: timingFunction, direction: direction)
    }
    
    func createtranslationYAnimation(_ values: [Double],
                                     timingFunction: CAMediaTimingFunction,
                                     direction: AnimationDirection) -> CAAnimation {
        return createAnimation(keyPath: "transform.translation.y", values: values, timingFunction: timingFunction, direction: direction)
    }
    
    func createAnimation(keyPath: String,
                         values: [Double],
                         timingFunction: CAMediaTimingFunction,
                         direction: AnimationDirection) -> CAAnimation {
        let translationXAnimation = Init(CAKeyframeAnimation(keyPath: keyPath)) {
            $0.timingFunctions = Array(repeating: timingFunction, count: values.count - 1)
            $0.isRemovedOnCompletion = false
            $0.values = direction == .forward ? values : values.reversed()
        }
        return translationXAnimation
    }
}

extension CALayer {
    
    func createRotateAnimation(clockwise: Bool, duration: Double) {
        let rotateAnimation = Init(CAKeyframeAnimation(keyPath: "transform.rotation.z")) {
            let rotateDirection: Double = clockwise ? 1 : -1
            $0.values = [0, rotateDirection * Double.pi, 2 * rotateDirection * Double.pi]
            $0.duration = 1
            $0.repeatCount = HUGE
            $0.isRemovedOnCompletion = false
        }
        self.add(rotateAnimation, forKey: "rotateAnimation")
    }
    
    func createAnimation(clockwise: Bool, duration: Double, show: Bool) {
        let rotateAnimation = Init(CAKeyframeAnimation(keyPath: "transform.rotation.z")) {
            let rotateDirection: Double = clockwise ? 1 : -1
            $0.values = [0, rotateDirection * Double.pi, 2 * rotateDirection * Double.pi]
        }
        
        let scaleAnimation = Init(CAKeyframeAnimation(keyPath: "transform.scale")) {
            $0.values = show ? [0.5, 1] : [1, 0.5]
            $0.timingFunctions = [CAMediaTimingFunction(name: .easeIn)]
        }
        
        let group = Init(CAAnimationGroup()) {
            $0.animations = [scaleAnimation, rotateAnimation]
            $0.duration = duration
            $0.isRemovedOnCompletion = false
        }
        self.add(group, forKey: "group")
    }
}
