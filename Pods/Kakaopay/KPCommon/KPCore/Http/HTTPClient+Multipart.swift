//
//  HTTPClient+Multipart.swift
//  Kakaopay
//
//  Created by BLICK on 21/08/2019.
//

import Foundation

extension HTTPClient {
    open func makeMultipartBody(parameters: [String: Any]?,
                                boundary: String,
                                multipartValues: [MultipartValue]) -> Data? {
        var body = Data()
        let prefixBoundary = "\r\n--\(boundary)\r\n".data(using: .utf8)
        let suffixBoundary = "\r\n--\(boundary)--\r\n".data(using: .utf8)
        
        if let parameters = parameters {
            body.append(prefixBoundary)
            parameters.forEach {
                let paramsContentDisposition = "Content-Disposition: form-data; name=\"\($0.key)\"\r\n\r\n"
                let valueDataBody = "\($0.value)\r\n"
                
                body.append(prefixBoundary)
                body.append(paramsContentDisposition, using: .utf8)
                body.append(valueDataBody, using: .utf8)
            }
        }
        multipartValues.forEach { value in
            let contentDisposition = "Content-Disposition: form-data; name=\"\(value.name)\"; filename=\"\(value.fileName)\"\r\n"
            let contentType = "Content-Type: \(value.mime)\r\n\r\n"
            
            body.append(prefixBoundary)
            body.append(contentDisposition, using: .utf8)
            body.append(contentType, using: .utf8)
            body.append(value.data)
        }
        body.append(suffixBoundary)
        return body
    }
    
    open func createBoundary() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
}

fileprivate extension Data {
    mutating func append(_ string: String, using: String.Encoding) {
        if let data: Data = string.data(using: using, allowLossyConversion: false) {
            self.append(data)
        }
    }
    
    mutating func append(_ data: Data?) {
        if let data = data {
            self.append(data)
        }
    }
}

// Multipart body 의 Content-Disposition, Content-Type에 들어가는 내용
public class MultipartValue {
    var name: String
    var fileName: String
    var mime: String
    var data: Data?
    
    public init(name: String, fileName: String, mime: String, data: Data?) {
        self.name = name
        self.fileName = fileName
        self.mime = mime
        self.data = data
    }
}
