//
//  ContentView.swift
//  VoiceRecognitionApp
//
//  Created by Mike Paraskevopoulos on 2/10/23.
//

import SwiftUI
import AVFoundation
import Speech

enum HotWords : String,CaseIterable{
    case count,back,code,reset
}


struct ContentView: View {
    let numbersDict = ["zero":"0","one":"1","two":"2","three":"3","four":"4","five":"5","six":"6","seven":"7","eight":"8","nine":"9"]
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var transcript = ""
    @State var isRecording = false
    @State var isEvaluating = false
    @State var validArray = [String]()
    @State var commandCodeList = [CommandCode]()
    
    var body: some View {
        VStack {
            VStack{
                Image(systemName: isRecording ? "pause.circle.fill" :"mic.fill")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Button {
                    if isRecording {
                        stopRec()
                    }else{
                        startRec()
                    }
                } label: {
                    Text(isRecording ?"Stop":"Start")
                }.disabled(isEvaluating)
            }
            
            if let text = speechRecognizer.transcript {
                Text(text).frame(alignment: .center)
            }
            
            
        }.onAppear{onAppear()}
            .padding()
    }
    
    func onAppear(){
        
    }
    
    //MARK: - Rec Control
    func startRec (){
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        isRecording.toggle()
    }
    
    func stopRec() {
        print(speechRecognizer.transcript)
        speechRecognizer.stopTranscribing()
        isRecording.toggle()
        evaluate(speech : speechRecognizer.transcript)
    }
    
    //MARK: - Evaluation
    func evaluate(speech text:String) {
        isEvaluating.toggle()
                validArray = text.components(separatedBy: " ").filter{HotWords.allCases.map { "\($0)" }.contains($0) || numbersDict.keys.contains($0) || numbersDict.values.contains($0)}
        
        //test start
//        var exampleScript = ["code","two","3","four","whatever","67","count","sixty","two", "code","two","reset","code","one","one","two","count", "five","back"]
//        validArray = exampleScript.filter{HotWords.allCases.map { "\($0)" }.contains($0) || numbersDict.keys.contains($0) || numbersDict.values.contains($0) }
        //test end
        
        
        var tempCommand = ""
        var tempCode = ""
        
        for i in 0..<validArray.count{
            
            switch (HotWords(rawValue: validArray[i] )){
            case .reset: do {
                commandCodeList = commandCodeList.dropLast(1)
            }
            case .back: do {
                commandCodeList = commandCodeList.dropLast(1)
            }
            default : do {
                if let command = HotWords(rawValue: validArray[i] )?.rawValue {
                    tempCommand = command
                }else if let number = numbersDict[validArray[i]]  {
                    tempCode += number
                }else if numbersDict.values.contains(validArray[i]) {
                    tempCode += validArray[i]
                }
                
                let pushingCondition = i != validArray.count-1 ? HotWords(rawValue: validArray[i+1] )?.rawValue != nil : true
                if (pushingCondition && validArray[i] != HotWords.reset.rawValue) {
                    print()
                    var cmco = CommandCode(command: tempCommand)
                    cmco.setCode(str: tempCode)
                    commandCodeList.append(cmco)
                    tempCommand = ""
                    tempCode = ""
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
