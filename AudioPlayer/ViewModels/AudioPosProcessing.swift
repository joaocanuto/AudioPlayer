//
//  AudioPosProcessing.swift
//  AudioPlayer
//
//  Created by Joao Guilherme Araujo Canuto on 14/09/23.
//

import Foundation
import AVFAudio
import Accelerate

class AudioPosProcessing {
    var averageDB : Double = 0.0
    var maxDB : Double = 0.0
    var minDB : Double = 0.0
    var pico : Double = 0.0
    var samples: [Float] = []
    
    
    func readData(audioTitle: String){
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentURL.appendingPathComponent(audioTitle)
        do {
            let audioFile = try AVAudioFile(forReading: url)
            //player.scheduleFile(audioFile, at: nil, completionHandler: nil)
            print("file is a file")
            print("file.fileFormat \(audioFile.fileFormat)")
            print("file.length \(audioFile.length)")
            print("file.processingFormat \(audioFile.processingFormat)")
            let test = AVAudioPCMBuffer(pcmFormat: audioFile.fileFormat, frameCapacity: AVAudioFrameCount(2*audioFile.length))
            try audioFile.read(into: test!)
            print(test?.array().count)
            print("Test is a buffer")
            print("test.frameLength \(test!.frameLength)")
            print("test.format \(test!.format)")
            print("test.frameCapacity \(test!.frameCapacity)")
            print("test.stride \(test!.stride)")
            samples.append(contentsOf: test!.array())
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func processData(){
        var sampleAuxiliar:[Float] = []
        self.averageDB = Double(samples
            .applyFilter(.audible)
            .calculateSoundPressureLevel())
        var minAuxiliar:Double = Double.infinity
        var maxAuxiliar:Double = -Double.infinity
//        for i in 0..<samples.count {
//            sampleAuxiliar.append(samples[i])
//            let instDB = sampleAuxiliar
//                .applyFilter(.audible)
//                .calculateSoundPressureLevel()
//            minAuxiliar = min(minAuxiliar, Double(instDB))
//            maxAuxiliar = max(maxAuxiliar, Double(instDB))
//        }
        self.minDB = minAuxiliar
        self.maxDB = calculateDBA(from: samples, sampleRate: 44100.0) ?? 0
        //TODO: Implementar a logica para capturar o pico do audio
        self.pico = 74.65
    }
    
    func getData(audioTitle: String) -> AudioDataCore{
        readData(audioTitle: audioTitle)
        processData()
        let audioDataCore: AudioDataCore = AudioDataCore(averageDB: averageDB, maxDB: maxDB, minDB: minDB, pico: pico)
        return audioDataCore
    }
    
    func calculateDBA(from audioSamples: [Float], sampleRate: Double) -> Double? {
        guard !audioSamples.isEmpty else {
            return nil
        }
        
        // Apply A-weighting filter to the audio samples
        let aWeightingFilter = [ // A-weighting filter coefficients
            1.6975,
            -2.5376,
            2.0897,
            -1.6118,
            0.7161,
            0.1290
        ]
        
        var weightedSamples = [Double](repeating: 0.0, count: audioSamples.count)
        vDSP.convolveD(audioSamples, 1, aWeightingFilter, 1, &weightedSamples, 1, vDSP_Length(audioSamples.count - 5), vDSP_Length(aWeightingFilter.count))
        
        // Calculate the power of the weighted samples
        var power: Double = 0.0
        vDSP_vsqD(weightedSamples, 1, &power, 1, vDSP_Length(audioSamples.count))
        
        // Calculate the mean power level
        power /= Double(audioSamples.count)
        
        // Convert power to dB
        let dB = 10.0 * log10(power)
        
        return dB
    }

    
}
