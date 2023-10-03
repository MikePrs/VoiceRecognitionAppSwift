//
//  RealmManager.swift
//  VoiceRecognitionApp
//
//  Created by Mike Paraskevopoulos on 3/10/23.
//

import Foundation
import RealmSwift

class RealmManager: ObservableObject {
    
    
    private(set) var localRealm: Realm?
    @Published var commands: [Commands] = []

    //MARK: - Initialize Realm
    
    init() {
        openRealm()
        getCommands()
    }
    func openRealm() {
        do {
            let config = Realm.Configuration(schemaVersion: 1, migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion > 1 {
                    // Do something, usually updating the schema's variables here
                }
            })

            Realm.Configuration.defaultConfiguration = config

            localRealm = try Realm()
            print("User Realm User file location: \(localRealm!.configuration.fileURL!.path)")
        } catch {
            print("Error opening Realm", error)
        }
    }
    
    //MARK: - Save new Command
    
    func saveNewCommand(with commandName : String)->String{
        if commandName.isEmpty {return "Cant use empty name."}
        if commands.filter({$0.name == commandName.lowercased()}).count == 0 {
            if let localRealm = localRealm {
                do {
                    try localRealm.write {
                        let newCommand = Commands()
                        newCommand.name = commandName.lowercased()
                        
                        localRealm.add(newCommand)
                        print("Added new command to Realm!")
                    }
                } catch {
                    print("Error adding command to Realm", error)
                }
            }
        }else{
            return "This command already exists"
        }
        
        return "ok"
    }
    
    //MARK: - Get Commands
    func getCommands() {
        if let localRealm = localRealm {
            let allCommands = localRealm.objects(Commands.self)
            allCommands.forEach { com in
                commands.append(com)
            }
        }
    }
}

//MARK: - Command Structure
class Commands: Object {
    @objc dynamic var name = String()
}



