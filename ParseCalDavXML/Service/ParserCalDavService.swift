//
//  ParserCalDavService.swift
//  ParseCalDavXML
//
//  Created by Thanh Le on 11/26/18.
//  Copyright © 2018 Thanh Le. All rights reserved.
//

import Foundation

protocol ParserCalDavService {
    func getCalDavObject(in text:String) ->  [Y4ObjectCalDav] 
    func getKeyValues(in text:String) ->(keys:[String], mainKeys:[String], values:[String])
}
