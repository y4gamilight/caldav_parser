//
//  OpenFileService.swift
//  ParseCalDavXML
//
//  Created by Thanh Le on 11/26/18.
//  Copyright © 2018 Thanh Le. All rights reserved.
//

import Foundation

protocol OpenFileService {
    func getContent(_ name:String, isBundle:Bool) -> String
}
