//
//  AudioSave.swift
//  AudioPlayer
//
//  Created by Joao Guilherme Araujo Canuto on 21/08/23.
//

import Foundation
import AVFAudio

class AudioSave {
    var service: CoredataServices = CoredataServices()
    
    func saveRec(samples: [Float], mixer: AVAudioMixerNode,jsonArray: [[String: Any]]) -> String{
        var audioFile:AVAudioFile?
        //Saving Audio
        let audioFormat = mixer.outputFormat(forBus: 0)
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioTitle = "recording\(UUID()).wav"
        var url = documentURL.appendingPathComponent(audioTitle)
        do {
            let file = try AVAudioFile(forWriting:url, settings: mixer.outputFormat(forBus: 0).settings)
            do {
                try file.write(from: samples.convertToPCMBuffer(for: audioFormat)!)
                let test = samples.convertToPCMBuffer(for: audioFormat)!
                print("Audio Format \(audioFormat)")
                print("Test is a buffer")
                print("test.frameLength \(test.frameLength)")
                print("test.format \(test.format)")
                print("test.frameCapacity \(test.frameCapacity)")
                print("test.stride \(test.stride)")
                print("file is a file")
                print("file.fileFormat \(file.fileFormat)")
                print("file.length \(file.length)")
                print("file.processingFormat \(file.processingFormat)")
                let test2 = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(file.length) )
                print("AVAudioFrameCount(file.length) \(AVAudioFrameCount(file.length))")
                print("Test2 is a buffer")
                print("test2.frameLength \(test2!.frameLength)")
                print("test2.format \(test2!.format)")
                print("test2.frameCapacity \(test2!.frameCapacity)")
                print("test2.stride \(test2!.stride)")
                //file.read(into: <#T##AVAudioPCMBuffer#>)
                print("samples.count \(samples.count)")
                service.createAudio(url: audioTitle)
            } catch {
                print(error)
            }
            audioFile = file
        } catch {
            print(error)
        }
        
        //Saving Json
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("json-Rec-\(UUID()).json")

            try jsonData.write(to: fileURL)
        } catch {
            print(error)
        }
        return audioTitle
    }
    func savePlay(jsonArray: [[String: Any]]){
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("json-Play-\(UUID()).json")

            try jsonData.write(to: fileURL)
        } catch {
            print(error)
        }
    }
    
    func saveJsonBufferPlay(jsonBuffer: [Any]){
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonBuffer, options: .prettyPrinted)
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("json-Play-Buffer-\(UUID()).json")

            try jsonData.write(to: fileURL)
        } catch {
            print(error)
        }
    }
    func saveJsonBufferRec(jsonBuffer: [Any]){
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonBuffer, options: .prettyPrinted)
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("json-Rec-Buffer-\(UUID()).json")

            try jsonData.write(to: fileURL)
        } catch {
            print(error)
        }
    }
}
