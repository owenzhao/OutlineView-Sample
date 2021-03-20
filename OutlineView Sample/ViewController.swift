//
//  ViewController.swift
//  OutlineView Sample
//
//  Created by zhaoxin on 2021/3/20.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var outlineView: NSOutlineView!
    
    private let cats:[String] = {
        (1...3).map {
            return String(format: "cat%02d", $0)
        }
    }()
    
    private let dogs:[String] = {
        (1...4).map {
            return String(format: "dog%02d", $0)
        }
    }()
    
    lazy private var animals = [cats, dogs]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController:NSOutlineViewDataSource {
    // 2
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return animals[index]
        }
        
        if let list = item as? [String] {
            return list[index]
        }
        
        return item as! String
    }
    
    // 3
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is [String] {
            return true
        }
        
        return false
    }
    
    // 1
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return animals.count
        }
        
        if let list = item as? [String] {
            return list.count
        }
        
        return 0
    }
    
    // 4
    // This function only works with Cell based Outline Views.
//    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
//
//        if item is [String] {
//            let row = outlineView.row(forItem: item)
//
//            if row == 0 {
//                return "cats"
//            }
//
//            return "dogs"
//        }
//
//        return item as! String
//    }
}

extension ViewController:NSOutlineViewDelegate {
    // 4
    // This function only works with View based Outline Views.
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let view:NSTableCellView!

        if item is [String] {
            view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("HeaderCell"), owner: self) as? NSTableCellView

            let row = outlineView.row(forItem: item)

            if row == 0 {
                view.textField?.stringValue = "cats"
            } else {
                view.textField?.stringValue = "dogs"
            }
        } else {
            view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("DataCell"), owner: self) as? NSTableCellView
            view.textField?.stringValue = item as! String
        }

        return view
    }
}
