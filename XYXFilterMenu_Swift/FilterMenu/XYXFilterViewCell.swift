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
        self.backgroundColor = MENU_TABLEVIEW_CELL_BG_COLOR_WHITE
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool{
        didSet{
            if isSelected == true {
                self.textLabel?.textColor = MENU_TABLEVIEW_CELL_TEXT_COLOR_SELECTED
            } else {
                self.textLabel?.textColor = MENU_TABLEVIEW_CELL_TEXT_COLOR_DEFAULT
            }

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
        textLabel.layer.borderWidth = 1
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

class XYXFilterAnnexView: UIView {
    
    var clearBtnCallback:(()->())?
    var confirmBtnCallback:(()->())?
    
    let clearBtn:UIButton = {
       let button = UIButton.init(type: UIButtonType.custom)
        button.setImage(UIImage.init(named: "Filter_Btn_Clear"), for: UIControlState.normal)
        button.setTitleColor(UIColor(red: 240.0/255, green: 109.0/255, blue: 57.0/255, alpha: 1), for: UIControlState.normal)
        button.setTitle("清空条件", for: UIControlState.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        button.backgroundColor = UIColor.clear
        button.sizeToFit()
        return button
    }()
    lazy var confirmBtn:UIButton = {
        let button = UIButton.init(type: UIButtonType.custom)
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        button.setTitle("确定", for: UIControlState.normal)
        button.backgroundColor = UIColor(red: 88.0/255, green: 149.0/255, blue: 248.0/255, alpha: 1)
        button.frame = CGRect(x: 0, y: 0, width: 150, height: frame.height)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = MENU_ANNEX_BG_COLOR
        clearBtn.addTarget(self, action: #selector(clearBtnClicked), for: UIControlEvents.touchUpInside)
        confirmBtn.addTarget(self, action: #selector(confirmBtnClicked), for: UIControlEvents.touchUpInside)
        addSubview(clearBtn)
        addSubview(confirmBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        confirmBtn.frame = CGRect(x: frame.width-confirmBtn.frame.width, y: 0, width: confirmBtn.frame.width, height: confirmBtn.frame.height)
        clearBtn.frame = CGRect(x: 15, y: confirmBtn.center.y-clearBtn.frame.height/2, width: clearBtn.frame.width, height: clearBtn.frame.height)
    }
    
    @objc private func clearBtnClicked(){
        if let callback = clearBtnCallback {
            callback()
        }
    }
    
    @objc private func confirmBtnClicked() {
        if let callback = confirmBtnCallback {
            callback()
        }
    }
}
