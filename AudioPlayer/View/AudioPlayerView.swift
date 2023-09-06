//
//  AudioPlayerView.swift
//  AudioPlayer
//
//  Created by Joao Guilherme Araujo Canuto on 17/08/23.
//

import SwiftUI

struct AudioPlayerView: View {
    @State var audioPlayer: AudioPlayer
    var analiseAudio:AnaliseAudio
    var audioUrl: String
    
    init(analiseAudio: AnaliseAudio, url: String){
        self.audioUrl = url
        self.analiseAudio = analiseAudio
        self.audioPlayer = AudioPlayer(analiseAudio: analiseAudio, audioUrl : url)
    }
    
    var body: some View {
        Button {
            audioPlayer.play()
        } label: {
            !audioPlayer.isPlaying ? Text("Play") : Text("Stop")
        }
        Button {
            audioPlayer.saveJson()
        } label: {
            Text("SALVE O JSON!")
        }
    }
}

//struct AudioPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        AudioPlayerView()
//    }
//}
