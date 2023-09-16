//
//  AudioPlayer.swift
//  AudioPlayer
//
// Estrutura:
/// File -----> Player -----> Mixer -----> Delay -----> MainMixer -----> (to speakers)
///
// File:
/// Usamos AVAudioFile. Uma classe que fica responsável por lidar com a escrita e leitura de arquivos de audio. [https://developer.apple.com/documentation/avfaudio/avaudiofile]
/// Escrevemos usando objetos AVAudioPCMBuffer.
/// Esses objetos contem samples como AVAudioCommomFormat.
///
/// AVAudioPCMBuffer: [https://developer.apple.com/documentation/avfaudio/avaudiopcmbuffer]
///     Um objeto que representa um buffer de audio usando PCM audio formats. ( veja AVAudioFormats )
/// AVAudioCommomFormat:
///     .pcmFormatFloat32 -----> 32bits [https://www.sounddevices.com/32-bit-float-files-explained/#:~:text=So%2C%2016%2Dbit%20WAV%20files,%2Dbit%2C%2048%20kHz%20file.]
///
// Nodes:
/// Player : responsável por tocar o audio. [https://developer.apple.com/documentation/avfaudio/avaudioplayernode]
/// MixerNode: responsavel por converter o audio de entrada para MONOPHONIC e para o samples rate 44100.0 Hz. [https://developer.apple.com/documentation/avfaudio/avaudiomixernode]
/// Delay: responsável apenas para sincronizarmos com graficos. Compensar a latencia de renderizar os dados. [https://developer.apple.com/documentation/avfaudio/avaudiounitdelay]
///
// Connections: [https://developer.apple.com/documentation/avfaudio/avaudioengine]
/// AudioEngine permite conectarmos nós especificos a fim de permitir o fluxo de audio e a captação dos sinais de audio.
///
// Sessões: AVAudioSession [https://developer.apple.com/documentation/avfaudio/avaudiosession]
/// Resumidamente, essa classe é resposável por indicar ao dispositivo as intenções do nosso app ( seja gravar, tocar, ....) e permite aplicar configurações e modos para isso.
/// mode: [https://developer.apple.com/documentation/avfaudio/avaudiosession/mode]
/// category: [https://developer.apple.com/documentation/avfaudio/avaudiosession/category]
/// options: [https://developer.apple.com/documentation/avfaudio/avaudiosession/categoryoptions]
// Functions:
/// setupAudio() -> Aplica configurações para tratarmos os dados do audio.
/// play() -> instala o "tap" responsável por monitorar os dados do audio e da inicia o player.
///     Captamos os dados do arquivo, com o "tap",e conseguimos manipula-la com o buffer
/// saveJson() -> salvo alguns dados no json para validar.
///
///
//  Created by Joao Guilherme Araujo Canuto on 21/08/23.
//

import Foundation
import AVFAudio
import AVFoundation
import UIKit

class AudioPlayer{
    var audioUrl : String
    
    var engine: AVAudioEngine!
    //Nodes
    private let player:AVAudioPlayerNode
    private let mixer:AVAudioMixerNode
    private let delay:AVAudioUnitDelay
    
    
    //Data
    var samples: [Float] = []
    var samples2: [Float] = []
    private var jsonArray:[[String:Any]] = []
    private var jsonBuffer:[Float] = []
    //Mesuarement
    public var instantaneousDBA: ((Float?) -> Void)?
    public var maxDBA: ((Float?) -> Void)?
    public var avgDBA: ((Float?) -> Void)?
    public var maxDBAValue: Float = 0.0
    
    //Testes
    private var analiseAudio: AnaliseAudio
    
    @Published var isPlaying = false
    
    //Files
    private var audioFile:AVAudioFile?

    init(analiseAudio: AnaliseAudio, audioUrl: String){
        self.audioUrl = audioUrl
        self.analiseAudio = analiseAudio
        self.engine = AVAudioEngine()
        self.player = AVAudioPlayerNode()
        self.mixer = AVAudioMixerNode()
        self.delay = AVAudioUnitDelay()
    }
    
    private func startEngine() {
        engine.prepare()
        if engine.isRunning {
            return
        }
        
        do {
            try engine.start()
        } catch {
            print(error)
        }
    }
    
