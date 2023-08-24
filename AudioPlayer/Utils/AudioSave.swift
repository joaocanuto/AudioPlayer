//
//  AudioSave.swift
//  AudioPlayer
//
//  Created by Joao Guilherme Araujo Canuto on 21/08/23.
//

import Foundation
import AVFAudio

class AudioSave {
    func saveRec(samples: [Float], mixer: AVAudioMixerNode,jsonArray: [[String: Any]]){
        var audioFile:AVAudioFile?
        //Saving Audio
        let audioFormat = mixer.outputFormat(forBus: 0)
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let file = try AVAudioFile(forWriting: documentURL.appendingPathComponent("recording\(UUID()).wav"), settings: mixer.outputFormat(forBus: 0).settings)
            do {
                try file.write(from: samples.convertToPCMBuffer(for: audioFormat)!)
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
