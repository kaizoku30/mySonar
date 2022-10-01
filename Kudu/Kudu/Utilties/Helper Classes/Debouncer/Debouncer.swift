import UIKit

/** Debouncer class to delay functions that only get delay each other until the timer fires  */
class Debouncer: NSObject {
    
    /** Callback that is getting called when the timer fires */
    public var callback: (() -> Void)?
    
    /** Delay Time in ms */
    public let delay: TimeInterval
    
    /** Next Date when the Debouncer will fire */
    public var fireDate: Date? {
            return timer?.fireDate
    }
    
    /** Timer to fire the callback event */
    private var timer: Timer?
    
    /** Init with delay time as argument */
    public init(delay: TimeInterval) {
        self.delay = delay
    }
    
    /** Init with delay time and callback argument */
    public init(delay: TimeInterval, callback: @escaping (() -> Void)) {
        self.delay = delay
        self.callback = callback
    }
    
    /** Call debouncer to start the callback after the delayed time. Multiple calls will ignore the older calls and overwrite the firing time */
    public func call() {
        // Cancle timer, if already running
        timer?.invalidate()
        // Reset timer to fire next event
        timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(fireCallback), userInfo: nil, repeats: false)
    }
    
    /** Function to fire the fallback, if it was set */
    @objc private func fireCallback(_ timer: Timer) {
        if callback == nil {
            NSLog("Debouncer timer fired, but callback was not set")
        }
        callback?()
    }
}
