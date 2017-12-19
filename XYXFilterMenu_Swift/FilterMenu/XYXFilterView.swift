//
//  XYXFilterView.swift
//  XYXFilterMenu_Swift
//
//  Created by Teresa on 2017/12/18.
//  Copyright © 2017年 Teresa. All rights reserved.
//

import Foundation
import UIKit

class XYXFilterView: UIView {
    
    enum ColumnType : Int {
        case TableViewOne = 0
        case TableViewTwo
        case CollectionView
    }
    
    var dataSource:XYXFilterMenuDataSource?
    var delegate:XYXFilterMenuDelegate?
    var menu:XYXFilterMenu?
    
    static let firstTabViewTag = 301
    static let secondTabViewTag = 302
    
    // 带默认数据的设定值
    var preUnfoldHeight:CGFloat = 300
    var unfoldHeight:CGFloat = 300
    var currentSelectedColumn:Int = -1
    
    var unfoldHeightChanged:Bool{
        get{
            return preUnfoldHeight == unfoldHeight ? false : true
        }
    }
    
    // UI
    private let firstTableView:UITableView = {
        let tableView = UITableView()
        tableView.tag = XYXFilterView.firstTabViewTag
        tableView.tableFooterView = UIView()
        return tableView
    }()
    private let secondTableView:UITableView = {
        let tableView = UITableView()
        tableView.tag = XYXFilterView.secondTabViewTag
        tableView.tableFooterView = UIView()
        return tableView
    }()
    private let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        // Set collectionView
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
//        collectionView.bounces = false
        // Set layout
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let width = XYX_SCREEN_WIDTH - 30
        let height = width / 7 * 2 - 1
        layout.itemSize = CGSize(width:width, height:height)
        return collectionView
    }()
    
    //MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        firstTableView.delegate = self
        firstTableView.dataSource = self
        secondTableView.delegate = self
        secondTableView.dataSource = self
        firstTableView.backgroundColor = backgroundColor
        secondTableView.backgroundColor = backgroundColor
        collectionView.backgroundColor = backgroundColor
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI
    func configureUI(column:Int,complete:(()->())?) {
        guard menu != nil else {
            return
        }
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        currentSelectedColumn = column
        let columnType = dataSource?.menu(menu!, typeOfColumn: column)
        
        var height:CGFloat = unfoldHeight
        if let newHeight = dataSource?.menu?(menu!, filterContentHeightAt: column){
            height = newHeight
            preUnfoldHeight = unfoldHeight
            unfoldHeight = newHeight
        }
        
        switch ColumnType.init(rawValue: columnType!)! {
        case .TableViewOne:
            firstTableView.frame = CGRect(x: bounds.minX, y: bounds.minY, width: frame.width, height: height)
            addSubview(firstTableView)
            firstTableView.reloadData()
            
        case .TableViewTwo:
            var firstWidth = frame.width/2
            var secondWidth = frame.width/2

            if let width = dataSource?.menu!(menu!, widthOf: firstTableView, at: column){
                firstWidth = width
            }
            if let width = dataSource?.menu!(menu!, widthOf: secondTableView, at: column){
                secondWidth = width
            }
            firstTableView.frame = CGRect(x: bounds.minX, y: bounds.minY, width: firstWidth, height: height)
            secondTableView.frame = CGRect(x: floor(firstTableView.frame.maxX), y: bounds.minY, width: ceil(secondWidth), height: height)
            addSubview(firstTableView)
            addSubview(secondTableView)
            firstTableView.reloadData()
            secondTableView.reloadData()
            
        case .CollectionView:
            collectionView.frame = CGRect(x: bounds.minX, y: bounds.minY, width: frame.width, height: height)
            addSubview(collectionView)
            collectionView.reloadData()
        }
        
        if let cp = complete{
            cp()
        }
    }

}

extension XYXFilterView:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        
        let indexPath = XYXFilterIndexPath.indexOf(currentSelectedColumn, 0, 0)
        
        if tableView == firstTableView{
            if let newCount = dataSource?.menu?(menu!, numberOfItemsAt: indexPath){
                count = newCount
            }
        }else if tableView == secondTableView{
            if let newCount = dataSource?.menu?(menu!, numberOfLeafsAt: indexPath){
                count = newCount
            }
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "test")
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "test")
        }
        
        var newTitle = "未定义"
        
        let indexPath = XYXFilterIndexPath.indexOf(currentSelectedColumn, 0, 0)
        if tableView == firstTableView{
            if let title = dataSource?.menu?(menu!, titleOfItemAt: indexPath){
                newTitle = title
            }
        }else if tableView == secondTableView{
            if let title = dataSource?.menu?(menu!, titleOfLeafAt: indexPath){
                newTitle = title
            }
        }
        cell!.textLabel?.text = newTitle
        
        return cell!
    }
}

extension XYXFilterView:UITableViewDelegate{
    
}
