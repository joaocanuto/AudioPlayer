//
//  ContentView.swift
//  AudioPlayer
//
//  Created by Joao Guilherme Araujo Canuto on 16/08/23.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
//    @StateObject var audioPlayer = AudioPlayer()
    @State var analiseAudio = AnaliseAudio()
    var body: some View {
        VStack {
            NavigationView {
                VStack{
                    NavigationLink(destination: AudioPlayerView(analiseAudio:analiseAudio), label:  {Text("Audio Player")})
                    NavigationLink(destination: AudioRecorderView(analiseAudio: analiseAudio), label:  {Text("Audio Recorder")})
                    NavigationLink(destination: AudioRecPlayView(), label:  {Text("Audio Recorder e Player")})
                }
            }

            Button {
                analiseAudio.analise()
            } label: {
                Text("Analise Audio!!")
            }

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
