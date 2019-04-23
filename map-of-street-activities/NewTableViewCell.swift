//
//  NewTableViewCell.swift
//  map-of-street-activities
//
//  server hostname — 85.143.173.40, port:81
//
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import UIKit

protocol TableViewCell {
    func onClickCell(index: Int, answer: Bool)
}

class NewTableViewCell: UITableViewCell {
    @IBOutlet weak var information: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var cellDelegate: TableViewCell?
    var index: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func validate(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            cellDelegate?.onClickCell(index: index!.row, answer: false)
        case 1:
            cellDelegate?.onClickCell(index: index!.row, answer: true)
        default:
            break
        }
    }
}
