//
//  File.swift
//  KPCore
//
//  Created by henry on 2018. 2. 1..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit
import FileProvider

/*
 wrapper class of FileManager.default
 */
open class File {
    
    /*
     [from File System Progamming Guide]
     
     .library: (Library/)
     This is the top-level directory for any files that are not user data files. You typically put files in one of several standard subdirectories. iOS apps commonly use the Application Support and Caches subdirectories; however, you can create custom subdirectories.
     Use the Library subdirectories for any files you don’t want exposed to the user. Your app should not use these directories for user data files.
     The contents of the Library directory (with the exception of the Caches subdirectory) are backed up by iTunes and iCloud.
     
     .applicationSupport: (Library/Application support/)
     Put app-created support files in the Library/Application support/ directory. In general, this directory includes files that the app uses to run but that should remain hidden from the user. This directory can also include data files, configuration files, templates and modified versions of resources loaded from the app bundle.
     * The contents of this directory are backed up by iTunes and iCloud.
     
     .documents: (Documents/)
     Put user data in Documents/. User data generally includes any files you might want to expose to the user—anything you might want the user to create, import, delete or edit. For a drawing app, user data includes any graphic files the user might create. For a text editor, it includes the text files. Video and audio apps may even include files that the user has downloaded to watch or listen to later.
     * The contents of this directory are backed up by iTunes and iCloud.
     
     .caches: (Library/Caches/)
     Put data cache files in the Library/Caches/ directory. Cache data can be used for any data that needs to persist longer than temporary data, but not as long as a support file. Generally speaking, the application does not require cache data to operate properly, but it can use cache data to improve performance. Examples of cache data include (but are not limited to) database cache files and transient, downloadable content. Note that the system may delete the Caches/ directory to free up disk space, so your app must be able to re-create or download these files as needed.
     
     .temp: (tmp/)
     Put temporary data in the tmp/ directory. Temporary data comprises any data that you do not need to persist for an extended period of time. Remember to delete those files when you are done with them so that they do not continue to consume space on the user’s device. The system will periodically purge these files when your app is not running; therefore, you cannot rely on these files persisting after your app terminates.
     */
    public static let library = File(baseURL: URL(directory: .library))
    public static let applicationSupport = File(baseURL: URL(directory: .applicationSupport))
    public static let document = File(baseURL: URL(directory: .document))
    public static let caches = File(baseURL: URL(directory: .caches))
    public static let temp = File(baseURL: URL(directory: .temp))

    let baseURL: URL
    public init(baseURL url: URL) {
        baseURL = url
    }
    
    public static func hashedFileName(_ plain: String) -> String {
        return plain.SHA256()!.hexString()
    }
    
    public func makeUrl(_ maybeRelativePath: String? = nil) -> URL {
        guard let relativePath = maybeRelativePath else {
            return baseURL
        }
        return baseURL.appendingPathComponent(relativePath)
    }
    
    public func makePath(_ maybeRelativePath: String? = nil) -> String {
        return makeUrl(maybeRelativePath).path
    }
    
    internal func createPathIfNecessary(at relativePath: String) {
        do {
            let url = makeUrl(relativePath).deletingLastPathComponent()
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch { /* silence error handling. */ }
    }

    @discardableResult
    public func write<Value: DataRepresentable>(_ value: Value?, fileName: String, secureKey maybeKey: Data? = nil) -> Bool {
        guard let value = value else {
            delete(at: fileName)
            return true
        }

        guard let data = value.toData() else {
            return false
        }
        
        var retData: Data = data
        if let key = maybeKey, let encryptedData = data.AES256Encrypt(key: key) {
            retData = encryptedData
        }
        
        createPathIfNecessary(at: fileName)
        return FileManager.default.createFile(atPath: makePath(fileName), contents: retData, attributes: nil)
    }

    @discardableResult
    public func secureWrite<Value: DataRepresentable>(_ value: Value?, fileName: String, key: Data) -> Bool {
        return write(value, fileName: fileName, secureKey: key)
    }
    
    public func read<Value: DataRepresentable>(fileName: String, secureKey maybeKey: Data? = nil) -> Value? {
        guard let data = FileManager.default.contents(atPath: makePath(fileName)) else {
            return nil
        }
        
        var retData: Data = data
        if let key = maybeKey, let decryptedData = data.AES256Decrypt(key: key) {
            retData = decryptedData
        }
        return Value.fromData(retData)
    }
    
    public func secureRead<Value: DataRepresentable>(fileName: String, key: Data) -> Value? {
        return read(fileName: fileName, secureKey: key)
    }

    @discardableResult
    public func delete(at fileName: String? = nil) -> Bool {
        do {
            try FileManager.default.removeItem(at: makeUrl(fileName))
            return true
        } catch {
            return false
        }
    }
    
    public func move(at fileName:String, to: URL) -> Bool {
        do {
            try FileManager.default.moveItem(at: makeUrl(fileName), to: to)
            return true
        } catch {
            return false
        }
    }
    
    public func exists(at fileName: String?) -> Bool {
        guard let fileName = fileName else {
            return false
        }
        return FileManager.default.fileExists(atPath: makePath(fileName))
    }
    
    public func contentsCount(forDirectory directoryPath: String? = nil) -> Int {
        do {
            return try FileManager.default.contentsOfDirectory(atPath: makePath(directoryPath)).count
        } catch  {
            return 0
        }
    }
    
    // as byte
    public func contentsSize(forDirectory directoryPath: String? = nil) -> Int {
        guard let directoryEnumerator = FileManager.default.enumerator(at: makeUrl(directoryPath), includingPropertiesForKeys: [URLResourceKey.fileSizeKey]) else {
            return 0
        }
        
        let fileSizeArray = directoryEnumerator.enumerated().map { iterator -> Int in
            guard let fileUrl = iterator.element as? URL else {
                return 0
            }
            
            do {
                guard let fileSize = try fileUrl.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).fileSize else {
                    return 0
                }
                return fileSize
            } catch { return 0 }
        }
        
        var totalFileSize: Int = 0
        for fileSize in fileSizeArray {
            totalFileSize += fileSize
        }
        return totalFileSize
    }
}

