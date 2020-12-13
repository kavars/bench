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
    let opQueue = OperationQueue()
    let logger: SSDLogService = LoggerService()

    var blockCount: Int32 = 0
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        configurator.configure(with: self)
        presenter.configureView()
        
        resetUI()
        
        exportButton.isEnabled = false
        clearButton.isEnabled = false
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
    
    @IBOutlet weak var exportButton: NSButton!
    @IBOutlet weak var clearButton: NSButton!
    
    // MARK: - Actions
    @objc func sliderMoved() {
        presenter.sliderMoved(with: sliderView.intValue)
    }
    
    @IBAction func removeAllBlocks(_ sender: Any) {
        DispatchQueue.global(qos: .utility).async {
            let dirPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("SSDBlocks")
            
            do {
                let blocksURL = try FileManager.default.contentsOfDirectory(at: dirPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                            
                for blockURL in blocksURL {
                    try FileManager.default.removeItem(at: blockURL)
                }
            } catch {
                self.createAndShowErrorAlert(with: "\(error.localizedDescription)\nYou can delete all blocks at ~/Library/Containers/Benchmark/data/SSDBlocks/")
            }
        }
        
        clearButton.isEnabled = false
    }
    
    @IBAction func exportLog(_ sender: Any) {
        let panel = NSSavePanel()
        
        panel.nameFieldStringValue = logger.logFileName
        
        let result = panel.runModal()
        
        switch result {
        case .OK:
            guard let saveURL = panel.url else {
                return
            }
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let fileURL = dir.appendingPathComponent(logger.logFileName)
                
                do {
                    try FileManager.default.moveItem(at: fileURL, to: saveURL)
                } catch {
                    createAndShowErrorAlert(with: "\(error.localizedDescription)\nYou can find log at ~/Library/Containers/Benchmark/data/Documents/\(logger.logFileName)")
                }
            }
        default:
            print("Panel shouldn't be anything other than OK or Cancel")
        }
        
        exportButton.isEnabled = false
    }
    
    @IBAction func startBenchmarkButtonTapped(_ sender: NSButton) {
        
        stopButton.isEnabled = true
        
        exportButton.isEnabled = false
        startButton.isEnabled = false
        writeSpeedLabel.stringValue = "0 mb/s"
        progressIndicator.maxValue = Double(blockCount)
        progressLabel.stringValue = "0/\(blockCount)"
        progressIndicator.doubleValue = 0.0
        progressLabel.isHidden = false
        progressIndicator.isHidden = false
        writeSpeedLabel.isHidden = false
        writeSpeedTitle.isHidden = false

        logger.createLogFileForSSD { (error) in
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = error
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.icon = NSImage(named: NSImage.cautionName)
            alert.runModal()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.resetUI()
                self.endWrite()
                
                // cancel operation
            }
            self.opQueue.cancelAllOperations()
//            return
        }
        
        let blockWriteOperation = BlockWriteOperation(blockCount: self.blockCount) { (index, result, blockTime) in
            
            self.logger.writeSSDLog(index: Int(index) + 1, speed: result, time: blockTime)
            
            self.writeSpeedLabel.stringValue = "\(result) mb/s"
            self.progressLabel.stringValue = "\(index + 1)/\(self.blockCount)"
            self.progressIndicator.doubleValue = Double(index + 1)
        }
        
        blockWriteOperation.completionBlock = {
            if !blockWriteOperation.isCancelled {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.resetUI()
                    self.endWrite()
                }
            }

            self.presenter.configureView()
        }
//        progressIndicator.startAnimation(nil)
        opQueue.addOperation(blockWriteOperation)
    }
    
    @IBAction func stopBenchmarkButtonTapped(_ sender: NSButton) {
        opQueue.cancelAllOperations()
        
        DispatchQueue.main.async {
            self.resetUI()
            self.endWrite()
        }
    }
    
    func resetUI() {
        progressLabel.isHidden = true
        progressIndicator.isHidden = true
        writeSpeedLabel.isHidden = true
        writeSpeedTitle.isHidden = true

        progressLabel.stringValue = ""
        progressIndicator.doubleValue = 0.0
        
//        progressIndicator.stopAnimation(nil)
    }
    
    func endWrite() {
        self.startButton.isEnabled = true
        self.stopButton.isEnabled = false
        self.clearButton.isEnabled = true
        self.exportButton.isEnabled = true
//        progressIndicator.stopAnimation(nil)

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
    
    func createAndShowErrorAlert(with description: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = description
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
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
