//
//  AudioListViewModel.swift
//  AudioPlayer
//
//  Created by Joao Guilherme Araujo Canuto on 04/09/23.
//

import Foundation

class AudioListViewModel: ObservableObject {
    lazy var service: CoredataServices = CoredataServices()
    @Published var audiosModel:[AudioModel] = []
    
    init(){
        loadPlants()
    }
    
    func loadPlants(){
        self.audiosModel = self.service.fetchAudioModel()
    }
}
