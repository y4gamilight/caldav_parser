//
//  ParseCalDavServiceImpl.swift
//  ParseCalDavXML
//
//  Created by Thanh Le on 11/26/18.
//  Copyright © 2018 Thanh Le. All rights reserved.
//

import Foundation

class ParserCalDavServiceImpl:ParserCalDavService {
    private var dataFields = (
        BEGIN: "BEGIN",
        END: "END"
    )
    
    func getCalDavObject(in text:String) -> [Y4ObjectCalDav] {
        let tupples = getKeyValues(in: text)
        
        let objectCalDav = getObjectCalDav(from:tupples)
        return objectCalDav
    }
    
    func getKeyValues(in text:String) ->(keys:[String], mainKeys:[String], values:[String]){
        let newContent = "\n" + text
        let formatRegex = "(?<=\n)(.*)(?=:)";
        
        var keys :[String] = []
        var mainKeys : [String] = []
        var values :[String] = []
        var components = getComponents(format: formatRegex, in: newContent)
        components = components.filter{ $0.contains(" ") == false}
        
        components = components.map { component in
            var result = component
            keys.append(result)
            if component.contains(";") {
                if let first = component.components(separatedBy: ";").first {
                    result = first
                }
            }
            return result
        }
        var tempContent = newContent
        for index in 0 ..< components.count {
            let startStr = keys[index]
            let key = components[index]
            mainKeys.append(key)
            if index < components.count - 1 {
                let nextIndex = index + 1
                let endStr:String = components[nextIndex]
                //        print("startStr :\(startStr)")
                //        print("endStr :\(endStr)")
                let formatRegex = "(?<=\(startStr):)(?s)(.*)(?=\n\(endStr))";
                //        print("formatRegex :\(formatRegex)")
                var value = ""
                let subComps = getComponents(format: formatRegex, in: tempContent)
                if let result = subComps.first {
                    value = result
                }
                values.append(value)
            } else {
                let endStr = "\nENDFLO_\(Date().timeIntervalSince1970)"
                let endContent = "\(tempContent)\(endStr)"
                var value = ""
                let formatRegex = "(?<=\(startStr):)(?s)(.*)(?=\n\(endStr))";
                let subComps = getComponents(format: formatRegex, in: endContent)
                if let result = subComps.first {
                    value = result
                }
                values.append(value)
            }
            
            let prefixStr = "STARTFLO_\(Date().timeIntervalSince1970)"
            let keyIndex = keys[index]
            let valueIndex = values[index]
            let line =  "\(prefixStr)\n\(keyIndex):\(valueIndex)"
            tempContent = "\(prefixStr)\(tempContent)"
            tempContent = tempContent.replacingOccurrences(of: line, with: "")
        }
        return (keys:keys, mainKeys: mainKeys, values:values)
        
    }
    
    
    
    private func getObjectCalDav(from tupples:(keys:[String], mainKeys:[String], values:[String])) -> [Y4ObjectCalDav]{
        let lengthArray = tupples.values.count
        var objects:[Y4ObjectCalDav] = []
        
        //TODO: For
        var currentIndex = 0
        while currentIndex < lengthArray {
            //get index begin 
            let keys = Array(tupples.keys[currentIndex..<lengthArray])
            let mainKeys =  Array(tupples.mainKeys[currentIndex..<lengthArray])
            let values =  Array(tupples.values[currentIndex..<lengthArray])
            
            guard let beginIndex = mainKeys.index(where: {$0 == self.dataFields.BEGIN}) else {
                return objects
            }
            
            let value = values[beginIndex]
            var endIndex = -1
            for i in (beginIndex + 1) ..< mainKeys.count {
                let endValue = values[i]
                if endValue == value {
                    endIndex = i
                    break
                }
            }
            
            //get index end
            if endIndex == -1 {
                return objects
            }
            let startIndex = beginIndex + 1
            let keysOfObject = Array(keys[startIndex..<endIndex])
            let mainKeysOfObject = Array(mainKeys[startIndex..<endIndex])
            let valuesOfObject = Array(values[startIndex..<endIndex])
            let contentsOfObject = getContent(keys: keysOfObject, values: valuesOfObject)
            
            let childs = getObjectCalDav(from: (keys:keysOfObject,mainKeys:mainKeysOfObject,values:valuesOfObject))
            
            let objectCaldav = Y4ObjectCalDav(type: value, keys: keysOfObject, values:valuesOfObject, mainKeys: mainKeysOfObject, childs:childs, contents:contentsOfObject)
            objects.append(objectCaldav)
            currentIndex = currentIndex + endIndex
        }
        
        
        return objects
    }
    
    private func getComponents(format:String, in text:String) -> [String]{
        
        do {
            let regex = try NSRegularExpression(pattern: format)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            let valided = results.map {[weak self] result in
                return String(text[Range(result.range, in: text)!])
            }
            return valided
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    private func getContent(keys: [String], values:[String]) -> [String:String] {
        var dict: [String:String] = [:]
        
        var type:String? = nil
        for index in 0 ..< keys.count {
            let key = keys[index]
            let value = values[index]
            
            if type != nil {
                if key == dataFields.END && type == value {
                    type = nil
                }
            } else {
                if key == dataFields.BEGIN {
                    type = value
                } else {
                    dict[key] = value
                }
            }
            
        }
        
        
        return dict
    }
}
