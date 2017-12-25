//
//  XYXFilterMenu.swift
//  XYXFilterMenu_Swift
//
//  Created by Teresa on 2017/12/15.
//  Copyright © 2017年 Teresa. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class XYXFilterMenu: UIView {
    
    //MARK: - Member
    var delegate:XYXFilterMenuDelegate?{
        didSet{
            filterView.delegate = delegate
        }
    }
    var dataSource:XYXFilterMenuDataSource?{
        didSet{
            configureMenuBar()
            filterView.dataSource = dataSource
        }
    }
    
    lazy var filterView:XYXFilterView = {
        let filter = XYXFilterView(menu: self)
        return filter
    }()
    
    let backGroundView = UIView()
    
    var selectedTableViewIndexPaths:[XYXFilterIndexPath] = []
    var selectedCollectionViewIndexPaths:[XYXFilterIndexPath] = []
    
    // 关于设定的各种参数（几乎可以不变的）
    var numOfMenu = 1
    var menuBarBGColorDefault = MENU_BG_COLOR_DEFAULT
    var menuBarBGColorSelected = MENU_BG_COLOR_DEFAULT
    var menuBarColorDefault = MENU_TITLE_COLOR_DEFAULT
    var menuBarColorSelected = MENU_TITLE_COLOR_SELECTED
    
    let animateDurationShort = 0.2
    let animateDuration = 0.25
    
    var menuTitleFontSize:CGFloat = 14
    var menuTitleMargin:CGFloat = 20
    var menuTitleTruncation = kCATruncationEnd
    var graySpaceHeight:CGFloat = 300
    
    // 关于设定的数据存储（肯定会发生改变的）
    var titleLayers:[CATextLayer] = []
    var indicatorLayers:[CAShapeLayer] = []
    var menuBgLayers:[CALayer] = []
    
    var currentSelectedColumn:Int = -1
    
    // 关于动画展示的参数
    var isDisplayed = false
    
    //MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureBaseSetting()
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(menuTapped(tapGesture:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - fileprivate Configuration
    
    fileprivate func configureMenuBar() {
        //初始化菜单栏
        numOfMenu = (dataSource?.numberOfColumns(menu: self))!
        let textLayerInterval = self.frame.size.width / CGFloat(numOfMenu * 2)
        let bgLayerInterval = self.frame.size.width / CGFloat(numOfMenu)
        
        var tempBgLayers:[CALayer] = []
        var tempTitles:[CATextLayer] = []
        var tempIndicators:[CAShapeLayer] = []
        
        for idx in 0...(numOfMenu-1) {
            //bgLayer            
            let bgLayerPosition = CGPoint(x:(CGFloat(idx)+0.5)*bgLayerInterval, y:self.frame.height/2)
            let bgLayer = createBgLayer(color: self.menuBarBGColorDefault, position: bgLayerPosition)
            self.layer.addSublayer(bgLayer)
            tempBgLayers.append(bgLayer)
            
            //title
            let titlePosition = CGPoint(x: CGFloat(idx*2+1) * textLayerInterval-8.0, y: self.frame.height / 2)
            let titleString = dataSource?.menu(self, titleOfColumnAt: idx)
            let titleLayer = createTextLayer(string:titleString!, color: self.menuBarColorDefault, position: titlePosition)
            self.layer.addSublayer(titleLayer)
            tempTitles.append(titleLayer)
            
            //indicator
            let indicatorLayer = createIndicator(color: self.menuBarColorDefault, position: CGPoint(x: titleLayer.frame.maxX, y: self.frame.height/2))
            self.layer.addSublayer(indicatorLayer)
            tempIndicators.append(indicatorLayer)
        }
        
        self.titleLayers = tempTitles
        self.indicatorLayers = tempIndicators
        self.menuBgLayers = tempBgLayers
    }
    
    fileprivate func configureBaseSetting() {
        //所有的默认字体、颜色都在这里初始化
        self.layer.backgroundColor = UIColor.darkGray.cgColor
        //筛选器
        filterView.unfoldHeight = XYX_SCREEN_HEIGHT - graySpaceHeight
        filterView.frame = CGRect(x: self.frame.minX, y: self.frame.maxY, width: self.frame.width, height: filterView.unfoldHeight)
        filterView.backgroundColor = UIColor(white: 1.0, alpha: 1)
        
        //底视图
        backGroundView.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: XYX_SCREEN_HEIGHT - frame.minY)
        backGroundView.isOpaque = false
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(backgroundTapped(tapGesture:)))
        backGroundView.addGestureRecognizer(gesture)
        
    }

    //MARK: - From filterView
    func closeFilter(with menuTitle:String?, at indexPath:XYXFilterIndexPath) {
        
        if let senderTitle = menuTitle{
            var title = senderTitle
            if let text = dataSource?.menu?(self, shouldChange: title, for: indexPath){
                title = text
            }
            
            let titleLayer = titleLayers[indexPath.column!]
            titleLayer.string = title
            let size = calculateTitleSizeWithString(string: title)
            let sizeWidth = (size.width < ((self.frame.size.width / CGFloat(numOfMenu)) - self.menuTitleMargin)) ? size.width : (self.frame.size.width / CGFloat(numOfMenu) - self.menuTitleMargin)
            titleLayer.bounds = CGRect(x: 0, y: 0, width: sizeWidth, height: size.height)
            
            let indicatorLayer = indicatorLayers[indexPath.column!]
            let position = CGPoint(x: titleLayer.frame.maxX, y: self.frame.height/2)
            indicatorLayer.position = CGPoint(x:(position.x + self.menuTitleMargin/4), y:(position.y + 2))
        }
        closeFilter(indexPath)
    }
    
    func closeFilter(_ forIndexPath:XYXFilterIndexPath?){
        
        let column = forIndexPath == nil ? currentSelectedColumn : (forIndexPath?.column)!
        animate(unfold: false, filterView: filterView, indicator: indicatorLayers[column], title: titleLayers[column], backgroundView: backGroundView) {
            self.isDisplayed = false
            self.menuBgLayers[self.currentSelectedColumn].backgroundColor = self.menuBarBGColorDefault.cgColor
        }
    }
    
}

