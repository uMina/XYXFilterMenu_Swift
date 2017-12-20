//
//  ViewController.swift
//  XYXFilterMenu_Swift
//
//  Created by Teresa on 2017/12/15.
//  Copyright © 2017年 Teresa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let titles = ["第1列","第2列","第3列","第4列"]
    let source0 = ["第一行","第二行"]
    let source0_0 = ["A","B","C","D","E","F","G"]
    let source0_1 = ["a","b","c","d","e","f","g","h","i","j"]
    let source1 = ["A","B","C","D","E"]
    let source2 = ["a","b","c","d","e","f","g"]
    let source3 = ["第一行","第二行","第三行"]
    let source3_0 = ["A","B"]
    let source3_1 = ["A","B","C","D"]
    let source3_2 = ["A","B","C"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menu = XYXFilterMenu.init(frame: CGRect(x: 0, y: 100, width: XYX_SCREEN_WIDTH, height: 44))
        menu.dataSource = self
        menu.delegate = self
        self.view.addSubview(menu)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController:XYXFilterMenuDataSource{
    func menu(_ menu: XYXFilterMenu, numberOfRowsAt indexPath: XYXFilterIndexPath) -> Int {
        guard indexPath.column != nil else {
            return 0
        }
        switch indexPath.column! {
        case 0:
            return source0.count
        case 1:
            return source1.count
        case 2:
            return source2.count
        case 3:
            return source3.count
        default:
            return 0
        }
    }
    
    func menu(_ menu: XYXFilterMenu, numberOfItemsAt indexPath: XYXFilterIndexPath) -> Int {
        guard indexPath.column != nil && indexPath.row != nil else {
            return 0
        }
        switch indexPath.column! {
        case 0:
            if indexPath.row == 0{
                return source0_0.count
            }else if indexPath.row == 1{
                return source0_1.count
            }
            return 0
            
        case 3:
            if indexPath.row == 0{
                return source3_0.count
            }else if indexPath.row == 1{
                return source3_1.count
            }else if indexPath.row == 2{
                return source3_2.count
            }
            return 0
            
        default:
            return 0
        }
    }
    
    func menu(_ menu: XYXFilterMenu, titleOfRowAt indexPath: XYXFilterIndexPath) -> String {
        let defaultString = ""
        guard indexPath.column != nil && indexPath.row != nil else {
            return defaultString
        }
        switch indexPath.column! {
        case 0:
            return source0[indexPath.row!]
        case 1:
            return source1[indexPath.row!]
        case 2:
            return source2[indexPath.row!]
        case 3:
            return source3[indexPath.row!]
        default:
            return defaultString
        }
    }
    
    func menu(_ menu: XYXFilterMenu, titleOfItemAt indexPath: XYXFilterIndexPath) -> String {
        let defaultString = ""
        guard indexPath.column != nil && indexPath.row != nil && indexPath.item != nil else {
            return defaultString
        }
        if indexPath.column == 0 {
            if indexPath.row == 0 {
                return source0_0[indexPath.item!]
            }else if indexPath.row == 1{
                return source0_1[indexPath.item!]
            }
        }else if indexPath.column == 3 {
            switch indexPath.row!{
            case 0:
                return source3_0[indexPath.item!]
            case 1:
                return source3_1[indexPath.item!]
            case 2:
                return source3_2[indexPath.item!]
            default:
                return defaultString
            }
        }
        return defaultString
    }
    
    //-----------------------------------------------
    
    func numberOfColumns(menu: XYXFilterMenu) -> Int {
        return titles.count
    }
    
    func menu(_ menu: XYXFilterMenu, titleOfColumnAt index: Int) -> String {
        return titles[index]
    }
    
    func menu(_ menu: XYXFilterMenu, typeOfColumn: Int) -> XYXFilterView.ColumnType.RawValue {
        switch typeOfColumn {
        case 0:
            return XYXFilterView.ColumnType.TableViewTwo.rawValue
        case 1...2:
            return XYXFilterView.ColumnType.TableViewOne.rawValue
        default:
            return XYXFilterView.ColumnType.CollectionView.rawValue
        }
    }
    
    func menu(_ menu: XYXFilterMenu, widthOf tableView: UITableView, at column: Int) -> CGFloat {
        if column == 0 {
            if tableView.tag == XYXFilterView.firstTabViewTag{
                return XYX_SCREEN_WIDTH * 0.35
            }else if tableView.tag == XYXFilterView.secondTabViewTag{
                return XYX_SCREEN_WIDTH * 0.65
            }
        }
        return XYX_SCREEN_WIDTH/2
    }
    
    func menu(_ menu: XYXFilterMenu, filterContentHeightAt column: Int) -> CGFloat {
        if column == 3 {
            return XYX_SCREEN_HEIGHT - menu.frame.maxY
        }
        return 300.0
    }
}

extension ViewController:XYXFilterMenuDelegate{
    func menu(_ menu:XYXFilterMenu, tapIndex: Int) {
//        print("被点击的是第\(tapIndex)列")
    }
}

