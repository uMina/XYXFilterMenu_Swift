//
//  ViewController.swift
//  XYXFilterMenu_Swift
//
//  Created by Teresa on 2017/12/15.
//  Copyright © 2017年 Teresa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let titles = ["第一列","第2列","第3列","第4列"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menu = XYXFilterMenu.init(frame: CGRect(x: 0, y: 100, width: XYX_SCREEN_WIDTH, height: 44))
        menu.dataSource = self
        self.view.addSubview(menu)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController:XYXFilterMenuDataSource{
    func numberOfColumns(menu: XYXFilterMenu) -> Int {
        return titles.count
    }
    func titleOfColumns(menu: XYXFilterMenu, index:Int) -> String {
        return titles[index]
    }
}

