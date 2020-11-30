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
        
//        ssdInfoBlock.layer?.cornerRadius = 10
//        ssdInfoBlock.layer?.masksToBounds = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var ssdInfoBlock: NSTextField!
    // Labels
    
    @IBOutlet weak var allSpaceLabel: NSTextField!
    @IBOutlet weak var usedSpaceLabel: NSTextField!
    @IBOutlet weak var freeSpaceLabel: NSTextField!
    @IBOutlet weak var writeSpeedLabel: NSTextField!
    
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd H:m:ss.SSSS"
        
        DispatchQueue.global().async {
            let data = Data(count: 1024*1024*1024)
            
            for _ in 0..<self.blockCount {
                if self.isStop {
                    break
                }
                do {
                    try data.write(to: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("test/" + dateFormatter.string(from: Date()) + ".data"))
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            self.presenter.configureView()
        }

        
        
    }
    
    @IBAction func stopBenchmarkButtonTapped(_ sender: NSButton) {
        isStop = true
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
