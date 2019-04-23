//
//  GetTableViewCell.swift
//  map-of-street-activities
//
//  server hostname — 85.143.173.40, port:81
//
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import UIKit

protocol TableViewCellFavourites {
    func onClickCell(index: Int)
}

class GetTableViewCell: UITableViewCell {
    @IBOutlet weak var labelOfActivity: UILabel!
    @IBAction func removeActivity(_ sender: Any) {
        cellDelegate?.onClickCell(index: index!.row)
    }
    
    var cellDelegate: TableViewCellFavourites?
    var index: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
