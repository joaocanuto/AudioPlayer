//
//  AudioListView.swift
//  AudioPlayer
//
//  Created by Joao Guilherme Araujo Canuto on 04/09/23.
//

import SwiftUI

struct AudioListView: View {
    var vm: AudioListViewModel = AudioListViewModel()
    
    var body: some View {
        VStack{
            LazyVStack(spacing:12){
                ForEach(vm.audiosModel, id: \.self){ audio in
                    VStack{
                        //Text(audio.url)
                        NavigationLink(destination: AudioPlayerView(analiseAudio: AnaliseAudio(), url: audio.url), label:  {Text("Audio Player")})
                    }
                }
            }
        }
        Button {
            vm.service.deleteAll()
        } label: {
            Text("Delete")
        }
    }
}

struct AudioListView_Previews: PreviewProvider {
    static var previews: some View {
        AudioListView()
    }
}
