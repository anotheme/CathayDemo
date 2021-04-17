//
//  ApiShare.swift
//  Demo
//
//  Created by SKEB2281 on 2021/4/15.
//

import UIKit
import Alamofire
import HandyJSON


/// 請求API工具類
class ApiShared: NSObject {
    static let shared: ApiShared = ApiShared()
    var sessionManager = Alamofire.Session.init()
    
    override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        sessionManager = Alamofire.Session.init(configuration: configuration)
    }
    
    func queryApi(url: String,
                      callback: @escaping (_ data: [Any], String?) -> Void)
    {
        sessionManager.request(url, method: .get, encoding: JSONEncoding.default).responseJSON
            { (response) in

                #if DEBUG
//                print(String.init(data: response.data!, encoding: .utf8)!)
                #endif
                
                switch response.result {
                case .success(let data):
                    guard let json: [String : Any] = data as? [String : Any],
                        let data = BaseModel.deserialize(from: json) else {
                            callback([""], "資料格式無法轉換")
                            return
                    }
                    callback(data.result!.results, "共\(data.result!.count)筆，一頁：\(data.result!.limit)筆")
                case .failure(let error):
                    print("\(error)")
                    callback([""], error.localizedDescription)
                    return
                }
        }
    }
    
    
}
