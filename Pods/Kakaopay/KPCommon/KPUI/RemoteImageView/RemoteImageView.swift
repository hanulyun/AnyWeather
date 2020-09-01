//
//  UIImageView.swift
//  KPUI
//
//  Created by henry on 2018. 3. 7..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

public enum RemoteImageResult: String {
    
    case remoteLoaded
    case cacheLoaded
    case failed
    
    public var isLoaded: Bool {
        return self == .remoteLoaded || self == .cacheLoaded
    }
}

public protocol RemoteImageView: class {
    
    var placeholderImage: UIImage? { get set }
    
    func setImage(url: URL?, useCache cacheType: CacheType, cacheIdentifier: String?, completion: ((RemoteImageResult, Error?) -> Void)?)
    func setImageCancel()
    
    var image: UIImage? { get set }
    var imageUrl: URL? { get set }
}

private var imageViewPlaceholderAssociatedObjectKey: Void?
private var imageViewTaskAssociatedObjectKey: Void?
private var imageViewRequestIdentifierAssociatedObjectKey: Void?
private var imageViewUrlAssociatedObjectKey: Void?

extension HTTPClient {
    public static let image: HTTPClient = {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.requestCachePolicy = .reloadIgnoringCacheData
        let client = HTTPClient(sessionConfiguration: sessionConfiguration, on: OperationQueue())
        client.logLevel = .none
        return client
    }()
}

extension RemoteImageView {
    
    private var task: URLSessionTask? {
        get {
            return objc_getAssociatedObject(self, &imageViewTaskAssociatedObjectKey) as? URLSessionTask
        }
        set {
            objc_setAssociatedObject(self, &imageViewTaskAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var isFirstRequest: Bool {
        get {
            return (task == nil)
        }
    }
    
    public var placeholderImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &imageViewPlaceholderAssociatedObjectKey) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &imageViewPlaceholderAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var requestIdentifier: String? {
        get {
            return objc_getAssociatedObject(self, &imageViewRequestIdentifierAssociatedObjectKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &imageViewRequestIdentifierAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var imageUrl: URL? {
        get {
            return objc_getAssociatedObject(self, &imageViewUrlAssociatedObjectKey) as? URL
        }
        set {
            objc_setAssociatedObject(self, &imageViewUrlAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func setImage(url: URL?, useCache cacheType: CacheType = .file, cacheIdentifier: String? = nil, completion: ((RemoteImageResult, Error?) -> Void)? = nil) {
        if placeholderImage == nil {
            // use default placeholderImage as current image.
        }
        self.imageUrl = url
        
        var maybeIdentifier: String?
        if let cacheID = cacheIdentifier {
            maybeIdentifier = cacheID
        } else if let imageUrl = url {
            maybeIdentifier = imageUrl.absoluteString.pay.SHA256()?.pay.base64UrlEncodedString()
        }
        guard let identifier = maybeIdentifier else {
            DispatchQueue.main.async {
                completion?(.failed, nil)
            }
            return
        }
        
        self.requestIdentifier = identifier
        if let cachedImage = ImageCache.shared[identifier, cacheType] {
            // cache hit
            self.image = cachedImage
            completion?(.cacheLoaded, nil)
        } else {
            guard let urlString = imageUrl?.absoluteString else {
                DispatchQueue.main.async {
                    completion?(.failed, nil)
                }
                return
            }
            task?.cancel()
            self.image = placeholderImage
            task = HTTPClient.image.request(urlString: urlString) { (data: Data?, error) in
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion?(.failed, error)
                    }
                    return
                }
                
                ImageCache.shared[identifier, cacheType] = UIImage(data: data)
                DispatchQueue.main.async {
                    if self.task?.state == .completed,
                        self.requestIdentifier == identifier {
                        self.image = UIImage(data: data)
                        completion?(.remoteLoaded, nil)
                        return
                    }
                    completion?(.failed, error)
                }
            }
        }
    }
    
    public func setImageCancel() {
        task?.cancel()
    }
}

