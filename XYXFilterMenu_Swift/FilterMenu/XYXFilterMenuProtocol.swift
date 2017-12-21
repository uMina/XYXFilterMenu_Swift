//
//  XYXFilterMenuProtocol.swift
//  XYXFilterMenu_Swift
//
//  Created by Teresa on 2017/12/15.
//  Copyright © 2017年 Teresa. All rights reserved.
//

import Foundation
import UIKit

@objc protocol XYXFilterMenuDataSource : NSObjectProtocol {
    
    //关于MenuBar
    func numberOfColumns(menu:XYXFilterMenu) -> Int
    func menu(_ menu:XYXFilterMenu, titleOfColumnAt index:Int) -> String
    
    //关于页面设定
    func menu(_ menu:XYXFilterMenu,typeOfColumn:Int) -> XYXFilterView.ColumnType.RawValue

    @objc optional func menu(_ menu:XYXFilterMenu,widthOf tableView:UITableView, at column:Int) -> CGFloat
    @objc optional func menu(_ menu:XYXFilterMenu,filterContentHeightAt column:Int) -> CGFloat
    
    //关于获取显示数据
    @objc optional func menu(_ menu:XYXFilterMenu, numberOfRowsAt indexPath:XYXFilterIndexPath) -> Int
    @objc optional func menu(_ menu:XYXFilterMenu, titleOfRowAt indexPath:XYXFilterIndexPath) -> String
    
    @objc optional func menu(_ menu:XYXFilterMenu, numberOfItemsAt indexPath:XYXFilterIndexPath) -> Int
    @objc optional func menu(_ menu:XYXFilterMenu, titleOfItemAt indexPath:XYXFilterIndexPath) -> String
    
    @objc optional func menu(_ menu: XYXFilterMenu, shouldChange title: String, for IndexPath: XYXFilterIndexPath) -> String? 
    
    //用于统计数据
    @objc optional func statistic(_ menu: XYXFilterMenu, tableView valueT:[XYXFilterIndexPath],collectionView valueC:[XYXFilterIndexPath])
    @objc optional func submit(_ menu: XYXFilterMenu, tableView valueT:[XYXFilterIndexPath],collectionView valueC:[XYXFilterIndexPath])
    
}

@objc protocol XYXFilterMenuDelegate : NSObjectProtocol {
    
    @objc optional func menu(_ menu:XYXFilterMenu,tapIndex:Int)
    
}
