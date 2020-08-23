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
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        configurator.configure(with: self)
        presenter.configureView()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: - Outlets
    
    // Labels
    
    @IBOutlet weak var allSpaceLabel: NSTextField!
    @IBOutlet weak var usedSpaceLabel: NSTextField!
    @IBOutlet weak var freeSpaceLabel: NSTextField!
    @IBOutlet weak var sliderValueLabel: NSTextField!
    @IBOutlet weak var writeSpeedLabel: NSTextField!
    
    // TextField & Slider
    @IBOutlet weak var inputValueTextField: NSTextField!
    @IBOutlet weak var sliderView: NSSlider!

    // Buttons
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    
    // MARK: - Actions
    
    @objc func sliderMoved() {
        sliderValueLabel.stringValue = String(sliderView.intValue) + " GB"
    }
    
    @IBAction func startBenchmarkButtonTapped(_ sender: NSButton) {
    }
    
    @IBAction func stopBenchmarkButtonTapped(_ sender: NSButton) {
    }
    
    // MARK: - SSDView methods
    func setupSlider(freeSpaceInBytes: Int64, sliderStartValue: Int) {
        sliderView.target = self
        sliderView.action = #selector(sliderMoved)
        
        sliderView.isContinuous = true
                
        sliderView.minValue = 1.0
        sliderView.maxValue = Double(freeSpaceInBytes)
        
        sliderView.intValue = Int32(sliderStartValue)
        sliderValueLabel.stringValue = String(sliderStartValue) + " GB"
    }
    
    func setupDiskSpaceLabels(all: String, used: String, free: String) {
        allSpaceLabel.stringValue = all
        usedSpaceLabel.stringValue = used
        freeSpaceLabel.stringValue = free
    }
    
    func setupButtons() {
        stopButton.isEnabled = false
    }
    
    func setupInputTextField() {
        inputValueTextField.delegate = self
    }
}

extension SSDViewController: NSTextFieldDelegate {
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        self.sliderValueLabel.stringValue = fieldEditor.string + " GB"
        self.sliderView.intValue = Int32(fieldEditor.string) ?? 0
        
        return true
    }
}
