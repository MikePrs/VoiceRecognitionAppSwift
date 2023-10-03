//
//  CommandCode.swift
//  VoiceRecognitionApp
//
//  Created by Mike Paraskevopoulos on 2/10/23.
//

import Foundation


struct CommandCode:Identifiable {
    var command : String?
    var value : Int?
    var id = UUID() 
    
    mutating func setValue(str : String){
        self.value = Int(str)
    }
}
