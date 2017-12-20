//
//  XYXFilterViewCell.swift
//  XYXFilterMenu_Swift
//
//  Created by Teresa on 2017/12/20.
//  Copyright © 2017年 Teresa. All rights reserved.
//

import Foundation
import UIKit

class XYXFilterViewTableViewCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel?.font = UIFont.systemFont(ofSize: MENU_TABLEVIEW_CELL_TEXT_FONTSIZE)
        self.textLabel?.textColor = MENU_TABLEVIEW_CELL_TEXT_COLOR_DEFAULT
        self.backgroundColor = MENU_TABLEVIEW_CELL_BG_COLOR_DEFAULT
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.textLabel?.textColor = MENU_TABLEVIEW_CELL_TEXT_COLOR_SELECTED
            self.backgroundColor = MENU_TABLEVIEW_CELL_BG_COLOR_SELECTED
        } else {
            self.textLabel?.textColor = MENU_TABLEVIEW_CELL_TEXT_COLOR_DEFAULT
            self.backgroundColor = MENU_TABLEVIEW_CELL_BG_COLOR_DEFAULT
        }
    }
    
    class func reuseIdentifier() -> String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}

class XYXFilterViewCollectionViewCell: UICollectionViewCell {
    lazy var textLabel:UILabel = {
       let textLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        textLabel.backgroundColor = MENU_COLLECTION_CELL_BG_COLOR_DEFAULT
        textLabel.layer.masksToBounds = true
        textLabel.layer.cornerRadius = 7
        textLabel.layer.borderWidth = 0.5
        textLabel.layer.borderColor = MENU_COLLECTION_CELL_BORDER_COLOR_DEFAULT.cgColor
        textLabel.text = "item"
        textLabel.textAlignment = NSTextAlignment.center
        textLabel.font = UIFont.systemFont(ofSize: MENU_COLLECTION_CELL_TEXT_FONTSIZE)
        return textLabel
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textLabel)
        self.clipsToBounds = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    class func reuseIdentifier() -> String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    override func layoutSubviews() {
        contentView.frame = bounds
        textLabel.frame = bounds
    }
    
    override var isSelected: Bool{
        didSet{
            if isSelected{
                textLabel.textColor = MENU_COLLECTION_CELL_TEXT_COLOR_SELECTED
                textLabel.backgroundColor = MENU_COLLECTION_CELL_BG_COLOR_SELECTED
                textLabel.layer.borderColor = MENU_COLLECTION_CELL_BORDER_COLOR_SELECTED.cgColor
                
            }else{
                textLabel.textColor = MENU_COLLECTION_CELL_TEXT_COLOR_DEFAULT
                textLabel.backgroundColor = MENU_COLLECTION_CELL_BG_COLOR_DEFAULT
                textLabel.layer.borderColor = MENU_COLLECTION_CELL_BORDER_COLOR_DEFAULT.cgColor
            }
        }
    }
}

class XYXFilterDefaultHeaderView: UICollectionReusableView {
    
    lazy var titleLabel:UILabel = {
        let textLabel = UILabel.init(frame: CGRect.zero)
        textLabel.font = UIFont.systemFont(ofSize: MENU_COLLECTION_HEADER_TEXT_FONTSIZE)
        textLabel.textColor = MENU_COLLECTION_HEADER_TEXT_COLOR
        textLabel.text = "Title"
        return textLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func reuseIdentifier() -> String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    override func layoutSubviews() {
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: 10, y: frame.height-titleLabel.frame.height-6, width: titleLabel.frame.width+6, height:titleLabel.frame.height)
    }
}

class XYXFilterDefaultFooterView: UICollectionReusableView {
    
    lazy var lineView:UIView = {
        let line = UIView.init(frame: CGRect(x: 10.0, y: 0.5, width: XYX_SCREEN_WIDTH-10.0, height: 0.5))
        line.backgroundColor = MENU_SEPARATOR_COLOR
        return line
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(lineView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func reuseIdentifier() -> String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
