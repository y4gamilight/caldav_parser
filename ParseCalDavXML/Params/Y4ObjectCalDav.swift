//
//  QEObjectCaldav.swift
//  ParseCalDavXML
//
//  Created by Thanh Le on 12/19/18.
//  Copyright © 2018 Thanh Le. All rights reserved.
//

import Foundation

public struct Y4ObjectCalDav {
    //Type object - in card begin
    public var type:String
    
    //Varible represent keys (full - key and properties of key)
    public var keys:[String]
    
    // Variable represent values
    public var values:[String]
    
    // Variable represent main of key ( exclude properties after ;)
    public var mainKeys:[String]
    
    public var childs:[Y4ObjectCalDav]
    
    public var contents:[String:String]
    
    init(type:String, keys:[String], values:[String], mainKeys:[String], childs:[Y4ObjectCalDav], contents:[String:String]) {
        self.type = type
        self.values = values
        self.keys = keys
        self.mainKeys = mainKeys
        self.childs = childs
        self.contents = contents
        
    }
    
    
    func getObject(of type:String) -> Y4ObjectCalDav? {
        if self.type == type {
            return self
        } else {
            var result:Y4ObjectCalDav? = nil
            for child in childs {
                if let object = child.getObject(of: type) {
                    result = object
                    break
                }
            }
            return result
        }
    }
}
