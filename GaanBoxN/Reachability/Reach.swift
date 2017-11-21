
import Foundation
import SystemConfiguration

// Rechability changed notification
let ReachabilityStatusChangedNotification = "ReachabilityStatusChangedNotification"

/**
 - Rechability type
 */
enum ReachabilityType: CustomStringConvertible {
    case wwan
    case wiFi
    
    // return current network
    var description: String {
        switch self {
        case .wwan: return "WWAN"
        case .wiFi: return "WiFi"
        }
    }
}

/**
 - Rechability Status
 */
enum ReachabilityStatus: CustomStringConvertible  {
    
    case offline
    case online(ReachabilityType)
    case unknown
    
    // return current network status
    var description: String {
        switch self {
        case .offline: return "Offline"
        case .online(let type): return "Online (\(type))"
        case .unknown: return "Unknown"
        }
    }
}

public class Reach {
    
    static var isInternet = false
    
    /**
     - Identify current network if found return the name
     - Otherwise return unknown
     */
    func connectionStatus() -> ReachabilityStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .unknown
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .unknown
        }
        
        return ReachabilityStatus(reachabilityFlags: flags)
    }
    
    /**
     - Monitor network when it changed
     */
    func monitorReachabilityChanges() {
        
        let host = "google.com"
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        let reachability = SCNetworkReachabilityCreateWithName(nil, host)!
        
        SCNetworkReachabilitySetCallback(reachability, { (_, flags, _) in
            let status = ReachabilityStatus(reachabilityFlags: flags)
 
            switch status {
            case .unknown, .offline:
                Reach.isInternet = false
            case .online(.wwan):
                Reach.isInternet = true
            case .online(.wiFi):
                Reach.isInternet = true
            }
      
            NotificationCenter.default.post(name: Notification.Name(rawValue: ReachabilityStatusChangedNotification),
                                            object: nil,
                                            userInfo: ["Status": status.description])
            }, &context)
        
        SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), RunLoopMode.commonModes as CFString)
    }
}

/**
 - An extension that provide internet is connected or not
 */
extension ReachabilityStatus {
    
    init(reachabilityFlags flags: SCNetworkReachabilityFlags) {
        let connectionRequired = flags.contains(.connectionRequired)
        let isReachable = flags.contains(.reachable)
        let isWWAN = flags.contains(.isWWAN)
     
        if !connectionRequired && isReachable {
            if isWWAN {
                self = .online(.wwan)
            } else {
                self = .online(.wiFi)
            }
        } else {
            self =  .offline
        }
    }
}
