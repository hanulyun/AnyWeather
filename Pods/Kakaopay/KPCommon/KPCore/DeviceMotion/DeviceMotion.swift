//
//  DeviceMotion.swift
//  Kakaopay
//
//  Created by henry.my on 2020/07/09.
//

import CoreMotion

public class DeviceMotion: CMMotionManager {
    
    /*
     사용하는 쪽에서 import CoreMotion 필요 없도록 별도 타입 정의 (CMAttitude 대체)
     roll, pitch, yaw 값이 헷갈릴때는 아래 문서상의 그림보면 바로 기억납니다!
     https://developer.apple.com/documentation/coremotion/getting_processed_device-motion_data/understanding_reference_frames_and_device_attitude
     */
    public typealias Attitude = (pitch: Double, roll: Double, yaw: Double)
        
    public enum Unit {
        case radian // default (approximately -1.07 ~ 1.07)
        case degree // -180º ~ 180º
        case normalize // -1 ~ 1
        case mapped((pitch: CGFloat, roll: CGFloat, yaw: CGFloat)) // given value range (화면 frame 기반 매핑 등을 위한 편의 기능)
        
        func convert(attitude: CMAttitude) -> Attitude {
            switch self {
            case .radian:
                return Attitude(pitch: attitude.pitch, roll: attitude.roll, yaw: attitude.yaw)
            case .degree:
                let convert: Double = (180.0 / .pi)
                return Attitude(pitch: attitude.pitch * convert, roll: attitude.roll * convert, yaw: attitude.yaw * convert)
            case .normalize:
                return Attitude(pitch: attitude.pitch / .pi, roll: attitude.roll / .pi, yaw: attitude.yaw / .pi)
            case .mapped((let pitch, let roll, let yaw)):
                let attitude = Attitude(pitch: attitude.pitch / .pi, roll: attitude.roll / .pi, yaw: attitude.yaw / .pi)
                let mapping: (Double, CGFloat) -> Double = { map, value in
                    return (map * Double(value)) + Double(value / 2)
                }
                return Attitude(pitch: mapping(attitude.pitch, pitch), roll: mapping(attitude.roll, roll), yaw: mapping(attitude.yaw, yaw))
            }
        }
    }
    
    private let operationQueue = OperationQueue()
    
    // roll = x, pitch = y, yaw = z
    private var previous: Attitude = (0, 0, 0)
    
    // internal: (update interval by seconds), sensitivity: (minumum movement value by radians(or given unit)), useReferenceAttitude: (if set 값들을 현재 위치 기반으로 보정)
    public func start(interval: TimeInterval = 0.01,
                      unit: Unit = .radian,
                      sensitivity maybeSensitibity: Double? = nil,
                      useReferenceAttitude: Bool = true, handler: @escaping (Attitude) -> Void) {
        stop()
        
        guard isDeviceMotionAvailable, isDeviceMotionActive == false else {
            return
        }
        
        startDeviceMotionUpdates()
        var initialAttitude = self.deviceMotion?.attitude
        if useReferenceAttitude, initialAttitude == nil {
            // 바로 측정시 deviceMotion 이 nil 값일 경우가 있어 async after 사용. why???????
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                initialAttitude = self.deviceMotion?.attitude
//                print("set reference: \(initialAttitude)")
            }
        }
        
        deviceMotionUpdateInterval = interval
        startDeviceMotionUpdates(to: self.operationQueue) { [weak self] (maybeData, error) in
            guard let self = self, let data = maybeData else {
                return
            }

            if useReferenceAttitude {
                guard let referenceAttitude = initialAttitude else {
                    return
                }
//                print("using reference: \(referenceAttitude)")
                data.attitude.multiply(byInverseOf: referenceAttitude)
            }

            let attitude = unit.convert(attitude: data.attitude)
            if let sensitivity = maybeSensitibity {
                let pitch = abs(attitude.pitch - self.previous.pitch)
                let roll = abs(attitude.roll - self.previous.roll)
                let yaw = abs(attitude.yaw - self.previous.yaw)
                guard pitch > sensitivity || roll > sensitivity || yaw > sensitivity else {
                    return
                }
            }
            
            // main thread
            DispatchQueue.main.async {
                handler(attitude)
            }
        }

    }
    
    public func stop() {
        stopDeviceMotionUpdates()
    }

    deinit {
        stop()
    }
}
