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
    
    var currentSelectedColumn:Int = 0
    var currentSelectedRow:Int?
    var currentSelectedItem:Int?
    
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
        collectionView.showsVerticalScrollIndicator = false
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        layout.headerReferenceSize = CGSize(width: XYX_SCREEN_WIDTH, height: 40.0)
        layout.footerReferenceSize = CGSize(width: XYX_SCREEN_WIDTH, height: 1)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        let width = (XYX_SCREEN_WIDTH - 50)/4
        let height:CGFloat = 30
        layout.itemSize = CGSize(width:width, height:height)
        
        collectionView.register(XYXFilterViewCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: XYXFilterViewCollectionViewCell.reuseIdentifier())
        collectionView.register(XYXFilterDefaultHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: XYXFilterDefaultHeaderView.reuseIdentifier())
        collectionView.register(XYXFilterDefaultFooterView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: XYXFilterDefaultFooterView.reuseIdentifier())
        return collectionView
    }()
    
    //MARK: - Life Cycle
    convenience init(menu:XYXFilterMenu) {
        self.init()
        self.menu = menu
        firstTableView.delegate = self
        firstTableView.dataSource = self
        secondTableView.delegate = self
        secondTableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        firstTableView.backgroundColor = backgroundColor
        secondTableView.backgroundColor = backgroundColor
        collectionView.backgroundColor = backgroundColor
        self.clipsToBounds = true
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. And 'self.menu' has to be assigned.")
    }
    
    //MARK: - UI
    func configureUI(column:Int,complete:(()->())?) {
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        //TODO:- 重置被选路径
        resetCurrentSelectedIndexPath()
        
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

    func currentSelectedIndexPath() -> XYXFilterIndexPath? {
        return XYXFilterIndexPath.indexOf(currentSelectedColumn, currentSelectedRow, currentSelectedItem)
    }
    
    func resetCurrentSelectedIndexPath() {
        currentSelectedRow = nil
        currentSelectedItem = nil
    }
}

extension XYXFilterView:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        
        let indexPath = XYXFilterIndexPath.indexOf(currentSelectedColumn, section, nil)
        
        if tableView == firstTableView{
            if let newCount = dataSource?.menu?(menu!, numberOfRowsAt: indexPath){
                count = newCount
            }
        }else if tableView == secondTableView{
            if let newCount = dataSource?.menu?(menu!, numberOfItemsAt: indexPath){
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
        
        var title = "未定义"
        if tableView == firstTableView{
            let idxPath = XYXFilterIndexPath.indexOf(currentSelectedColumn, indexPath.row, 0)
            if let newTitle = dataSource?.menu?(menu!, titleOfRowAt: idxPath){
                title = newTitle
            }
        }else if tableView == secondTableView{
            let idxPath = XYXFilterIndexPath.indexOf(currentSelectedColumn, currentSelectedRow ?? 0, indexPath.row)
            if let newTitle = dataSource?.menu?(menu!, titleOfItemAt: idxPath){
                title = newTitle
            }
        }
        cell!.textLabel?.text = title
        
        return cell!
    }
}

extension XYXFilterView:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let columnType = dataSource?.menu(menu!, typeOfColumn: currentSelectedColumn)
        if columnType == XYXFilterView.ColumnType.TableViewOne.rawValue{
            //TODO: 告知外界某项目被点中了
            currentSelectedRow = indexPath.row
            let theSelectedIndex = XYXFilterIndexPath.indexOf(currentSelectedColumn, currentSelectedRow, currentSelectedItem)
            print("被点击的路径是\(theSelectedIndex)")
            
            print("然后关闭页面，并对选择路径清零")
            resetCurrentSelectedIndexPath()
        }else if columnType == XYXFilterView.ColumnType.TableViewTwo.rawValue{
            if tableView == firstTableView{
                //切换数据源
                currentSelectedRow = indexPath.row
                secondTableView.reloadData()
            }
            else if tableView == secondTableView{
            //TODO: 告知外界某项目被点中了
                currentSelectedItem = indexPath.row
                let theSelectedIndex = XYXFilterIndexPath.indexOf(currentSelectedColumn, currentSelectedRow ?? 0, currentSelectedItem)
                print("被点击的路径是\(theSelectedIndex)")
                
                print("然后关闭页面，并对选择路径清零")
                resetCurrentSelectedIndexPath()
            }
        }
    
        
    }

}

extension XYXFilterView:UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        var count = 0
        let idxPath = XYXFilterIndexPath.indexOf(currentSelectedColumn, nil, nil)
        if let newCount = dataSource?.menu?(menu!, numberOfRowsAt: idxPath){
            count = newCount
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        let idxPath = XYXFilterIndexPath.indexOf(currentSelectedColumn, section, nil)
        if let newCount = dataSource?.menu?(menu!, numberOfItemsAt: idxPath){
            count = newCount
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: XYXFilterViewCollectionViewCell.reuseIdentifier(), for: indexPath) as! XYXFilterViewCollectionViewCell
        var title = "未定义"
        let idxPath = XYXFilterIndexPath.indexOf(currentSelectedColumn, indexPath.section, indexPath.row)
        if let newTitle = dataSource?.menu?(menu!, titleOfItemAt: idxPath) {
            title = newTitle
        }
        cell.textLabel.text = title
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind:UICollectionElementKindSectionHeader,  withReuseIdentifier: XYXFilterDefaultHeaderView.reuseIdentifier(), for: indexPath) as! XYXFilterDefaultHeaderView
            var title = "未定义"
            let idxPath = XYXFilterIndexPath.indexOf(currentSelectedColumn, indexPath.section, nil)
            if let newTitle = dataSource?.menu?(menu!, titleOfRowAt: idxPath){
                title = newTitle
            }
            headerView.titleLabel.text = title
            headerView.layoutIfNeeded()
            return headerView
            
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind:UICollectionElementKindSectionFooter,  withReuseIdentifier: XYXFilterDefaultFooterView.reuseIdentifier(), for: indexPath)
            return footerView
            
        default:
            return UICollectionReusableView.init(frame: CGRect.zero)
        }
    }
    
    
}

extension XYXFilterView:UICollectionViewDelegate{

}

