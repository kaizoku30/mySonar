//
//  MD5HashGenerator.swift
//  Kudu
//
//  Created by Admin on 24/08/22.
//

import Foundation
import CryptoKit

class MD5Hash {
    static func getHash(inputString: String) -> String {
        let computed = Insecure.MD5.hash(data: inputString.data(using: .utf8)!)
        let output = computed.map { String(format: "%02hhx", $0) }.joined()
       // debugPrint("Hash generated for \(inputString) :\n\(output)")
        return output
    }
    
    static func generateHashForTemplate(itemId: String, modGroups: [ModGroup]?) -> String {
        var inpuString = itemId
        if let modGroups = modGroups {
            // DRINKS
            var selectedDrinksModifiers: [String] = []
            let drinksModGroups: [ModGroup] = modGroups.filter({ $0.modType ?? "" == ModType.drink.rawValue })
            drinksModGroups.forEach({ (drinkModGroup) in
                let selectedModifiers = drinkModGroup.modifiers?.filter({ $0.addedToTemplate ?? false == true })
                selectedModifiers?.forEach({
                    selectedDrinksModifiers.append($0._id ?? "")
                })
            })
            selectedDrinksModifiers.forEach({
                inpuString.append($0)
            })
            // ADD
            var selectedAddModifiers: [String] = []
            let addModGroups: [ModGroup] = modGroups.filter({ $0.modType ?? "" == ModType.add.rawValue })
            addModGroups.forEach({ (addModGroup) in
                let selectedModifiers = addModGroup.modifiers?.filter({ $0.addedToTemplate ?? false == true })
                selectedModifiers?.forEach({
                    let addString = ($0._id ?? "") + ("\($0.count ?? 0)")
                    selectedAddModifiers.append(addString)
                })
            })
            selectedAddModifiers.forEach({
                inpuString.append($0)
            })
            // REMOVE
            var selectedRemoveModifiers: [String] = []
            let removeModGroups: [ModGroup] = modGroups.filter({ $0.modType ?? "" == ModType.remove.rawValue })
            removeModGroups.forEach({ (removeModGroup) in
                let selectedModifiers = removeModGroup.modifiers?.filter({ $0.addedToTemplate ?? false == true })
                selectedModifiers?.forEach({
                    selectedRemoveModifiers.append("\($0._id ?? "")")
                })
            })
            selectedRemoveModifiers.forEach({
                inpuString.append($0)
            })
            // REPLACE
            var selectedReplaceModifiers: [String] = []
            let replaceModGroups: [ModGroup] = modGroups.filter({ $0.modType ?? "" == ModType.replace.rawValue })
            replaceModGroups.forEach({ (replaceModGroup) in
                let selectedModifiers = replaceModGroup.modifiers?.filter({ $0.addedToTemplate ?? false == true })
                selectedModifiers?.forEach({
                    selectedReplaceModifiers.append("\($0._id ?? "")")
                })
            })
            selectedReplaceModifiers.forEach({
                inpuString.append($0)
            })
        }
        
        return MD5Hash.getHash(inputString: inpuString)
    }
}
