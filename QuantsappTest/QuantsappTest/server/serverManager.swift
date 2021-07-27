//
//  serverManager.swift
//  QuantsappTest
//
//  Created by Yash Raut on 27/07/21.
//

import Foundation
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

class ServerManager {
        
    func get(url: String, closure: @escaping (Result<JSON>) -> Void) {
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default)
                .responseSwiftyJSON { response in

                    switch response.result {

                    case .success(let data):
                        print(data)
                        if let result = response.result.value {
                            closure(.success(result))
                        }
                    case .failure(let error):
                        print(error)
                        closure(.failure(error))
                    }
            }
    }
    
    
}


