//
//  NetworkLogPlugin.swift
//  DNNews
//
//  Created by Evgenii Semenov on 24.12.2019.
//  Copyright © 2019 Evgenii Semenov. All rights reserved.
//

import Foundation
import Moya
import Result

public final class NetworkLogPlugin: PluginType {
    public func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        //      #else
        logDivider()
        
        if let method = request.request?.httpMethod, let url = request.request?.url?.absoluteString {
            print("Request:\t\(method) \(url)")
        }
        
        if let headers = request.request?.allHTTPHeaderFields {
            logDictionary(title: "Headers", dictionary: headers)
        }
        
        if let data = request.request?.httpBody {
            logData(data: data)
        }
        
        logDivider()
        #endif
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        #if DEBUG
        //      #else
        let request = result.value?.request
        let response = result.value?.response
        
        logDivider()
        
        if let method = request?.httpMethod, let url = request?.url?.absoluteString {
            print("Response:\t\(method) \(url)")
        }
        if let code = response?.statusCode {
            print("Code: \t\(code)")
        }
        if let headers = response?.allHeaderFields {
            logDictionary(title: "Headers", dictionary: headers)
        }
        if case .success(let response) = result {
            logData(data: response.data)
        }
        
        logDivider()
        #endif
    }
    
    private func logDivider() {
        print("\n---------------------\n")
    }
    
    private func logDictionary(title: String, dictionary: [AnyHashable : Any]) {
        print("\(title):\t[")
        dictionary.forEach { key, value in
            print("\t\(key) : \(value)")
        }
        print("]")
    }
    
    private func logData(data: Data) {
        if let string = jsonString(from: data) {
            print("JSON:\t\(string)")
        } else if let string = String(data: data, encoding: .utf8) {
            print("Data:\t\(string)")
        }
        
    }
    
    private func jsonString(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
            let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
                return nil
        }
        
        return String(data: pretty, encoding: .utf8)?.replacingOccurrences(of: "\\", with: "")
    }
}
