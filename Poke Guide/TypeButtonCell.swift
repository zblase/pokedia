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
    var detailVC: DetailsViewController!
    var isToggle: Bool = false
    var isSel: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(type: TypeStruct, detailVC: DetailsViewController, isSel: Bool) {
        self.type = type
        self.detailVC = detailVC
        self.isSel = isSel
        
        contentView.layer.masksToBounds = true
        contentView.contentMode = .scaleAspectFit
        typeIcon.image = type.appearance.getImage().withRenderingMode(.alwaysTemplate)
        typeIcon.tintColor = isSel ? typeIcon.tintColor.withAlphaComponent(1) : typeIcon.tintColor.withAlphaComponent(0.75)
        typeIcon.contentMode = .scaleAspectFit
        
        cellButton.backgroundColor = type.appearance.getColor().withAlphaComponent(isSel ? 0.45 : 0.1)
        cellButton.layer.cornerRadius = 8
        cellButton.layer.borderColor = isSel ? type.appearance.getColor().withAlphaComponent(0.75).cgColor : type.appearance.getColor().withAlphaComponent(0.5).cgColor
        cellButton.layer.borderWidth = 1
        
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        self.layer.shadowRadius = 0.75
        self.layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.15 : 0.4
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        
    }
    
    func configureToggle(name: String) {
        self.isToggle = true
        
        typeLabel.adjustsFontSizeToFitWidth = true
        typeLabel.text = name
        typeLabel.textColor = isSel ? typeLabel.textColor.withAlphaComponent(1) : typeLabel.textColor.withAlphaComponent(0.75)
    }
    
    func configureEffect(value: String) {
        typeLabel.text = value
        typeLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    @IBAction func typeClicked(_ sender: Any?) {
        if self.isToggle {
            self.detailVC.toggleTypeCell(cell: self)
        }
        else {
            self.detailVC.typeCellTapped(type: self.type)
        }
    }
}