// Animate
extension XYXFilterMenu{
    func animate(unfold:Bool, filterView:XYXFilterView, indicator:CAShapeLayer, title:CATextLayer, backgroundView:UIView, complete:(()->Void)?) {
        self.beginIgnoringInteractionEvents()
        self.animate(indicator: indicator, unfold: unfold) {
            self.animate(title: title, selected: unfold, complete: {
                self.animate(backgroundView: backgroundView, show: unfold, complete: {
                    self.animate(filterView: filterView, show: unfold, complete: {
                        self.endIgnoringInteractionEvents()
                    })
                })
            })
        }
        if let cp = complete {
            cp()
        }
    }
    
    fileprivate func animate(indicator:CAShapeLayer,unfold:Bool,complete:(()->Void)?) {
        
        let animate = CABasicAnimation.init(keyPath: "transform.rotation.z")
        animate.duration = animateDuration
        animate.isRemovedOnCompletion = false
        animate.fillMode = kCAFillModeForwards
        animate.toValue = unfold ? Double.pi : 0
        indicator.add(animate, forKey: animate.keyPath)
        
        if unfold {
            indicator.fillColor = menuBarColorSelected.cgColor
        }else{
            indicator.fillColor = menuBarColorDefault.cgColor
        }
        if let cp = complete {
            cp()
        }
    }
    
    fileprivate func animate(title:CATextLayer,selected:Bool,complete:(()->Void)?) {

        let size = calculateTitleSizeWithString(string: title.string as! String)
        let sizeWidth = (size.width < (frame.width / CGFloat(numOfMenu) - menuTitleMargin)) ? size.width : frame.width / CGFloat(numOfMenu) - menuTitleMargin
        title.bounds = CGRect(x: 0, y: 0, width: sizeWidth, height: size.height)
        
        if selected {
            title.foregroundColor = menuBarColorSelected.cgColor
        }else{
            title.foregroundColor = menuBarColorDefault.cgColor
        }
        
        if let cp = complete {
            cp()
        }
    }
    
