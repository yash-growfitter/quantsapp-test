//
//  dataModel.swift
//  QuantsappTest
//
//  Created by Yash Raut on 27/07/21.
//

import Foundation
import UIKit

class dataMod: NSObject {

    static var sharedInstance:dataMod = dataMod()
    
    var symbol = ""
    var price = ""
    var open_interest = ""
    var price_change_percent = ""
    var open_interest_percent = ""
    
    var filter = ""
}
