//
//  ViewController.swift
//  picker
//
//  Created by Colin Treseler on 6/18/18.
//  Copyright © 2018 Colin Treseler. All rights reserved.
//

import UIKit
import Anchorage
import PickerView

class ViewController: UIViewController, PickerViewDelegate, PickerViewDataSource {
    let cameraModes = ["Matt", "Smells", "Like", "Vegemite"]
    func pickerViewNumberOfItems(_ pickerView: PickerView) -> Int {
        return cameraModes.count
    }
    
    func pickerView(_ pickerView: PickerView, itemAtIndex index: Int) -> String {
        return cameraModes[index]
    }
    
    func pickerView(_ pickerView: PickerView, selected index: Int) {
    }

    weak var pickerView: PickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        pickerView = view.add(subview: PickerView(), configure: { (picker, view) in
            picker.centerAnchors == view.centerAnchors
            picker.widthAnchor == view.widthAnchor
            picker.heightAnchor == 40
            picker.itemColor = .white
            picker.delegate = self
            picker.dataSource = self
            picker.select(index: 3, animated: false)
        })
        
        view.add(subview: UIButton(), configure: { (button, view) in
            button.topAnchor == pickerView.bottomAnchor + 20
            button.centerXAnchor == view.centerXAnchor
            button.setTitle("here we are", for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .primaryActionTriggered)
            button.setTitleColor(UIColor.black, for: .normal)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func buttonTapped(_ sender: Any) {
        pickerView.select(index: 2, animated: true)
    }
}

protocol SubviewAddable {}
extension UIView: SubviewAddable {}

extension SubviewAddable where Self: UIView {
    @discardableResult
    func add<Subview: UIView>(subview: Subview, configure: (Subview, Self) -> Void) -> Subview {
        addSubview(subview)
        configure(subview, self)
        return subview
    }
}