    fileprivate func animate(backgroundView:UIView,show:Bool,complete:(()->Void)?) {
        if show {
            self.superview?.addSubview(backgroundView)
            backgroundView.superview?.addSubview(self)
            UIView.animate(withDuration: animateDuration, animations: {
                backgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
            })
        } else {
            UIView.animate(withDuration: animateDuration, animations: {
                backgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
            }, completion: { (finish) in
                backgroundView.removeFromSuperview()
            })
        }
        if let cp = complete {
            cp()
        }
    }
    
    fileprivate func animate(filterView:XYXFilterView, show:Bool, complete:(()->Void)?){
        if show{
            superview?.addSubview(filterView)
            filterView.superview?.addSubview(self)
            
            filterView.configureUI(column: currentSelectedColumn, complete: {
                
                if filterView.unfoldHeightChanged == true{
                    UIView.animate(withDuration: self.animateDuration, animations: {
                        filterView.frame = CGRect(x: self.frame.minX, y: self.frame.maxY, width: self.frame.width, height: filterView.unfoldHeight)
                    }, completion: { (isSucccess) in
                        if let cp = complete{
                            cp()
                        }
                    })
                }else{
                    filterView.frame = CGRect(x: self.frame.minX, y: self.frame.maxY, width: self.frame.width, height: filterView.unfoldHeight)
                    if let cp = complete{
                        cp()
                    }
                }
            })
            
        }else{
            UIView.animate(withDuration: animateDuration, animations: {
                filterView.frame = CGRect(x: 0, y: filterView.frame.minY, width: filterView.frame.width, height: 0)
            }, completion: { (isFinished) in
                let _ = filterView.subviews.map({ (subView) in
                    subView.removeFromSuperview()
                })
                filterView.removeFromSuperview()
            })
            if let cp = complete{
                cp()
            }
        }
    }
    
    
}

// Create
extension XYXFilterMenu{
    
    fileprivate func createBgLayer(color:UIColor,position:CGPoint) -> CALayer {
        let layer = CALayer.init()
        layer.position = position
        layer.bounds = CGRect(x: position.x, y: position.y, width: frame.width/CGFloat(numOfMenu), height: frame.height-1)
        layer.backgroundColor = color.cgColor
        return layer
    }
    
    fileprivate func createIndicator(color:UIColor,position:CGPoint) -> CAShapeLayer{
        let layer = CAShapeLayer()
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x:0, y:0))
        path.addLine(to: CGPoint(x:8, y:0))
        path.addLine(to: CGPoint(x:4, y:4))
        path.close()
        
        layer.path = path.cgPath
        layer.lineWidth = 0.8
        layer.fillColor = color.cgColor
        
        let tranform = CGAffineTransform.identity
        let bound = path.cgPath.copy(strokingWithWidth: layer.lineWidth, lineCap: CGLineCap.butt, lineJoin: CGLineJoin.miter, miterLimit: layer.miterLimit, transform: tranform)
        layer.bounds = bound.boundingBox
        
        layer.position = CGPoint(x:(position.x + self.menuTitleMargin/4), y:(position.y + 2))
        
        return layer;
    }

    fileprivate func createTextLayer(string:String,color:UIColor,position:CGPoint) -> CATextLayer {
        
        let size = calculateTitleSizeWithString(string: string)
        let layer = CATextLayer()
        let sizeWidth = (size.width < ((self.frame.size.width / CGFloat(numOfMenu)) - self.menuTitleMargin)) ? size.width : (self.frame.size.width / CGFloat(numOfMenu) - self.menuTitleMargin)
        layer.bounds = CGRect(x: 0, y: 0, width: sizeWidth, height: size.height)
        layer.string = string
        layer.fontSize = self.menuTitleFontSize
        layer.alignmentMode = kCAAlignmentCenter
        layer.foregroundColor = color.cgColor
        layer.contentsScale = UIScreen.main.scale
        layer.position = position
        layer.truncationMode = self.menuTitleTruncation
        
        return layer
    }
    
    private func calculateTitleSizeWithString(string:String) -> CGSize {
        let fontSize = self.menuTitleFontSize

        let dic = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: fontSize)]
        let theString = NSString.init(string: string)
        var size = theString.boundingRect(with: CGSize(width: 280, height: 0), options: NSStringDrawingOptions(rawValue: NSStringDrawingOptions.truncatesLastVisibleLine.rawValue | NSStringDrawingOptions.usesLineFragmentOrigin.rawValue | NSStringDrawingOptions.usesFontLeading.rawValue), attributes: dic, context: nil).size
        
        if string.contains("1") {
            size.width += 2
        }
        return size
    }

}

