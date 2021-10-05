//
//  TypeButtonCell.swift
//  Poke Guide
//
//  Created by Zack Blase on 10/4/21.
//

import UIKit

class TypeButtonCell: UICollectionViewCell {

    @IBOutlet var typeIcon: UIImageView!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var cellButton: TypeCellButton!
    
    var movesetView: DetailMovesetSubView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(type: TypeStruct, text: String, msView: DetailMovesetSubView) {
        self.movesetView = msView
        cellButton.type = type
        contentView.layer.masksToBounds = true
        contentView.contentMode = .scaleAspectFit
        typeIcon.image = type.appearance.getImage().withRenderingMode(.alwaysTemplate)
        typeIcon.contentMode = .scaleAspectFit
        
        typeLabel.adjustsFontSizeToFitWidth = true
        typeLabel.text = text
        
        cellButton.backgroundColor = type.appearance.getColor().withAlphaComponent(0.1)
        cellButton.layer.cornerRadius = 8
        cellButton.layer.borderColor = type.appearance.getColor().cgColor
        cellButton.layer.borderWidth = 1
    }
    
    @IBAction func typeClicked(_ sender: Any?) {
        let typeBtn = sender as! TypeCellButton
        
        self.movesetView.typeCellTapped(type: typeBtn.type!)
    }
}
