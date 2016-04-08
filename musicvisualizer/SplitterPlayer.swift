//
//  SplitterPlayer.swift
//  EqualizerKH
//
//  Created by Kenny Hartwig on 2016-04-07.
//  Copyright © 2016 Kenny Hartwig. All rights reserved.
//

import Foundation
import AVFoundation

class SplitterPlayer : NSObject {
    
    
    //Player to controller the audio
    var audio_engine: AVAudioEngine = AVAudioEngine()
    var master_player: AVAudioPlayerNode = AVAudioPlayerNode()
    var master_buffer: AVAudioPCMBuffer?
    
    var sample_rate: Double?
    var file_length: Int64 = 0
    
    func readFilesIntoNodes( file_name: String, file_extension: String ) {
        
        //Loading the file into a buffer
        let url = NSBundle.mainBundle().URLForResource(file_name, withExtension: file_extension)
        let file = try! AVAudioFile(forReading: url!)
        let format = AVAudioFormat(commonFormat: .PCMFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
        master_buffer = AVAudioPCMBuffer(PCMFormat: format, frameCapacity: UInt32(file.length))
        try! file.readIntoBuffer(master_buffer!)
    
        //Record File Information
        self.sample_rate = file.fileFormat.sampleRate
        self.file_length = file.length
        
        //Connecting player node to the audio engine and starting it
        let mixer = audio_engine.mainMixerNode
        audio_engine.attachNode(master_player)
        audio_engine.connect(master_player, to: mixer, format: format)
        try! audio_engine.start()
        

        //Schedule the node when to start playing
        master_player.scheduleBuffer(master_buffer!, atTime: nil, options: .Loops, completionHandler: nil)
        
        //Initialize Volume
        master_player.volume = 1.0
    }
    
    func playNodes(){
        master_player.play()
    }
    
    //Splits master_buffer into its frequencies
    func split_audio_into_subnodes(){
        print("IN\n")
        let original_data = Array(UnsafeBufferPointer(start: master_buffer!.floatChannelData[0], count:Int(master_buffer!.frameLength)))
        print("floatArray \(original_data)\n")
        
        //Must be a power of two, this is the size of the sample we take of the audio at a time
        let FFT_size = 2048
        
        //Frequencies go from 0 to Fs
        // where Fs = the sample rate of the original audio
        // However, only half the frequencies are useable so we take those values
        let max_freq = self.sample_rate! / 2.0
        
        // Bin size is dependent on the FFT_size and sample rate
        let bin_size = (self.sample_rate!/(Double)(FFT_size))
        
    }
    
    func FFT( audio_data:Array<Float>, bin_size:Float, sample_rate:Double, size:Int){
        
    }
    
}