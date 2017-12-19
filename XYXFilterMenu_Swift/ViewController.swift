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
//    func menu(_ menu: XYXFilterMenu, titleOfItemAt indexPath: XYXFilterIndexPath) -> String {
//        <#code#>
//    }
    
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

