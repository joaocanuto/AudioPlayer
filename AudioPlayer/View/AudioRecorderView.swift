//
//  AudioRecorderView.swift
//  AudioPlayer
//
//  Created by Joao Guilherme Araujo Canuto on 17/08/23.
//

import SwiftUI
import AVFAudio

struct AudioRecorderView: View {
    @State var audioRecorder: AudioRecorder
    var analiseAudio:AnaliseAudio
    
    init(analiseAudio: AnaliseAudio){
        self.analiseAudio = analiseAudio
        self.audioRecorder = AudioRecorder(analiseAudio: analiseAudio)
    }
    
    
    var body: some View {
        VStack{
            Button {
                audioRecorder.startRecording()
            } label: {
                Text("Recording")
            }
            Button {
                audioRecorder.stopRecording()
            } label: {
                Text("Stop")
            }
            
            Button {
                audioRecorder.save()
            } label: {
                Text("Save")
            }
        }
    }
}

//struct AudioRecorderView_Previews: PreviewProvider {
//    static var previews: some View {
//        AudioRecorderView()
//    }
//}
