//
//  TextFormatting.swift
//
//  Created by Andrew Goodwin on 8/17/16.
//  Copyright © 2016 Conway Corporation. All rights reserved.
//

import Foundation
import UIKit

private struct AssociatedKeys {
    static var format = "format"
    static var fi = "fi"
    static var ld = "ld"
}

@IBDesignable
extension UITextField
{
    @IBInspectable
    var format: String {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.format) as? String ?? ""
        }
        set {

                let oldFormat = self.format
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.format,
                    newValue as NSString,
                    objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                
                if self.text != nil && self.text!.characters.count > 0{
                    formatChanged(oldFormat)
                }

        }
    }
    private var textSourceArray: [String] {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ld) as? [String] ?? []
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.ld,
                newValue as [NSString]?,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    func formatText(string:String)->Bool{
        //string is the newest character to be added
        if self.format != "" && self.text != nil{
            let backspace = string == ""
            var textFieldIndex = self.text!.characters.count > 0 ? self.text!.characters.count - 1 : -1
            var textFieldArray = Array(self.text!.characters)
            let newStringArray = Array(string.characters)
            let formatArray = Array(self.format.characters)
            var newText = ""
            if backspace == false{
                textFieldArray = textFieldArray + newStringArray
                for s in newStringArray{
                    print(s)
                    if textSourceArray.count < formatArray.count{
                        if String(formatArray[textSourceArray.count]).lowercaseString == "x"{
                            newText = newText + String(textFieldArray[textFieldIndex+1])
                            textFieldIndex = textFieldIndex + 1
                            textSourceArray.append("u")
                        }
                        else{
                            while String(formatArray[textSourceArray.count]).lowercaseString != "x"{
                                if String(formatArray[textSourceArray.count]).lowercaseString == "\\"{
                                    newText = newText + "x"
                                    textSourceArray.append("e")
                                    textSourceArray.append("f")
                                }
                                else{
                                    newText = newText + String(formatArray[textSourceArray.count])
                                    textSourceArray.append("f")
                                }
                            }
                            newText = newText + String(textFieldArray[textFieldIndex+1])
                            textFieldIndex = textFieldIndex + 1
                            textSourceArray.append("u")
                        }
                        
                    }
                    else if textFieldIndex < textFieldArray.count{
                        newText = newText + String(textFieldArray[textFieldIndex+1])
                        textFieldIndex = textFieldIndex + 1
                    }
                    print(textFieldArray)
                    
                    print(textSourceArray)
                }
                self.text = self.text! + newText
                if self.text?.characters.count == formatArray.count{
                    print("done formatting")
                    //if self.respondsToSelector(Selector("getjumpOrder")){
                        //do i support auto first responder
                        NSNotificationCenter.defaultCenter().postNotificationName("text.MoveNext.Format", object: nil)
                    //}
                }
                return false
            }
            else{
                if textSourceArray.count > 0 && textFieldArray.count <= formatArray.count{
                    
                    if textSourceArray.last! == "u"{
                        textSourceArray.removeLast()
                        textFieldArray.removeLast()
                    }
                    
                    while textSourceArray.count > 0 && textSourceArray.last! != "u"{
                        textSourceArray.removeLast()
                        if textSourceArray.count > 0 && textSourceArray.last! != "e"{
                            textFieldArray.removeLast()
                        }
                        else if textSourceArray.count == 0 && textFieldArray.count > 0{
                            textFieldArray.removeLast()
                        }
                        
                    }
                    print(textSourceArray)
                    
                }
                else if textFieldArray.count > 0{
                    textFieldArray.removeLast()
                }
                
                for ch in textFieldArray{
                    newText = newText + String(ch)
                }
                
                print(textFieldArray)
                
                self.text = newText
                return false
            }
        }
        
        return true
    }
    
    private func formatChanged(oldFormat:String?){
        var newText = ""
        var enteredText = self.text
            enteredText = getUserEnteredCharacters(oldFormat!)
            textSourceArray = []
            var formatIndex = 0
            var enteredIndex = 0
            let enteredArray = Array(enteredText!.characters)
            let formatArray = Array(self.format.characters)
            while enteredIndex < enteredArray.count && formatIndex < formatArray.count{
                if String(formatArray[formatIndex]).lowercaseString == "\\"{
                    textSourceArray.append("e")
                    textSourceArray.append("f")
                    newText = newText + "x"
                    formatIndex = formatIndex + 2
                }
                else if String(formatArray[formatIndex]).lowercaseString == "x"{
                    newText = newText + String(enteredArray[enteredIndex])
                    enteredIndex = enteredIndex + 1
                    formatIndex = formatIndex + 1
                    textSourceArray.append("u")
                }
                else{
                    newText = newText + String(formatArray[formatIndex])
                    formatIndex = formatIndex + 1
                    textSourceArray.append("f")
                }
            }
            while enteredIndex < enteredArray.count{
                newText = newText + String(enteredArray[enteredIndex])
                enteredIndex = enteredIndex + 1
            }
            
            self.text = newText
        
        
    }
    
    private func getUserEnteredCharacters(fromFormat:String) -> String{
        if fromFormat == ""{
            return self.text!
        }
        var enteredText = ""
        let enteredArray = Array(self.text!.characters)
        var userEnteredIndices = [Int]()
        let _ = textSourceArray.enumerate().filter{(index, element) in
            if element == "u"{
                userEnteredIndices.append(index)
                return true
            }
            return false
        }
        for ent in userEnteredIndices{
            let char = String(enteredArray[ent])
            print(char)
            enteredText = enteredText + char
        }
        return enteredText
    }
}