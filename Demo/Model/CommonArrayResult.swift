//
//  CommonArrayResult.swift
//  Demo
//
//  Created by SKEB2281 on 2021/4/15.
//

import UIKit
import HandyJSON

class CommonArrayResult: HandyJSON {
    
    var limit: Int = 0
    var offset: Int = 0
    var count: Int = 0
    var sort: String = ""
    var results: [Any] = []
    
    required init() {}
}
