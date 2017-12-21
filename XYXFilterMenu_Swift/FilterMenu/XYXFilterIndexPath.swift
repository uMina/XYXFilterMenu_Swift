//
//  XYXFilterIndexPath.swift
//  XYXFilterMenu_Swift
//
//  Created by Teresa on 2017/12/15.
//  Copyright © 2017年 Teresa. All rights reserved.
//

import Foundation

class XYXFilterIndexPath: NSObject {
    var column:Int?
    var row:Int?
    var item:Int?
    
    fileprivate convenience init(_ column:Int, _ row:Int?, _ item:Int?) {
        self.init()
        self.column = column
        self.row = row
        self.item = item
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard object is XYXFilterIndexPath else{
            return false
        }
        let newObj = object as! XYXFilterIndexPath
        if self.column == newObj.column && self.row == newObj.row && self.item == newObj.item {
            return true
        }
        return false
    }
    
    override var description: String{
        get{
            return "XYXFilterIndexPath:(column:\(column ?? -1),row:\(row ?? -1),item:\(item ?? -1))"
        }
    }
    
    class func indexOf(_ column:Int, _ row:Int?, _ item:Int?) -> XYXFilterIndexPath{
        let indexPath = XYXFilterIndexPath.init(column, row, item)
        return indexPath
    }
}
