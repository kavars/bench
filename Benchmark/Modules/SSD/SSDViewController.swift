//
//  ViewController.swift
//  Benchmark
//
//  Created by Kirill Varshamov on 23.08.2020.
//  Copyright © 2020 Kirill Varshamov. All rights reserved.
//

import Cocoa

class SSDViewController: NSViewController, SSDViewProtocol {

    // MARK: - Properties
    var presenter: SSDPresenterProtocol!
    let configurator: SSDConfiguratorProtocol = SSDConfigurator()
    
    var isStop: Bool = false
    var blockCount: Int32 = 0
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        configurator.configure(with: self)
        presenter.configureView()
        
        writeSpeedLabel.stringValue = ""
        progressLabel.stringValue = ""
        progressIndicator.doubleValue = 0.0
        progressLabel.isHidden = true
        progressIndicator.isHidden = true
        writeSpeedLabel.isHidden = true
        writeSpeedTitle.isHidden = true
//        ssdInfoBlock.layer?.cornerRadius = 10
//        ssdInfoBlock.layer?.masksToBounds = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var ssdInfoBlock: NSTextField!
    // Labels
    
    @IBOutlet weak var allSpaceLabel: NSTextField!
    @IBOutlet weak var usedSpaceLabel: NSTextField!
    @IBOutlet weak var freeSpaceLabel: NSTextField!
    @IBOutlet weak var writeSpeedLabel: NSTextField!
    
    @IBOutlet weak var writeSpeedTitle: NSTextField!
    // TextField & Slider
    @IBOutlet weak var inputValueTextField: NSTextField!
    @IBOutlet weak var sliderView: NSSlider!

    // Buttons
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    
    // MARK: - Actions
    
    @objc func sliderMoved() {
        presenter.sliderMoved(with: sliderView.intValue)
//        inputValueTextField.stringValue = ""
//        inputValueTextField.placeholderString = "\(sliderView.intValue) GB"
    }
    
    @IBAction func startBenchmarkButtonTapped(_ sender: NSButton) {
        stopButton.isEnabled = true
        isStop = false
        
        writeSpeedLabel.stringValue = "0 mb/s"
        progressIndicator.maxValue = Double(blockCount)
        progressLabel.stringValue = "0/\(blockCount)"
        progressIndicator.doubleValue = 0.0
        progressLabel.isHidden = false
        progressIndicator.isHidden = false
        writeSpeedLabel.isHidden = false
        writeSpeedTitle.isHidden = false

        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "HH-mm-ss"
        logFile = "ssd_test+\(dateFormatter.string(from: Date())).csv"

        let text = "Block;Speed;Time\n"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(logFile)
            
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {print(error.localizedDescription)}
        }
        
        dateFormatter.dateFormat = "y-MM-dd H-m-ss.SSSS"
        
        
        DispatchQueue.global(qos: .userInteractive).async {
            let gb = 1024 * 1024 * 1024
            let data = Data(count: gb)
            
            let dirPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("SSDBlocks")
            
            try? FileManager.default.createDirectory(at: dirPath, withIntermediateDirectories: true, attributes: nil) //
                        
            for i in 0..<self.blockCount {
                let startBlock = Date()
                if self.isStop {
                    break
                }
                do {
                    try data.write(to: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("SSDBlocks/" + dateFormatter.string(from: Date()) + ".data"))
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                let endBlockTime = Date()
                let blockTime = endBlockTime.timeIntervalSince(startBlock)
                
                DispatchQueue.main.async {
                    self.progressLabel.stringValue = "\(i + 1)/\(self.blockCount)"
                    self.progressIndicator.doubleValue = Double(i + 1)
                    
                    let result = Int(1024.0 - Double(gb) * blockTime / 1024.0 / 1024.0 + 1024.0)
                    
                    self.logSSD(index: Int(i) + 1, speed: result, time: blockTime)
                    
                    self.writeSpeedLabel.stringValue = "\(result) mb/s"

                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.progressLabel.isHidden = true
                self.progressIndicator.isHidden = true
                self.progressLabel.stringValue = ""
                self.writeSpeedLabel.isHidden = true
                self.writeSpeedTitle.isHidden = true
                self.progressIndicator.doubleValue = 0.0
            }
            self.presenter.configureView()
        }

        
        
    }
    var logFile = ""
    func logSSD(index: Int, speed: Int, time: Double) {
        DispatchQueue.global(qos: .utility).async {
            let text = "\(index);\(speed);\(time)\n"
            
            let stringData = text.data(using: .utf8)!

            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let fileURL = dir.appendingPathComponent(self.logFile)
                
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(stringData)
                        fileHandle.closeFile()
                    }
                }
            }
        }
    }
    
    @IBAction func stopBenchmarkButtonTapped(_ sender: NSButton) {
        isStop = true
        
        DispatchQueue.main.async {
            self.writeSpeedLabel.isHidden = true
            self.progressLabel.isHidden = true
            self.progressIndicator.isHidden = true
            self.writeSpeedTitle.isHidden = true
            self.writeSpeedLabel.stringValue = ""
            self.progressLabel.stringValue = ""
            self.progressIndicator.doubleValue = 0.0
        }
    }
    
    // MARK: - SSDViewProtocol methods
    func setupSlider(freeSpaceInBytes: Double, sliderStartValue: Int, sliderValueText: String) {
        DispatchQueue.main.async {
            self.sliderView.target = self
            self.sliderView.action = #selector(self.sliderMoved)
            
            self.sliderView.isContinuous = true
                    
            self.sliderView.minValue = 1.0
            self.sliderView.maxValue = freeSpaceInBytes
            
            self.sliderView.integerValue = 1
            
        }
    }
    
    func setupDiskSpaceLabels(all: String, used: String, free: String) {
        DispatchQueue.main.async {
            self.allSpaceLabel.stringValue = all
            self.usedSpaceLabel.stringValue = used
            self.freeSpaceLabel.stringValue = free
        }
    }
    
    func setupButtons() {
        DispatchQueue.main.async {
            self.stopButton.isEnabled = false
        }
    }
    
    func setupInputTextField() {
        DispatchQueue.main.async {
            self.inputValueTextField.delegate = self
        }
    }
    
    func updateSliderTextValue(with textValue: String) {
        DispatchQueue.main.async {
            self.inputValueTextField.stringValue = ""
            self.inputValueTextField.placeholderString = textValue
        }
    }
    
    func updateSliderValue(with intValue: Int32) {
        DispatchQueue.main.async {
            self.sliderView.intValue = intValue
        }
    }
    
    func createAndActivateAlert() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            
            alert.messageText = "Incorrect value"
            alert.informativeText = "Input block size more than 0 and less than free space"
            alert.addButton(withTitle: "OK")
            alert.alertStyle = .warning
            alert.icon = NSImage(named: NSImage.cautionName)
            
            alert.runModal()
        }
    }
}

extension SSDViewController: NSTextFieldDelegate {
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        
        presenter.textFieldUpdated(with: fieldEditor.string, maxValue: self.sliderView.maxValue)
        
        return true
    }
}
