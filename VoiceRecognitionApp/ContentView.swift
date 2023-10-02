//
//  ContentView.swift
//  VoiceRecognitionApp
//
//  Created by Mike Paraskevopoulos on 2/10/23.
//

import SwiftUI
import AVFoundation
import Speech

struct ContentView: View {
    
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var transcript = ""
    @State var isRecording = false
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
                }
            }
            
            if let text = speechRecognizer.transcript {
                Text(text).frame(alignment: .center)
            }
            

        }.onAppear{}
        .padding()
    }
    
    func startRec (){
        isRecording.toggle()
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
    }
    
    func stopRec() {
        print(speechRecognizer.transcript)
        speechRecognizer.stopTranscribing()
        isRecording.toggle()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
