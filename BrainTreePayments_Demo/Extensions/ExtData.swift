//
//  ExtData.swift
//  BTOFF
//
//  Created by LogicalWings Mac on 05/09/18.
//  Copyright © 2018 LogicalWings Mac. All rights reserved.
//

import Foundation

extension Data{
    
    func getDictionaryFromData() -> NSDictionary {
        
        var dictResponse = NSDictionary()
        
        do {
            
            let responseObject = try JSONSerialization.jsonObject(with: self, options: .allowFragments)
            dictResponse = responseObject as! NSDictionary
            
        } catch (let error) {
            print(error)
        }
        
        return dictResponse
    }
}
