//
//  TypeCollectionCell.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/24/21.
//

import UIKit

class TypeCollectionCell: UICollectionViewCell {
    
    static let identifier = "TypeCollectionCell"
    
    @IBOutlet var typeButton: TypeCellButton!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellName: UILabel!
    @IBOutlet var backImage: UIImageView!
    
    func configureCell(appearance: TypeAppearance) {
        
        typeButton.type = typeDict[appearance.name.lowercased()]
        backImage.layer.backgroundColor = appearance.getColor().cgColor
        cellImage.image = appearance.getImage().withRenderingMode(.alwaysTemplate)
        cellName.text = appearance.name
        contentView.layer.backgroundColor = UIColor.tertiarySystemBackground.cgColor
        contentView.layer.cornerRadius = 15.0
        //contentView.layer.borderWidth = 1
        //contentView.layer.borderColor = UIColor(named: "ColorButtonBorder")!.cgColor
        //contentView.layer.masksToBounds = true
        
        /*layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        layer.shadowRadius = 0.85
        layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.15 : 0.4
        
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath*/
    }
}
