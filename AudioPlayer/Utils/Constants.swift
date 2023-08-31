//
//  Constants.swift
//  AudioPlayer
//
//  Created by Joao Guilherme Araujo Canuto on 21/08/23.
//

import Foundation
import AVFAudio


struct Constants {
    static let bufferSize = 4096
    static let channels = 1
    static let commomFormat = AVAudioCommonFormat.pcmFormatFloat32
    static let sampleRate: Double = 48000.0
}
