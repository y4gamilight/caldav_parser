//
//  main.swift
//  ParseCalDavXML
//
//  Created by Thanh Le on 11/26/18.
//  Copyright © 2018 Thanh Le. All rights reserved.
//

import Foundation

let name = "aol_location.txt"

let openService:OpenFileService = OpenFileServiceImpl()
let parserService: ParserCalDavService = ParserCalDavServiceImpl()
let content = openService.getContent(name,isBundle:true)
print("Content: \(content)")
parserService.getKeyValues(in: content)
let arrays = parserService.getCalDavObject(in: content)
