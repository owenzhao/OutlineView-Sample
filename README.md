# NSOutlineView Briefing
The new version of [Xliff Tool](https://github.com/owenzhao/Xliff-Tool) needs to use NSOutlineView. However, the official document by Apple is of flaw and the answers on SO are too old. I have to pay nearly a whole afternoon to find out what the right approach is. Here is the briefing.

## Briefing
In fact, Apple does provide a sample project of NSOutlineView. However, that sample is based on cocoa bindings. So if you want to know cocoa bindings. Here is the way.

> [Navigating Hierarchical Data Using Outline and Split Views](https://developer.apple.com/documentation/appkit/cocoa_bindings/navigating_hierarchical_data_using_outline_and_split_views)

Otherwise, welcome to go on.

On Apple's Docs, it says:

> If you are using conventional data sources for content you must implement the basic methods that provide the outline view with data: [outlineView(_:child:ofItem:)](https://developer.apple.com/documentation/appkit/nsoutlineviewdatasource/1528977-outlineview), [outlineView(_:isItemExpandable:)](https://developer.apple.com/documentation/appkit/nsoutlineviewdatasource/1535198-outlineview), [outlineView(_:numberOfChildrenOfItem:)](https://developer.apple.com/documentation/appkit/nsoutlineviewdatasource/1535549-outlineview), and [outlineView(_:objectValueFor:byItem:)](https://developer.apple.com/documentation/appkit/nsoutlineviewdatasource/1531606-outlineview). Applications that acquire their data using Cocoa bindings do not need to implement these methods.

However, if you create a new project with the Xcode 12.4 with Storyboard, the sample you find from SO won't work.

That is because the document is outdated. 

### Steps
1. Create a new project, using Swift and Storyboard.
2. Add a Source List to the view controller.

The result will be look like this.

![outline_view_in_view_controller](https://user-images.githubusercontent.com/2182896/111873727-bea8cf80-89cc-11eb-9c10-2c0219f6563d.png | width=474)

Right click the storyboard and choose "Outline View". You will find the Outline View is View based.

![outline_view_is_view_based_by_default](https://user-images.githubusercontent.com/2182896/111873730-c5cfdd80-89cc-11eb-9e82-eef198fea56f.png | width=360)

That is the reason why Apple's document doesn't work. You need to change View based to Cell based to make it work.


### codes

```swift
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
```

Look at the order number of the function, that is the order the system calls them. 

1. At first, the system asks how many children of root.  
2. Then the system asks you to provide the object that represent the child.
3. Then the system asks you if the child is expandable.
4. Then the system asks you to provide the view/cell of the child.
5. When you click a child, the system goes to step 1, but this time, the child is the new root.

> You should aware that there are two kinds of items. One is `Any?`, the other is `Any`. 
> They are different.
> The `Any?` type is the parent node of the child. For first level cells, item is nil. nil means it is the root.
> The `Any` type is the child.

## References
### [My Sample](https://github.com/owenzhao/OutlineView-Sample/tree/main)
### [Apple's Document Outline View](https://developer.apple.com/documentation/appkit/views_and_controls/outline_view)
### [NSOutlineView example on SO](https://stackoverflow.com/questions/6664898/nsoutlineview-example)
### [Mac OSX 开发基础控件学习之 NSOutlineView](https://www.jianshu.com/p/80772f759989)