// TapGesture
extension XYXFilterMenu{
    
    @objc private func backgroundTapped(tapGesture:UITapGestureRecognizer) {
        guard currentSelectedColumn >= 0 else{
            return
        }
        let type = dataSource?.menu(self, typeOfColumn: currentSelectedColumn)
        guard type != XYXFilterView.ColumnType.CollectionView.rawValue else{
            return
        }
        animate(unfold: false, filterView: filterView, indicator: indicatorLayers[currentSelectedColumn], title: titleLayers[currentSelectedColumn], backgroundView: backGroundView) {
            self.isDisplayed = false
            self.menuBgLayers[self.currentSelectedColumn].backgroundColor = self.menuBarBGColorDefault.cgColor
            self.filterView.resetCurrentSelectedIndexPath()
        }
    }
    
    @objc private func menuTapped(tapGesture:UITapGestureRecognizer) {
        guard self.dataSource != nil else {
            return
        }
        let touchPoint = tapGesture.location(in: self)
        let tapIndex = Int(touchPoint.x / (self.frame.width / CGFloat(numOfMenu)))
        
        for idx in 0...numOfMenu-1{
            if idx != tapIndex{
                animate(indicator: indicatorLayers[idx], unfold: false, complete: {
                    self.animate(title: self.titleLayers[idx], selected: false, complete: {
                        self.menuBgLayers[idx].backgroundColor = self.menuBarBGColorDefault.cgColor
                    })
                })
            }
        }
        
        if tapIndex == currentSelectedColumn && isDisplayed {
            //Dismiss filterView.
            animate(unfold: false, filterView: filterView, indicator: indicatorLayers[tapIndex], title: titleLayers[tapIndex], backgroundView: backGroundView, complete: {
                self.currentSelectedColumn = tapIndex
                self.isDisplayed = false
                self.menuBgLayers[tapIndex].backgroundColor = self.menuBarBGColorDefault.cgColor
                self.filterView.resetCurrentSelectedIndexPath()
            })

        } else {
            currentSelectedColumn = tapIndex
            animate(unfold: true, filterView: filterView, indicator: indicatorLayers[tapIndex], title: titleLayers[tapIndex], backgroundView: backGroundView, complete: {
                self.isDisplayed = true
                self.menuBgLayers[tapIndex].backgroundColor = self.menuBarBGColorSelected.cgColor
            })
        }
  
        if let delegate = self.delegate {
            delegate.menu?(self, tapIndex: self.currentSelectedColumn)
        }
    }
    
}

// Extra Method
extension XYXFilterMenu{
    fileprivate func beginIgnoringInteractionEvents() {
        if UIApplication.shared.isIgnoringInteractionEvents == false {
            UIApplication.shared.beginIgnoringInteractionEvents()
            perform(#selector(self.endIgnoringInteractionEvents), with: nil, afterDelay: animateDuration)
        }
    }
    
    @objc fileprivate func endIgnoringInteractionEvents() {
        if UIApplication.shared.isIgnoringInteractionEvents {
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }

}
