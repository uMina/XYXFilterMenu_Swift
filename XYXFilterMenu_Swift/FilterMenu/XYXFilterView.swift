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
        tableView.register(XYXFilterViewTableViewCell.classForCoder(), forCellReuseIdentifier: XYXFilterViewTableViewCell.reuseIdentifier())
        return tableView
    }()
    private let secondTableView:UITableView = {
        let tableView = UITableView()
        tableView.tag = XYXFilterView.secondTabViewTag
        tableView.tableFooterView = UIView()
        tableView.register(XYXFilterViewTableViewCell.classForCoder(), forCellReuseIdentifier: XYXFilterViewTableViewCell.reuseIdentifier())
        return tableView
    }()
    private let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsSelection = false
        collectionView.allowsMultipleSelection = true
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
    
    private lazy var annexView:XYXFilterAnnexView = {
        let view = XYXFilterAnnexView.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50.0))
        view.clearBtnCallback = {
            self.menu?.selectedCollectionViewIndexPaths.removeAll()
            self.collectionView.reloadData()
            self.resetCurrentSelectedIndexPath()
        }
        
        view.confirmBtnCallback = {
            
            let title = (self.menu?.selectedCollectionViewIndexPaths.count)! > 0 ? "更多" : (self.dataSource?.menu(self.menu!, titleOfColumnAt: self.currentSelectedColumn) ?? nil)
            let index = XYXFilterIndexPath.indexOf(self.currentSelectedColumn, nil, nil)
            self.menu?.closeFilter(with: title, at: index)
            self.statisticResult()
            self.submitResult()
            self.resetCurrentSelectedIndexPath()
        }
        
        return view
        
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
        
        secondTableView.backgroundColor = MENU_BG_COLOR_DEFAULT
        collectionView.backgroundColor = MENU_BG_COLOR_DEFAULT
        
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

            if let width = dataSource?.menu?(menu!, widthOf: firstTableView, at: column){
                firstWidth = width
            }
            if let width = dataSource?.menu?(menu!, widthOf: secondTableView, at: column){
                secondWidth = width
            }
            firstTableView.frame = CGRect(x: bounds.minX, y: bounds.minY, width: firstWidth, height: height)
            secondTableView.frame = CGRect(x: floor(firstTableView.frame.maxX), y: bounds.minY, width: ceil(secondWidth), height: height)
            addSubview(firstTableView)
            addSubview(secondTableView)
            firstTableView.reloadData()
            secondTableView.reloadData()
            
        case .CollectionView:
            collectionView.frame = CGRect(x: bounds.minX, y: bounds.minY, width: frame.width, height: height-annexView.frame.height)
            addSubview(collectionView)
            collectionView.reloadData()
            
            annexView.frame = CGRect(x: bounds.minX, y: collectionView.frame.maxY, width: annexView.frame.width, height: annexView.frame.height)
            addSubview(annexView)
            
        }
        
        if let cp = complete{
            cp()
        }
    }
    
    func resetCurrentSelectedIndexPath() {
        print("resetCurrentSelectedIndexPath()被调用了")
        currentSelectedRow = nil
        currentSelectedItem = nil
    }

    fileprivate func currentSelectedIndexPath() -> XYXFilterIndexPath? {
        var theSelectedIndexpath:XYXFilterIndexPath? = nil
        let type = dataSource?.menu(menu!, typeOfColumn: currentSelectedColumn)
   
        if let tn = type, let tt = ColumnType.init(rawValue: tn) {
            switch tt {
            case XYXFilterView.ColumnType.CollectionView:
                for idxPath in menu!.selectedCollectionViewIndexPaths{
                    if idxPath.column == currentSelectedColumn && idxPath.row == currentSelectedRow{
                        theSelectedIndexpath = idxPath
                    }
                }
            case XYXFilterView.ColumnType.TableViewOne:
                for idxPath in menu!.selectedTableViewIndexPaths{
                    if idxPath.column == currentSelectedColumn {
                        theSelectedIndexpath = idxPath
                    }
                }
                theSelectedIndexpath = theSelectedIndexpath ?? XYXFilterIndexPath.indexOf(currentSelectedColumn, 0, 0)
                
            case XYXFilterView.ColumnType.TableViewTwo:
                for idxPath in menu!.selectedTableViewIndexPaths{
                    
                    if idxPath.column == currentSelectedColumn{
                        if currentSelectedRow == nil || currentSelectedRow == idxPath.row {
                            print("---------C")
                            theSelectedIndexpath = idxPath
                        }
                    }
                }
                theSelectedIndexpath = theSelectedIndexpath ?? XYXFilterIndexPath.indexOf(currentSelectedColumn, currentSelectedRow ?? 0, 0)
                
            }
        }else if currentSelectedColumn >= 0 && currentSelectedColumn <= (menu?.titleLayers.count)! {
            print("currentSelectedColumn:\(currentSelectedColumn),意外的。type : \(type!)")
            return currentSelectedIndexPath()
        }
        print("---------D.type : \(type!),\(currentSelectedColumn >= 0),\(currentSelectedColumn <= (menu?.titleLayers.count)!)")
        return theSelectedIndexpath
        
    }

    func clearSelectedData() {
        if self.firstTableView.superview != nil {
            self.firstTableView.reloadData()
        }
        if self.secondTableView.superview != nil {
            self.secondTableView.reloadData()
        }
        if self.collectionView.superview != nil {
            self.collectionView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension XYXFilterView:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        
        let indexPath = currentSelectedIndexPath()!
        
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
       
        var cell = tableView.dequeueReusableCell(withIdentifier: XYXFilterViewTableViewCell.reuseIdentifier())
        if cell == nil {
            cell = XYXFilterViewTableViewCell.init(style: .default, reuseIdentifier: XYXFilterViewTableViewCell.reuseIdentifier())
            cell?.selectionStyle = .none
        }
        
        var title = "未定义"
        if tableView == firstTableView{
            let idxPath = XYXFilterIndexPath.indexOf(currentSelectedColumn, indexPath.row, 0)
            if let newTitle = dataSource?.menu?(menu!, titleOfRowAt: idxPath){
                title = newTitle
            }
        }else if tableView == secondTableView{
            var theRow = currentSelectedRow ?? 0
            if let highlightedIndexPath = currentSelectedIndexPath() {
                theRow = highlightedIndexPath.row!
            }
            let idxPath = XYXFilterIndexPath.indexOf(currentSelectedColumn, theRow, indexPath.row)
            
            if let newTitle = dataSource?.menu?(menu!, titleOfItemAt: idxPath){
                title = newTitle
            }
        }
        cell!.textLabel?.text = title
        
        if let highlightedIndexPath = currentSelectedIndexPath() {
            let type = dataSource?.menu(menu!, typeOfColumn: currentSelectedColumn)
            if type! == XYXFilterView.ColumnType.TableViewTwo.rawValue{
                firstTableView.backgroundColor = MENU_TABLEVIEW_CELL_BG_COLOR_GRAY
            }else{
                firstTableView.backgroundColor = MENU_TABLEVIEW_CELL_BG_COLOR_WHITE
            }
            if tableView == firstTableView {
                if highlightedIndexPath.row == indexPath.row{
                    cell?.isSelected = true
                    cell?.backgroundColor = MENU_TABLEVIEW_CELL_BG_COLOR_WHITE
                }else{
                    cell?.isSelected = false
                    if type! == XYXFilterView.ColumnType.TableViewTwo.rawValue{
                        cell?.backgroundColor = MENU_TABLEVIEW_CELL_BG_COLOR_GRAY
                    }else{
                        cell?.backgroundColor = MENU_TABLEVIEW_CELL_BG_COLOR_WHITE
                    }
                }
                
            }else if tableView == secondTableView{
                if highlightedIndexPath.item == indexPath.row{
                    cell?.isSelected = true
                }else{
                    cell?.isSelected = false
                }
                cell?.backgroundColor = MENU_TABLEVIEW_CELL_BG_COLOR_WHITE
            }
        }
        return cell!
    }
}

