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
    @IBOutlet var cellButton: UIButton!
    
    var type: TypeStruct!
    var movesetView: DetailMovesetSubView!
    var isSel: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(type: TypeStruct, text: String, msView: DetailMovesetSubView, isSel: Bool) {
        self.type = type
        self.movesetView = msView
        self.isSel = isSel
        
        contentView.layer.masksToBounds = true
        contentView.contentMode = .scaleAspectFit
        typeIcon.image = type.appearance.getImage().withRenderingMode(.alwaysTemplate)
        typeIcon.contentMode = .scaleAspectFit
        
        typeLabel.adjustsFontSizeToFitWidth = true
        typeLabel.text = text
        
        cellButton.backgroundColor = type.appearance.getColor().withAlphaComponent(isSel ? 0.35 : 0.15)
        cellButton.layer.cornerRadius = 8
        cellButton.layer.borderColor = type.appearance.getColor().cgColor
        cellButton.layer.borderWidth = 1
        
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.15 : 0.4
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        
    }
    
    @IBAction func typeClicked(_ sender: Any?) {
        self.movesetView.typeCellTapped(cell: self)
    }
}
