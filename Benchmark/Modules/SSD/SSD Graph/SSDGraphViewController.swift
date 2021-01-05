//
//  SSDGraphViewController.swift
//  Benchmark
//
//  Created by Kirill Varshamov on 05.01.2021.
//  Copyright © 2021 Kirill Varshamov. All rights reserved.
//

import Cocoa

class SSDGraphViewController: NSViewController {
    
    let graphStack: NSStackView = {
        let stackView = NSStackView()
        
        stackView.spacing = 3
        stackView.alignment = .bottom
        stackView.distribution = .fill
        stackView.orientation = .horizontal
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func loadView() {        
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(graphStack)
        
        NSLayoutConstraint.activate([
            graphStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            graphStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            graphStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            graphStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
    
    func buildGraph(with csvFile: String) {
//        print(csvFile)
        
        let testData = [
            0.85,
            0.9,
            0.5,
            0.1,
            0.85,
            0.9,
            0.5,
            0.1,
            0.85,
            0.9,
            0.5,
            0.1,
            0.2
        ]
        
        for data in testData {
            let gView = NSView()
            gView.translatesAutoresizingMaskIntoConstraints = false
            gView.wantsLayer = true
            gView.layer?.backgroundColor = NSColor.systemGreen.cgColor
            gView.layer?.cornerRadius = 3
            
            let widthSize = CGFloat((150 - 16 - 16 - 3 * (testData.count - 1)) / testData.count)
            
            print(widthSize) // normal width size = 6
            
            let heightSize = CGFloat((150 - 16 - 16) * data)
            
            let height = gView.heightAnchor.constraint(equalToConstant: 0)
            
            NSLayoutConstraint.activate([
                gView.widthAnchor.constraint(equalToConstant: widthSize),
                height
            ])
            
            graphStack.addArrangedSubview(gView)
            NSAnimationContext.runAnimationGroup { (context) in
                context.duration = 1.0
                height.animator().constant = heightSize
            }

        }
        
        NSAnimationContext.runAnimationGroup { (context) in
            context.duration = 2.0
        } completionHandler: {
//            button.alphaValue = 1.0
        }
    }
}
