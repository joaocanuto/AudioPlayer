//
//  ACSignal.swift
//  AudioPlayer
//
//  Created by Joao Guilherme Araujo Canuto on 21/08/23.
//
import Foundation
import Accelerate
import AVFAudio

public enum ACFilter {
    case audible
    case custom([[Float]])
    
    fileprivate struct Constants {
        static let audible: [[Float]] = [
            [0.25574113, 0.51148225, 0.25574113, 1.0, -0.14053608, 0.0049376],
            [1.0, -2.0001525, 1.00015251, 1.0, -1.88490122, 0.88642147],
            [1.0, -1.9998475, 0.99984751, 1.0, -1.99413888, 0.99414747]
        ]
    }
    
}

public typealias ACSignal = [Float]

extension ACSignal {
    
    public func applyFilter(_ filter: ACFilter) -> ACSignal {
        let filterConstant = {
            switch filter {
            case .audible:
                return ACFilter.Constants.audible
            case .custom(let signal):
                return signal
            }
        }()
        
        return applySOSFilt(filterConstant)
    }
    
    public func convertToPCMBuffer(for format: AVAudioFormat) -> AVAudioPCMBuffer? {
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(count)) else {
            return nil
        }
        
        buffer.frameLength = AVAudioFrameCount(count)
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        
        // Fill the buffer with samples
        for channel in 0..<Int(format.channelCount) {
            let channelData = buffer.floatChannelData?[channel]
            let stride = buffer.stride
            for sampleIndex in 0..<Int(count) {
                channelData?[sampleIndex * stride] = self[sampleIndex]
            }
        }
        
        return buffer
    }
    
    func calculateSoundPressureLevel() -> Float {
        
        let calibrationFactor: Float = 11.1694
        let calibrationFactorLevel: Float = 20*log10(calibrationFactor)
        
        return self.calculateSoundPressureLevelFromSignalPressure() + calibrationFactorLevel
    }
    
    private func applySOSFilt(_ SOS: [[Float]]) -> ACSignal {
        let filterOrder = SOS.count
        var result: [Float] = self
        
        for index in 0..<filterOrder {
            let BAvector = SOS[index][0...5]
            let feedbacks = [BAvector[3], BAvector[4], BAvector[5]]
            let feedFowards = [BAvector[0], BAvector[1], BAvector[2]]
            result = baFiltSecondOrder(feedFowards: feedFowards, feedbacks: feedbacks, inputSignal: result)
        }
        
        return result
    }
    
    private func calculateSoundPressureLevelFromSignalPressure() -> Float {
        return 20 * log10(vDSP.rootMeanSquare(self)) + 93.97
    }
    
}

public func baFiltSecondOrder(
    feedFowards: [Float],
    feedbacks: [Float],
    inputSignal: [Float]
) -> [Float] {
    let filterCoeff2: [Double] = vDSP.floatToDouble([
        feedFowards[0],
        feedFowards[1],
        feedFowards[2],
        feedbacks[1],
        feedbacks[2]
    ])
    
    var biquadFilter = vDSP.Biquad(
        coefficients: filterCoeff2,
        channelCount: 1,
        sectionCount: 1,
        ofType: Float.self
    )
    
    let signalFiltereds = biquadFilter!.apply(input: inputSignal)
    return(signalFiltereds)
}
