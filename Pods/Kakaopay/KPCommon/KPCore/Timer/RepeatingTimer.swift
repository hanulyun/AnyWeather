//
//  RepeatingTimer.swift
//  PayPFM
//
//  Created by Lyman.j on 26/04/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

public class RepeatingTimer {
    private(set) var delay: TimeInterval = 0
    private(set) var timerInterval: TimeInterval = 2
    public var eventHandler: (()->Void)?
    
    private enum State {
        case suspended
        case resumed
    }
    private var state: State = .suspended
    
    public init() {
        
    }
    public init(delay: TimeInterval, timeInterval: TimeInterval, handler: (()->Void)? = nil)  {
        self.delay = delay
        self.timerInterval = timeInterval
        self.eventHandler = handler
    }
    public convenience init(timeInterval: TimeInterval) {
        self.init(delay: 0, timeInterval: timeInterval)
    }

    public func update(delay: TimeInterval, timeInterval: TimeInterval) {
        self.delay = delay
        self.timerInterval = timeInterval
    }
    deinit {
        timer.setEventHandler(handler: nil)
        timer.cancel()
        eventHandler = nil
        print("timer deinit")
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + self.delay, repeating: self.timerInterval)
        t.setEventHandler{ [weak self] in
            self?.eventHandler?()
        }
        return t
    }()
    
    public func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }
    public func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
    
    
}
