//
//  XYXFilterMenu_ExtraInterface.swift
//  XYXFilterMenu_Swift
//
//  Created by Teresa on 2018/3/5.
//  Copyright © 2018年 Teresa. All rights reserved.
//

extension XYXFilterMenu{
    
    /// 为筛选菜单设定默认选项.
    /// 本方法必须搭配dataSource?.titleOfRows(_:indexPath:)或者dataSource?.titleOfItems(_:indexPath:)使用.
    ///
    /// - Parameters:
    ///   - key: 默认选项的名称.
    ///   - indexPath: 默认选项所在的路径.只能将路径的叶子节点设置为默认选项.例如对于TableViewOne类型的页面,indexPath必须有一个column成员,对于TableViewTwo和Collection类型页面,indexPath必须有column和row成员
    /// - Returns: 设定默认选项是否成功.
    func setDefaultSelection(key:String, indexPath:XYXFilterIndexPath) -> Bool {
        
        let columnType = XYXFilterView.ColumnType(rawValue: (dataSource?.menu(self, typeOfColumn: indexPath.column!))!)
        
        guard columnType != nil && indexPath.column! < titleLayers.count else {
            return false
        }
        
        let setForItem = indexPath.row != nil ? true : false
        
        if setForItem == false && columnType! != .TableViewOne && dataSource == nil{
            return false
        }
        
        var titleArray:[String]?
        if columnType! == .TableViewOne {
            titleArray = dataSource?.titleOfRows?(self, indexPath: indexPath)
            
            if let idx = titleArray?.index(of: key){
                
                selectedTableViewIndexPaths = (selectedTableViewIndexPaths.filter{ path -> Bool in
                    return indexPath.column == path.column ? false : true
                })
                let newIdx = XYXFilterIndexPath.indexOf(indexPath.column!, idx)
                selectedTableViewIndexPaths.append(newIdx)
            }
            
        }else{
            titleArray = dataSource?.titleOfItems?(self, indexPath: indexPath)
            
            if let idx = titleArray?.index(of: key){
                let newIdx = XYXFilterIndexPath.indexOf(indexPath.column!, indexPath.row, idx)
                
                if columnType! == .TableViewTwo{
                    selectedTableViewIndexPaths = (selectedTableViewIndexPaths.filter{ path -> Bool in
                        return indexPath.column == path.column ? false : true
                    })
                    selectedTableViewIndexPaths.append(newIdx)
                    
                }else{
                    
                    selectedCollectionViewIndexPaths = (selectedCollectionViewIndexPaths.filter{ path -> Bool in
                        return indexPath.column == path.column ? false : true
                    })
                    selectedCollectionViewIndexPaths.append(newIdx)
                }
                
            }
        }
        
        if titleArray != nil{
            let titleLayer = titleLayers[indexPath.column!]
            titleLayer.string = key
            self.layoutSublayers(of: titleLayer)
            self.layoutSublayers(of: indicatorLayers[indexPath.column!])
            self.layoutSublayers(of: menuBgLayers[indexPath.column!])
            return true
            
        }else{
            return false
        }
        
    }
}

