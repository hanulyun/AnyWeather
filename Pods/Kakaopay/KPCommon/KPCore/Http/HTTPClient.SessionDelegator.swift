//
//  HTTPClient.SessionDelegateHandler.swift
//  Kakaopay
//
//  Created by henry.my on 23/09/2019.
//

import Foundation

extension HTTPClient {

    internal class SessionDelegator: NSObject, URLSessionDelegate {
        var pinCertificatesProvider: (() -> [SecCertificate])? = nil
        
        private func trustIsValid(_ trust: SecTrust) -> Bool {
            var isValid = false
            
            var result = SecTrustResultType.invalid
            let status = SecTrustEvaluate(trust, &result)
            
            if status == errSecSuccess {
                let unspecified = SecTrustResultType.unspecified
                let proceed = SecTrustResultType.proceed
                isValid = result == unspecified || result == proceed
            }
            
            return isValid
        }
        
        public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential? = nil
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
                let serverTrust = challenge.protectionSpace.serverTrust,
                let pinCertificatesProvider = self.pinCertificatesProvider {
                
                let host = challenge.protectionSpace.host
                let pinnedCertificates = pinCertificatesProvider()
                
                let policy = SecPolicyCreateSSL(true, host as CFString)
                SecTrustSetPolicies(serverTrust, policy)
                SecTrustSetAnchorCertificates(serverTrust, pinnedCertificates as CFArray)
                SecTrustSetAnchorCertificatesOnly(serverTrust, true)
                
                if trustIsValid(serverTrust) {
                    disposition = .useCredential
                    credential = URLCredential(trust: serverTrust)
                } else {
                    disposition = .cancelAuthenticationChallenge
                }
            }
            completionHandler(disposition, credential)
        }
    }
}
