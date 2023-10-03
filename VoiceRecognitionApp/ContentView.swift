//
//  ContentView.swift
//  VoiceRecognitionApp
//
//  Created by Mike Paraskevopoulos on 2/10/23.
//

import SwiftUI
import AVFoundation
import Speech
import RealmSwift


struct ContentView: View {
    let numbersDict = ["zero":"0","one":"1","two":"2","three":"3","four":"4","five":"5","six":"6","seven":"7","eight":"8","nine":"9"]
    @State var commandsList = [String]()
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State var isRecording = false
    @State var isEvaluating = false
    @State var transcript = "Waiting input..."
    @State var validArray = [String]()
    @State var commandCodeList = [CommandCode]()
    @State var error = ""
    @State var currState = CommandCode()
    @State private var showingAlert = false
    @State private var commandName: String = ""
    @StateObject var realmManager = RealmManager()

    
    var body: some View {
        VStack {
            VStack{
                Text(transcript).frame(alignment: .center)
            }.frame(maxWidth: .infinity).padding().background(.cyan).cornerRadius(20)
            
            if currState.command != nil{
                VStack{
                    VStack(alignment: .leading){
                        Text("Command: \(currState.command!)").padding(.bottom,10)
                        Text("Value: \(currState.value!)")
                    }
                }.frame(maxWidth: .infinity).padding().background(.teal).cornerRadius(20)
            }
            
            Text(error).foregroundColor(.red)
            
            if commandCodeList.count > 0 {
                List(commandCodeList, id: \.id) { item in
                    HStack{
                        VStack(alignment: .leading){
                            Text("Command: \(item.command!)").padding(.bottom,10)
                            Text("Value: \(item.value!)")
                        }
                    }
                }
            }
            Spacer()
            HStack{
                if isRecording{AudioVisualizer()}
                Button {
                    if isRecording {
                        stopRec()
                    }else{
                        startRec()
                    }
                } label: {
                    Image(systemName: isRecording ? "pause.circle.fill" :"mic.fill")
                        .imageScale(.large)
                        .foregroundColor(isRecording ? .black: .white)
                        .frame(width: 90, height: 90)
                        .background(isRecording ? Color.red : .accentColor)
                        .clipShape(Circle())
                }.disabled(isEvaluating)
                if isRecording{AudioVisualizer()}
            }
            HStack{
                Spacer()
                Button {
                    showingAlert = true
                } label: {
                    Text("Add Command")
                }.alert("Add Command", isPresented: $showingAlert,actions:{
                    TextField("Name", text: $commandName)
                    Button("Cancel",role: .cancel, action: {})
                    Button("Done",action:{
                        let addRes = realmManager.saveNewCommand(with: commandName)
                        if addRes != "ok"{
                           error = addRes
                        }
                    })
                },message: {
                    Text("Existing commands: \(commandsList.joined(separator: ", "))")
                })
            }
        }.onAppear{onAppear()}
            .padding()
    }
    
    func onAppear(){
        realmManager.commands.forEach({ commands in
            commandsList.append(String(commands.name))
        })
    }
    
    //MARK: - Rec Control
    func startRec (){
        error = ""
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        isRecording.toggle()
    }
    
    func stopRec() {
        print(speechRecognizer.transcript)
        speechRecognizer.stopTranscribing()
        isRecording.toggle()
        if speechRecognizer.transcript != transcript{
            transcript = speechRecognizer.transcript
            evaluate(speech : speechRecognizer.transcript)
        }
        currState = commandCodeList.last ?? CommandCode()
    }
    
    //MARK: - Evaluation
    func evaluate(speech text:String) {
        isEvaluating.toggle()
        
        
        
        //test start
        //        var exampleScript = ["two","code","3"]
        // text.lowercased().components(separatedBy: " ")
        validArray = text.lowercased().components(separatedBy: " ").filter{commandsList.contains(($0)) || numbersDict.keys.contains($0) || numbersDict.values.contains($0) }
        //test end
        
        
        print(validArray)
        if validArray.count == 0 {
            error = "No valid input"
            isEvaluating.toggle()
            return
        }
        
        var tempCommand = ""
        var tempCode = ""
        
        for i in 0..<validArray.count{
            
            switch (validArray[i]){
            case "reset": do {
                commandCodeList = commandCodeList.dropLast(1)
            }
            case "back": do {
                commandCodeList = commandCodeList.dropLast(1)
            }
            default : do {
                
                if commandsList.contains(validArray[i]) {
                    tempCommand = validArray[i]
                }else if let number = numbersDict[validArray[i]]  {
                    tempCode += number
                }else if numbersDict.values.contains(validArray[i]) {
                    tempCode += validArray[i]
                }
                
                let pushingCondition = i != validArray.count-1 ? commandsList.contains(validArray[i+1]) : true
                if (pushingCondition && validArray[i] != "reset") {
                    if tempCommand != "" && tempCode != "" {
                        var cmco = CommandCode(command: tempCommand)
                        cmco.setValue(str: tempCode)
                        commandCodeList.append(cmco)
                        tempCommand = ""
                        tempCode = ""
                    }else{
                        tempCommand = ""
                        tempCode = ""
                        error = "Input not given correctly."
                        isEvaluating.toggle()
                        return
                    }
                }
            }
            }
        }
        
        print(commandCodeList)
        isEvaluating.toggle()
    }
}


//MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
