//
//  OpenFileServiceImpl.swift
//  ParseCalDavXML
//
//  Created by Thanh Le on 11/26/18.
//  Copyright © 2018 Thanh Le. All rights reserved.
//

import Foundation

class OpenFileServiceImpl:OpenFileService {
    func getContent(_ name:String, isBundle:Bool) -> String {
        var content = ""
        if isBundle == true { 
            let url = URL(fileURLWithPath: name)
            do {
                content = try String(contentsOf: url)
            } catch(let e) {
                print("Exception :\(e)")
            }
            
        }
        return content
    }
}