extension XYXFilterView:UITableViewDelegate{
    
    func tableViewType(_ type:XYXFilterView.ColumnType, append indexPath:XYXFilterIndexPath) -> Bool {
        var shouldChange = true
        if type == XYXFilterView.ColumnType.TableViewOne {
            menu?.selectedTableViewIndexPaths = (menu?.selectedTableViewIndexPaths.filter{ path -> Bool in
                return indexPath.column == path.column ? false : true
                })!
            menu?.selectedTableViewIndexPaths.append(indexPath)
           
        }else if type == XYXFilterView.ColumnType.TableViewTwo {
            
            menu?.selectedTableViewIndexPaths = (menu?.selectedTableViewIndexPaths.filter{ path -> Bool in
                if indexPath.column == path.column{
                    if indexPath.row != path.row && indexPath.item == 0{
                        //通常不限选项的item==0
                        //当在双列tableView时，如果之前选中了"非不限"选项，再选中相同column而不同row的"不限选项"时，筛选结果不做改变
                        shouldChange = false
                        return true
                    }
                    return false
                }
                return true
                })!
            
            if shouldChange{
                menu?.selectedTableViewIndexPaths.append(indexPath)
            }
        }
        return shouldChange
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let columnType = dataSource?.menu(menu!, typeOfColumn: currentSelectedColumn)
        if columnType == XYXFilterView.ColumnType.TableViewOne.rawValue{
            
            currentSelectedRow = indexPath.row
            let theSelectedIndex = XYXFilterIndexPath.indexOf(currentSelectedColumn, currentSelectedRow, currentSelectedItem)
            let _ = tableViewType(XYXFilterView.ColumnType(rawValue: columnType!)!, append: theSelectedIndex)
            
            let cell = tableView.cellForRow(at: indexPath) as! XYXFilterViewTableViewCell
            menu?.closeFilter(with: cell.textLabel?.text, at: theSelectedIndex)
            
            resetCurrentSelectedIndexPath()
            statisticResult()
            submitResult()
            
        }else if columnType == XYXFilterView.ColumnType.TableViewTwo.rawValue{
            if tableView == firstTableView{
                //切换数据源
                if currentSelectedRow != indexPath.row{
                    currentSelectedRow = indexPath.row
                    firstTableView.reloadData()
                    secondTableView.reloadData()
                }
            }
            else if tableView == secondTableView{
                var theRow:Int = 0
                if let row = currentSelectedRow{
                    theRow = row
                }else{
                    if let path = currentSelectedIndexPath(){
                        theRow = path.row!
                    }
                }
                currentSelectedItem = indexPath.row
                
                let theSelectedIndex = XYXFilterIndexPath.indexOf(currentSelectedColumn, theRow, currentSelectedItem)
                let shouldChange = tableViewType(XYXFilterView.ColumnType(rawValue: columnType!)!, append: theSelectedIndex)
                if shouldChange == true{
                    let cell = tableView.cellForRow(at: indexPath) as! XYXFilterViewTableViewCell
                    menu?.closeFilter(with: cell.textLabel?.text, at: theSelectedIndex)
                }else{
                    menu?.closeFilter(nil)
                }
                resetCurrentSelectedIndexPath()
                statisticResult()
                submitResult()
            }
        }
    }

}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

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
        
        let theIndex = XYXFilterIndexPath.indexOf(currentSelectedColumn, indexPath.section, indexPath.row)
        var isSelected = false
        
        for path in (menu?.selectedCollectionViewIndexPaths)! {
            if path.isEqual(theIndex){
                isSelected = true
                break
            }
        }
        
        if isSelected == true {
            cell.isSelected = isSelected
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.left)
        }

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

