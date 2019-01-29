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
            
            let value = values[beginIndex].trimmingCharacters(in: .whitespacesAndNewlines)
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
    
    private func getComponentsAndResult(format:String, in text:String) -> ( [(NSRange,String)]) {
        
        do {
            let regex = try NSRegularExpression(pattern: format)
            let results = regex.matches(in: text, options: .withoutAnchoringBounds,
                                        range: NSRange(text.startIndex..., in: text))
            let valided = results.compactMap { (result) -> (_ :NSRange,_ : String)? in
                var rangeText = result.range
                guard let range = Range.init(result.range, in: text)else{
                    return nil
                }
                //Get first ":"
                let value = String(text[range])
                var keyValue = value
                if let key = value.components(separatedBy: ":").first {
                    keyValue = key
                    rangeText.length = key.count
                }
                return (rangeText,keyValue)
            }
            return valided
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    private func getComponents(format:String, in text:String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: format)
            let results = regex.matches(in: text, options: .withoutAnchoringBounds,
                                        range: NSRange(text.startIndex..., in: text))
            let valided = results.map { result in
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
    
    
    func getKeyValues(in text:String) ->(keys:[String], mainKeys:[String], values:[String]){
        let text = text.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
        let newContent = "\n" + text
        let formatRegex = "(?<=\n)(.*)(?=:)";
        
        var keys :[String] = []
        var mainKeys : [String] = []
        var values :[String] = []
        var results = getComponentsAndResult(format: formatRegex, in: newContent)
        results = results.filter{ result in
            let fullKey = result.1
            if fullKey.contains(" ") == true {
                //[TODO] Hard code for trick
                if fullKey.contains("mailto") == false {
                    return false
                }
                
                if fullKey.contains("ORGANIZER") == false && fullKey.contains("ATTENDEE") == false {
                    return false
                }
            }
            return true
            
        }
        let components = results.map {$0.1}
        var ranges = results.map {$0.0}
        
        components.forEach { component in
            var result = component
            keys.append(result)
            if component.contains(";") {
                if let first = component.components(separatedBy: ";").first {
                    result = first
                }
            }
            mainKeys.append(result)
        }
        var tempContent = newContent
        for index in 0 ..< mainKeys.count {
            let startStr = keys[index]
            let startRange = ranges[index].location
            let indexStart = newContent.index(newContent.startIndex, offsetBy: startRange)
            if index < mainKeys.count - 1 {
                let nextIndex = index + 1
                let endStr:String = mainKeys[nextIndex]
                //        print("startStr :\(startStr)")
                //        print("endStr :\(endStr)")
                let formatRegex = "(?<=\(startStr):)(?s)(.*)(?=\n\(endStr))";
                //        print("formatRegex :\(formatRegex)")
                var value = ""
                let endRange = ranges[nextIndex].location + ranges[nextIndex].length
                let indexEnd = newContent.index(newContent.startIndex, offsetBy: endRange)
                tempContent = String(newContent[indexStart..<indexEnd])
                let subComps = getComponents(format: formatRegex, in: tempContent)
                if let result = subComps.first {
                    value = result
                }
                values.append(value)
            } else {
                tempContent = String(newContent[indexStart..<newContent.endIndex])
                var value = tempContent.replacingOccurrences(of: "\(startStr):", with: "")
                value = value.trimmingCharacters(in: .whitespacesAndNewlines)
                values.append(value)
            }
            
        }
        return (keys:keys, mainKeys: mainKeys, values:values)
        
    }
    
}
