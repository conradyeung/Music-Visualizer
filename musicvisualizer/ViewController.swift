//
//  ViewController.swift
//  musicvisualizer
//
//  Created by Conrad Yeung on 2016-03-09.
//  Copyright © 2016 music visualizer. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate {
    var player = SplitterPlayer()
    var displayLink:CADisplayLink!
    var layers:[CALayer]!
    var scale: Float = 1.0
    var select: Int = 0
    var pickerDataSource = ["0-62Hz","63-125Hz","126-250Hz","251-500Hz","501Hz-1kHz","1khz-2kHz","2-4kHz","4-8kHz"];
    @IBOutlet weak var bandPick: UIPickerView!
    @IBOutlet weak var FreqBinSize: UILabel!
    @IBOutlet weak var VolumeSlider: UISlider!
    @IBOutlet weak var SampleRate: UILabel!
    @IBOutlet weak var FileLength: UILabel!
    @IBOutlet weak var FFTSize: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bandPick.dataSource = self;
        self.bandPick.delegate = self;
        // Setup 8 layers for frequency bars.
        let color:CGColorRef = UIColor(red: 0, green: 0.6, blue: 0.8, alpha: 1).CGColor
        layers = [CALayer(), CALayer(), CALayer(), CALayer(), CALayer(), CALayer(), CALayer(), CALayer()]
        for n in 0...7 {
            layers[n].backgroundColor = color
            layers[n].frame = CGRectZero
            self.view.layer.addSublayer(layers[n])
        }
        // A display link call for graph functions
        displayLink = CADisplayLink(target: self, selector: "onDisplayLink")
        displayLink.frameInterval = 1
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    
        //play audio functions
        player.readFilesIntoNodes("tone_3800", file_extension: "wav")
        player.split_audio_into_subnodes()
        player.playNodes()
        
        // Set label text
        SampleRate.text = "Sample Rate: " + String(player.sample_rate!) + " Hz"
        FileLength.text = "File Length: " + String(player.file_length)
        FFTSize.text = "FFT Size: " + String(player.FFT_size)
        FreqBinSize.text = "Frequency Bin Size: " + String(Float(player.sample_rate!)/Float(player.FFT_size)) + " Hz"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderChange(sender: UISlider) {
        //volume scale slider
        scale = Float(sender.value/10.0)
        player.sub_players[select].volume = scale
    }
    func onDisplayLink() {
        // Get the frequency values.
        let frequencies = UnsafeMutablePointer<Float>.alloc(8)
        for i in 0...7{
            //set frequencies as volume and normalize values
            frequencies[i] = player.sub_players[i].volume/20
        }
        // Wrapping the UI changes in a CATransaction block like this prevents animation/smoothing.
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        CATransaction.setDisableActions(true)
        
        // Set the dimension of every frequency bar.
        let originY:CGFloat = self.view.frame.size.height - 160
        let width:CGFloat = (self.view.frame.size.width - 47) / 8
        var frame:CGRect = CGRectMake(20, 0, width, 0)
        for n in 0...7 {
            //print(frequencies[n])
            frame.size.height = CGFloat(frequencies[n]) * 4000
            frame.origin.y = originY - frame.size.height
            layers[n].frame = frame
            frame.origin.x += width + 1
        }
        
        CATransaction.commit()
        frequencies.dealloc(8)
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerDataSource[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        select = row
        print(row)
    }
}

