//
//  NetworkService.swift
//  Weather App
//
//  Created by Yoji on 23.10.2023.
//

import Foundation

public final class NetworkService {
    @MainActor public static let shared = NetworkService()
    
    private let label = "weather"
    
    public lazy var weatherKey: String? = {
        guard let key = self.getKeyFromKeychain(label: label) else { return nil }
        return "&appid=\(self.decode(array: key) ?? "")"
    }()
    
    func getUrlBy(lat: Float, lon: Float) -> String {
        return "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&units=metric"
    }
    
    private func encode(key: String) {
        var array:[UInt8] = []
        key.data(using: .utf8)?.forEach { byte in
            array.append(byte)
        }
        print(array)
    }
    
    private func decode(array: [UInt8]?) -> String? {
        guard let array else { return nil }
        return String(data: Data(array), encoding: .utf8)
    }
    
    private func addKeyToKeychain(key: [UInt8], label: String) -> [UInt8] {
        let keyData = Data(key)
        let keychainItemQuery: [String: Any] = [
            kSecValueData as String: keyData,
            kSecAttrLabel as String: label,
            kSecClass as String: kSecClassKey
        ]
        
        _ = SecItemAdd(keychainItemQuery as CFDictionary, nil)
        return key
    }
    
    private func getKeyFromKeychain(label: String) -> [UInt8]? {
        let keychainSearchingQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrLabel as String: label,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(keychainSearchingQuery as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            var key: [UInt8]
            key = [51, 98, 49, 101, 51, 55, 50, 52, 57, 100, 48, 99, 52, 52, 97, 53, 51, 53, 55, 54, 54, 97, 54, 50, 48, 99, 101, 54, 102, 101, 57, 102]
            return self.addKeyToKeychain(key: key, label: label)
        }
        
        guard let keyData = item as? Data else {
            return nil
        }
        
        let key: [UInt8] = Array(keyData)
        return key
    }
}
