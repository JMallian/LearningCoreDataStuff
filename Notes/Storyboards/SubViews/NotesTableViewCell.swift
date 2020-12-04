//
//  NotesTableViewCell.swift
//  Notes
//
//  Created by Jessica Mallian on 12/1/20.
//

import UIKit

class NotesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    private let textColorSelected: UIColor = .blue
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            titleLabel.textColor = textColorSelected
            updatedAtLabel.textColor = textColorSelected
            contentLabel.textColor = textColorSelected
        } else {
            titleLabel.textColor = .label
            updatedAtLabel.textColor = .label
            contentLabel.textColor = .label
        }
    }
    
}