// Codable
extension File {

    @discardableResult
    public func write<Value: Encodable>(_ value: Value?, fileName: String, secureKey maybeKey: Data? = nil) -> Bool {
        guard let value = value else {
            delete(at: fileName)
            return true
        }
 
        var maybeData: Data? = nil
        if let convertData = value as? Data {
            maybeData = convertData
        } else if let convertData = (value as? String)?.data(using: .utf8) {
            maybeData = convertData
        } else if let convertData = try? JSONEncoder().encode(value){
            maybeData = convertData
        }
        
        guard let data = maybeData else {
            return false
        }
 
        var retData: Data = data
        if let key = maybeKey, let encryptedData = data.AES256Encrypt(key: key) {
            retData = encryptedData
        }
 
        createPathIfNecessary(at: fileName)
        return FileManager.default.createFile(atPath: makePath(fileName), contents: retData, attributes: nil)
    }

    @discardableResult
    public func secureWrite<Value: Encodable>(_ value: Value?, fileName: String, key: Data) -> Bool {
        return write(value, fileName: fileName, secureKey: key)
    }
 
    public func read<Value: Decodable>(fileName: String, secureKey maybeKey: Data? = nil) -> Value? {
        guard let data = FileManager.default.contents(atPath: makePath(fileName)) else {
            return nil
        }

        var retData: Data = data
        if let key = maybeKey, let decryptedData = data.AES256Decrypt(key: key) {
            retData = decryptedData
        }
        
        if Value.self is Data.Type {
            return retData as? Value
        } else if Value.self is String.Type {
            return String(bytes: retData, encoding: .utf8) as? Value
        }
        
        return try? JSONDecoder().decode(Value.self, from: retData)
    }
 
    public func secureRead<Value: Decodable>(fileName: String, key: Data) -> Value? {
        return read(fileName: fileName, secureKey: key)
    }
}


// Codable Array
extension File {
    @discardableResult
    public func write<Value: Encodable>(_ value: Value?, fileName: String, secureKey maybeKey: Data? = nil) -> Bool where Value: ExpressibleByArrayLiteral {
        guard let value = value else {
            delete(at: fileName)
            return true
        }
        
        var maybeData: Data? = nil
        do { maybeData = try PropertyListEncoder().encode(value) } catch { }
        
        guard let data = maybeData else {
            return false
        }
        
        var retData: Data = data
        if let key = maybeKey, let encryptedData = data.AES256Encrypt(key: key) {
            retData = encryptedData
        }
        
        createPathIfNecessary(at: fileName)
        return FileManager.default.createFile(atPath: makePath(fileName), contents: retData, attributes: nil)
    }
    
    @discardableResult
    public func secureWrite<Value: Encodable>(_ value: [Value]?, fileName: String, key: Data) -> Bool where Value: ExpressibleByArrayLiteral {
        return write(value, fileName: fileName, secureKey: key)
    }
    
    public func read<Value: Decodable>(fileName: String, secureKey maybeKey: Data? = nil) -> Value? where Value: ExpressibleByArrayLiteral {
        guard let data = FileManager.default.contents(atPath: makePath(fileName)) else {
            return nil
        }
        
        var retData: Data = data
        if let key = maybeKey, let decryptedData = data.AES256Decrypt(key: key) {
            retData = decryptedData
        }
        
        do { return try PropertyListDecoder().decode(Value.self, from: retData) }
        catch { return nil }
    }
    
    public func secureRead<Value: Decodable>(fileName: String, key: Data) -> Value? where Value: ExpressibleByArrayLiteral {
        return read(fileName: fileName, secureKey: key)
    }
}


// Codable Dictionary
extension File {
    @discardableResult
    public func write<Value: Encodable>(_ value: Value?, fileName: String, secureKey maybeKey: Data? = nil) -> Bool where Value: ExpressibleByDictionaryLiteral {
        guard let value = value else {
            delete(at: fileName)
            return true
        }
        
        var maybeData: Data? = nil
        do { maybeData = try PropertyListEncoder().encode(value) } catch { }
        
        guard let data = maybeData else {
            return false
        }
        
        var retData: Data = data
        if let key = maybeKey, let encryptedData = data.AES256Encrypt(key: key) {
            retData = encryptedData
        }
        
        createPathIfNecessary(at: fileName)
        return FileManager.default.createFile(atPath: makePath(fileName), contents: retData, attributes: nil)
    }
    
    @discardableResult
    public func secureWrite<Value: Encodable>(_ value: [Value]?, fileName: String, key: Data) -> Bool where Value: ExpressibleByDictionaryLiteral {
        return write(value, fileName: fileName, secureKey: key)
    }
    
    public func read<Value: Decodable>(fileName: String, secureKey maybeKey: Data? = nil) -> Value? where Value: ExpressibleByDictionaryLiteral {
        guard let data = FileManager.default.contents(atPath: makePath(fileName)) else {
            return nil
        }
        
        var retData: Data = data
        if let key = maybeKey, let decryptedData = data.AES256Decrypt(key: key) {
            retData = decryptedData
        }
        
        do { return try PropertyListDecoder().decode(Value.self, from: retData) }
        catch { return nil }
    }
    
    public func secureRead<Value: Decodable>(fileName: String, key: Data) -> Value? where Value: ExpressibleByDictionaryLiteral {
        return read(fileName: fileName, secureKey: key)
    }
}
