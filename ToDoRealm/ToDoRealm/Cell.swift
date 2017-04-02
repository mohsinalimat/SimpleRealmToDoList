//
//  CellTableViewCell.swift
//  ToDoRealm
//
//  Created by Dilraj Devgun on 4/1/17.
//  Copyright © 2017 Dilraj Devgun. All rights reserved.
//

import UIKit

class Cell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.setSelected(false, animated: true)
    }
    
    func setColor(color:UIColor) {
        self.backgroundColor = color
        self.textLabel?.textColor = UIColor.white
    }

}
