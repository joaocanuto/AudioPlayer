//
//  AudioRecorder.swift
//  AudioPlayer
// Estrutura:
/// Microphone -----> Mixer -----> MixerAux -----> MainMixer -----> (to speakers)
// Nodes:
/// Mixer :  responsavel por converter o audio de entrada para MONOPHONIC e para o samples rate 44100.0 Hz. [https://developer.apple.com/documentation/avfaudio/avaudiomixernode]
/// MixerAux : possuio configurações essenciais para evitar que o audio "vaze".
/// MainMixer : usado para linkar o audio input com a audio engine.
///
// Connections: [https://developer.apple.com/documentation/avfaudio/avaudioengine]
/// AudioEngine permite conectarmos nós especificos a fim de permitir o fluxo de audio e a captação dos sinais de audio.
///
// Sessões: AVAudioSession [https://developer.apple.com/documentation/avfaudio/avaudiosession]
/// Resumidamente, essa classe é resposável por indicar ao dispositivo as intenções do nosso app ( seja gravar, tocar, ....) e permite aplicar configurações e modos para isso.
/// mode: [https://developer.apple.com/documentation/avfaudio/avaudiosession/mode]
/// category: [https://developer.apple.com/documentation/avfaudio/avaudiosession/category]
/// options: [https://developer.apple.com/documentation/avfaudio/avaudiosession/categoryoptions]
/// // Functions:
/// setupAudio() -> Aplica configurações para tratarmos os dados do audio.
/// startRecording() -> instala o "tap" responsável por gravar e monitorar os dados do audio e da inicia o gravação.
///     Captamos os dados da gravação, com o "tap",e conseguimos manipula-la com o buffer.
/// saveJson() -> salvo alguns dados no json para validar.
//  Created by Joao Guilherme Araujo Canuto on 21/08/23.
//

import Foundation
import AVFAudio


class AudioRecorder : ObservableObject {
    var engine: AVAudioEngine!
    //Nodes
    private var mic: AVAudioInputNode
    private let mixer = AVAudioMixerNode()
    private let mixerAux = AVAudioMixerNode()
    //Data
    var samples: [Float] = []
    private var jsonArray:[[String:Any]] = []
    private var jsonBuffer:[Any] = []
    //Mesuarement
    public var instantaneousDBA: ((Float?) -> Void)?
    public var maxDBA: ((Float?) -> Void)?
    public var avgDBA: ((Float?) -> Void)?
    public var maxDBAValue: Float = 0.0
    
    private var isRecording = false
    
    //Files
    private var audioFile:AVAudioFile?

    // Testes
    private var analiseAudio:AnaliseAudio
    
    init(analiseAudio: AnaliseAudio){
        self.analiseAudio = analiseAudio
        self.engine = AVAudioEngine()
        self.mic = engine.inputNode
        setupAudio()
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
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record,mode: .measurement,options: .allowBluetooth)
        } catch { print("Failed to set audioSession category.") }
        
        //ATTACH
        
        engine.attach(mixer)
        engine.attach(mixerAux)
        
        
        //FORMATS
        let micFormat = mic.inputFormat(forBus: 0)
        let mixerOutputFormat = AVAudioFormat(
            commonFormat: Constants.commomFormat,
            sampleRate: Constants.sampleRate,
            channels: AVAudioChannelCount(Constants.channels),
            interleaved: false
        )
        
        //CONNECTIONS
        
        engine.connect(mic, to: mixer, format: micFormat)
        engine.connect(mixer, to: mixerAux, format: mixerOutputFormat)
        engine.connect(mixerAux, to: engine.mainMixerNode, format: mixerOutputFormat)
        mixerAux.volume = 0.0
    }
    
    func startRecording(){
        //INSTALL TAP
        mixer.installTap(onBus: 0,
                         bufferSize: AVAudioFrameCount(Constants.bufferSize),
                         format: nil)
        { buffer, time in
            if(!buffer.array().first!.isEqual(to: 0.0)) {
        
                let instantaneousDBA = buffer
                    .array()
                    .applyFilter(.audible)
                    .calculateSoundPressureLevel()
                
                self.instantaneousDBA?(instantaneousDBA)
                
                // calculate avgDBA
                self.samples.append(contentsOf: buffer.array())
                self.jsonBuffer.append(contentsOf: buffer.array())
                let avgDBA = self.samples
                    .applyFilter(.audible)
                    .calculateSoundPressureLevel()
                
                self.avgDBA?( avgDBA )
                
                // calculate maxDBA
                let maxDBAV = instantaneousDBA > self.maxDBAValue ? instantaneousDBA : self.maxDBAValue
                self.maxDBAValue = instantaneousDBA > self.maxDBAValue ? instantaneousDBA : self.maxDBAValue
                
                self.maxDBA?(self.maxDBAValue )
                
                // Creating JSON:
                let jsonAudio: [String: Any] = [
                    "avgDBA": avgDBA ,
                    "maxDBA": maxDBAV,
                    "instDBA": instantaneousDBA
                ]
                
                self.jsonArray.append(jsonAudio)
                print("Hello")
            }
        }
        startEngine()
    }
    func stopRecording(){
        mixer.removeTap(onBus: 0)
        isRecording = false
    }
    
    func save(){
        let audioSave = AudioSave()
        print("samples.capacity: \(samples.count)")
        print("jsonBuffer: \(jsonBuffer.count)")
        analiseAudio.bufferArrayRec.append(contentsOf: jsonBuffer)
        audioSave.saveRec(samples: samples, mixer: mixer,jsonArray: jsonArray)
        audioSave.saveJsonBufferRec(jsonBuffer: jsonBuffer)
    }
}
