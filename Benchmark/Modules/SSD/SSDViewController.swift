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

    var blockCount: Int32 = 0 // move to interactor
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        configurator.configure(with: self)
        presenter.configureView()
    }
    
    // MARK: - Outlets
    
    // Labels
    @IBOutlet weak var allSpaceLabel: NSTextField!
    @IBOutlet weak var usedSpaceLabel: NSTextField!
    @IBOutlet weak var freeSpaceLabel: NSTextField!
    @IBOutlet weak var writeSpeedLabel: NSTextField!
    @IBOutlet weak var writeSpeedTitle: NSTextField!
    @IBOutlet weak var progressLabel: NSTextField!

    // Others
    @IBOutlet weak var inputValueTextField: NSTextField!
    @IBOutlet weak var sliderView: NSSlider!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!

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
                self.createAndShowErrorAlert(with: "\(error.localizedDescription)\n\nYou can delete all blocks at ~/Library/Containers/Benchmark/data/SSDBlocks/")
            }
            
            self.presenter.updateUI()
        }
        
        clearButton.isEnabled = false
    }
    
    @IBAction func exportLog(_ sender: Any) {
//        let panel = NSSavePanel()
//
//        panel.nameFieldStringValue = logger.logFileName
//
//        let result = panel.runModal()
//
//        switch result {
//        case .OK:
//            guard let saveURL = panel.url else {
//                return
//            }
//
//            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//
//                let fileURL = dir.appendingPathComponent(logger.logFileName)
//
//                do {
//                    try FileManager.default.moveItem(at: fileURL, to: saveURL)
//                } catch {
//                    createAndShowErrorAlert(with: "\(error.localizedDescription)\nYou can find log at ~/Library/Containers/Benchmark/data/Documents/\(logger.logFileName)")
//                }
//            }
//        default:
//            print("Panel shouldn't be anything other than OK or Cancel")
//        }
//
//        exportButton.isEnabled = false
    }
    
    @IBAction func startBenchmarkButtonTapped(_ sender: NSButton) {
        presenter.startButtonTapped()
    }
    
    @IBAction func stopBenchmarkButtonTapped(_ sender: NSButton) {
        presenter.stopButtonTapped()
    }
    
    // MARK: - SSDViewProtocol methods
    func setupSlider(freeSpaceInBytes: Double) { // , sliderStartValue: Int, sliderValueText: String) {
        DispatchQueue.main.async {
            self.sliderView.target = self
            self.sliderView.action = #selector(self.sliderMoved)
            
            self.sliderView.isContinuous = true
                    
            self.sliderView.minValue = 1.0
            self.sliderView.maxValue = freeSpaceInBytes
            
            self.sliderView.integerValue = 1
            
        }
    }
    
    func updateSlider(freeSpaceInBytes: Double) {
        self.sliderView.maxValue = freeSpaceInBytes
        
        self.sliderView.integerValue = 1
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
            self.exportButton.isEnabled = false
            self.clearButton.isEnabled = false
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
    
    func resetUI() {
        DispatchQueue.main.async {
            self.progressLabel.isHidden = true
            self.progressIndicator.isHidden = true
            self.writeSpeedLabel.isHidden = true
            self.writeSpeedTitle.isHidden = true

            self.progressLabel.stringValue = ""
            self.progressIndicator.doubleValue = 0.0
        
        }
    }
    
    func endWrite() {
        DispatchQueue.main.async {
            self.startButton.isEnabled = true
            self.stopButton.isEnabled = false
            self.clearButton.isEnabled = true
            self.exportButton.isEnabled = true
        }
    }
    
    func changeUIForStart(blockCount: Int32) {
        DispatchQueue.main.async {
            self.stopButton.isEnabled = true
            
            self.exportButton.isEnabled = false
            self.startButton.isEnabled = false
            self.writeSpeedLabel.stringValue = "0 mb/s"
            self.progressIndicator.maxValue = Double(blockCount)
            self.progressLabel.stringValue = "0/\(blockCount)"
            self.progressIndicator.doubleValue = 0.0
            self.progressLabel.isHidden = false
            self.progressIndicator.isHidden = false
            self.writeSpeedLabel.isHidden = false
            self.writeSpeedTitle.isHidden = false
        }
    }
    
    func updateWriteSpeed(_ speed: String) {
        DispatchQueue.main.async {
            self.writeSpeedLabel.stringValue = speed
        }
    }
    
    func updateProgress(_ label: String, _ indicator: Double) {
        DispatchQueue.main.async {
            self.progressLabel.stringValue = label
            self.progressIndicator.doubleValue = indicator
        }
    }
}

extension SSDViewController: NSTextFieldDelegate {
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        
        presenter.textFieldUpdated(with: fieldEditor.string, maxValue: self.sliderView.maxValue)
        
        return true
    }
    
    func controlTextDidChange(_ obj: Notification) {
        presenter.textFieldUpdated(with: self.inputValueTextField.stringValue, maxValue: self.sliderView.maxValue)
    }
}
