//
//  XYXFilterMenuProtocol.swift
//  XYXFilterMenu_Swift
//
//  Created by Teresa on 2017/12/15.
//  Copyright © 2017年 Teresa. All rights reserved.
//

import Foundation

protocol XYXFilterMenuDataSource:NSObjectProtocol {
    
    func numberOfColumns(menu:XYXFilterMenu) -> Int
    func titleOfColumns(menu:XYXFilterMenu, index:Int) -> String
    
    
}