    func setupAudio(){
        //SESSION SETUP
//        
//        let session = AVAudioSession.sharedInstance()
//        do {
//            try session.setCategory(.playAndRecord,mode: .measurement,options: .allowBluetooth)
//        } catch { print("Failed to set audioSession category.") }
//
        //ATTACH
        engine.attach(player)
        engine.attach(mixer)
        engine.attach(delay)
                
        //FORMATS
        let playerOutputFormat = player.outputFormat(forBus: 0)
        let mixerOutputFormat = AVAudioFormat(
            commonFormat: Constants.commomFormat,
            sampleRate: playerOutputFormat.sampleRate,
            channels: AVAudioChannelCount(Constants.channels),
            interleaved: false
        )
        
        //CONNECTIONS
        
        engine.connect(player, to: mixer, format: playerOutputFormat)
        engine.connect(mixer, to: delay, format: mixerOutputFormat)
        engine.connect(delay, to: engine.mainMixerNode, format: mixerOutputFormat)
        let delayOutputFormat = delay.outputFormat(forBus: 0)
        print("delayOutputFormat = \(delayOutputFormat)")
        delay.delayTime = 0.0
        delay.feedback = 0.0
        delay.lowPassCutoff = 44100.0/2.0
        delay.wetDryMix = 100
        
        //SCHEDULEFILE
        //var selectedSongURL = Bundle.main.url(forResource: "intro4", withExtension: "wav")
//        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        var url = documentURL.appendingPathComponent(audioUrl)
//        //guard let selectedSongURL = URL(string: url) else {return}
//        do {
//            let audioFile = try AVAudioFile(forReading: url)
//            player.scheduleFile(audioFile, at: nil, completionHandler: nil)
//            print("file is a file")
//            print("file.fileFormat \(audioFile.fileFormat)")
//            print("file.length \(audioFile.length)")
//            print("file.processingFormat \(audioFile.processingFormat)")
//            let test = AVAudioPCMBuffer(pcmFormat: audioFile.fileFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
//            try audioFile.read(into: test!)
//            print("Test is a buffer")
//            print("test.frameLength \(test!.frameLength)")
//            print("test.format \(test!.format)")
//            print("test.frameCapacity \(test!.frameCapacity)")
//            print("test.stride \(test!.stride)")
//            samples2.append(contentsOf: test!.array())
//            print("aaa",samples2.count)
//        } catch {
//            print(error.localizedDescription)
//        }

    }
    
    func play(){
        setupAudio()
        self.avgDBA?( 0 )
        self.instantaneousDBA?(0)
        self.maxDBA?(0)
        if(isPlaying) {
            mixer.removeTap(onBus: 0)
            player.stop()
            isPlaying = false
            //samples = []
            print("Helloo")
            return
        }
        
        //INSTALL TAP
        //mixer.volume = 0
        var cont = 0
        mixer.installTap(onBus: 0,
                         bufferSize: AVAudioFrameCount(Constants.bufferSize),
                         format: nil)
        { [self] buffer, time in
            if(!buffer.array().first!.isEqual(to: 0.0) && cont < 10) {
                cont += 1
                let instantaneousDBA = buffer
                    .array()
                    .applyFilter(.audible)
                    .calculateSoundPressureLevel()
                
                self.instantaneousDBA?(instantaneousDBA)
                
                // calculate avgDBA
                self.samples.append(contentsOf: buffer.array())
                //self.jsonBuffer.append(contentsOf: buffer.array())
                let avgDBA = self.samples
                    .applyFilter(.audible)
                    .calculateSoundPressureLevel()
                
                self.avgDBA?( avgDBA )
                
                // calculate maxDBA
                let maxDBAV = instantaneousDBA > self.maxDBAValue ? instantaneousDBA : self.maxDBAValue
                self.maxDBAValue = instantaneousDBA > self.maxDBAValue ? instantaneousDBA : self.maxDBAValue
                
                self.maxDBA?(self.maxDBAValue )
                
                // Creating JSON:
//                let jsonAudio: [String: Any] = [
//                    "avgDBA": avgDBA ,
//                    "maxDBA": maxDBAV,
//                    "instDBA": instantaneousDBA
//                ]
//                
//                self.jsonArray.append(jsonAudio)
            }
        }
//        if(cont == 10) {
//            player.stop()
//            isPlaying = false
//        }
        startEngine()
        player.play()
        isPlaying = true
    }
    func saveJson(){
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentURL.appendingPathComponent(audioUrl)
        //guard let selectedSongURL = URL(string: url) else {return}
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
            self.jsonBuffer.append(contentsOf: test!.array())
            print("Test is a buffer")
            print("test.frameLength \(test!.frameLength)")
            print("test.format \(test!.format)")
            print("test.frameCapacity \(test!.frameCapacity)")
            print("test.stride \(test!.stride)")
            samples2.append(contentsOf: test!.array())
            print("aaa",samples2.count)
        } catch {
            print(error.localizedDescription)
        }
        var s2: [Float] = []
        for i in 0..<samples2.count{
            s2.append(samples2[i])
            let avgDBA2 = s2
                .applyFilter(.audible)
                .calculateSoundPressureLevel()
            
            let jsonAudio: [String: Any] = [
                "avgDBA": avgDBA2
            ]
            self.jsonArray.append(jsonAudio)
        }
        
//        for i in 0..<samples.count{
//            s.append(samples[i])
//            let avgDBA = s
//                .applyFilter(.audible)
//                .calculateSoundPressureLevel()
////            print(samples2[i])
//            let avgDBA2 = s2
//                .applyFilter(.audible)
//                .calculateSoundPressureLevel()
//
//            print("\(avgDBA) - \(avgDBA2)")
//
        //}
        print("jsonBuffer: \(jsonBuffer.count)")
        analiseAudio.bufferArrayPlay.append(contentsOf: jsonBuffer)
        AudioSave().savePlay(jsonArray: self.jsonArray)
        AudioSave().saveJsonBufferPlay(jsonBuffer: self.jsonBuffer)
    }
    
    
}
