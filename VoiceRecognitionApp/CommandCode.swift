//
//  CommandCode.swift
//  VoiceRecognitionApp
//
//  Created by Mike Paraskevopoulos on 2/10/23.
//

import Foundation


struct CommandCode {
    var command : String?
    var code : Int?
    
    
    mutating func setCode(str : String){
        self.code = Int(str)
    }
}