extension XYXFilterView:UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let path = XYXFilterIndexPath.indexOf(currentSelectedColumn, indexPath.section, indexPath.item)
        if let size = dataSource?.menu?(menu!, sizeOfCollectionCellAtIndexPath: path){
            let newSize = (size.width == CGSize.zero.width) && (size.height == CGSize.zero.height) ? COLLECTION_CELL_DEFAULT_SIZE : size
            return newSize
        }
        return COLLECTION_CELL_DEFAULT_SIZE
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let path = XYXFilterIndexPath.indexOf(currentSelectedColumn, indexPath.section, indexPath.item)
        if let index = menu?.selectedCollectionViewIndexPaths.index(of: path) {
            menu?.selectedCollectionViewIndexPaths.remove(at: index)
        }
        
        statisticResult()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        currentSelectedRow = indexPath.section
        var shouldAddIndex = true

        if let path = currentSelectedIndexPath() {
            if let index = menu?.selectedCollectionViewIndexPaths.index(of: path) {
                menu?.selectedCollectionViewIndexPaths.remove(at: index)
            }
            if path.item == indexPath.item {
                shouldAddIndex = false
            }
        }

        if shouldAddIndex {
            let theSelectedIndex = XYXFilterIndexPath.indexOf(currentSelectedColumn, indexPath.section, indexPath.item)
            menu?.selectedCollectionViewIndexPaths.append(theSelectedIndex)
        }

        self.collectionView.reloadData()
        
        statisticResult()
    }

}

// MARK: - Submit Data

extension XYXFilterView{
    
    func statisticResult() {
        print("尝试提交数据以供计算")
        print("table:\((menu?.selectedTableViewIndexPaths)!)")
        print("collection:\((menu?.selectedCollectionViewIndexPaths)!)")
        dataSource?.statistic?(menu!, tableView: (menu?.selectedTableViewIndexPaths)!, collectionView: (menu?.selectedCollectionViewIndexPaths)!)
    }
    
    func submitResult() {
        print("提交筛选结果")
        print("table:\((menu?.selectedTableViewIndexPaths)!)")
        print("collection:\((menu?.selectedCollectionViewIndexPaths)!)")
        dataSource?.submit?(menu!, tableView: (menu?.selectedTableViewIndexPaths)!, collectionView: (menu?.selectedCollectionViewIndexPaths)!)
    }
}














