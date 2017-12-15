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
    
    var dataSource:XYXFilterMenuDataSource?{
        didSet{
            configureMenuBar()
        }
    }
    
    // 关于设定的各种参数
    var numOfMenu = 1
    var menuBarBGColor = MENU_BG_COLOR_DEFAULT
    var menuBarColorDefault = MENU_TITLE_COLOR_DEFAULT
    var menuBarColorSelected = MENU_TITLE_COLOR_SELECTED
    
    
    // 关于设定的数据存储
    var titleLayers:[CALayer] = []
    var indicatorLayers:[CALayer] = []
    var menuBgLayers:[CALayer] = []
    
    var menuTitleFontSize:CGFloat = 14
    var menuTitleMargin:CGFloat = 20
    var menuTitleTruncation = kCATruncationEnd
    
    
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
        var tempTitles:[CALayer] = []
        var tempIndicators:[CALayer] = []
        
        for idx in 0...(numOfMenu-1) {
            //bgLayer
            let color = idx%2 == 0 ? UIColor.yellow : self.menuBarBGColor
            
            let bgLayerPosition = CGPoint(x:(CGFloat(idx)+0.5)*bgLayerInterval, y:self.frame.height/2)
            let bgLayer = createBgLayer(color: color, position: bgLayerPosition)
            self.layer.addSublayer(bgLayer)
            tempBgLayers.append(bgLayer)
            
            //title
            let titlePosition = CGPoint(x: CGFloat(idx*2+1) * textLayerInterval-8.0, y: self.frame.height / 2)
            let titleString = dataSource?.titleOfColumns(menu: self, index: idx)
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
    }
}

// Create
extension XYXFilterMenu{
    
    fileprivate func createBgLayer(color:UIColor,position:CGPoint) -> CALayer {
        let layer = CALayer.init()
        layer.position = position
        layer.bounds = CGRect(x: position.x, y: position.y, width: self.frame.width/CGFloat(self.numOfMenu), height: self.frame.height-1)
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
        
        layer.position = CGPoint(x:(position.x + self.menuTitleMargin/4), y:(position.y + 2));
        
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
        if string == "1号线" {
            size.width = 36.87
        }else if (string.hasPrefix("1")){
            size.width = 45.0
        }
        return size
    }

}

// TapGesture
extension XYXFilterMenu{
    @objc private func menuTapped(tapGesture:UITapGestureRecognizer) {
        
    }
}
