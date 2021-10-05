//
//  AddFavoriteTypeCell.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/28/21.
//

import UIKit

class AddFavoriteTypeCell: UICollectionViewCell {
    static let identifier = "AddFavoriteTypeCell"
    
    @IBOutlet var typeIcon: UIImageView!
    
    var type: TypeStruct?
    var isSel = false
    
    func configure(typeName: String, isSel: Bool) {
        self.type = typeDict[typeName]!
        self.isSel = isSel
        
        contentView.layer.cornerRadius = 8
        contentView.layer.borderColor = type!.appearance.getColor().cgColor
        contentView.backgroundColor = type!.appearance.getColor().withAlphaComponent(0.05)
        contentView.layer.borderWidth = 1.0
        typeIcon.contentMode = .scaleAspectFit
        
        typeIcon.image = type!.appearance.getImage().withRenderingMode(.alwaysTemplate)
        
        if isSel {
            contentView.backgroundColor = type!.appearance.getColor().withAlphaComponent(0.75)
        }
        else {
            contentView.backgroundColor = type!.appearance.getColor().withAlphaComponent(0.05)
        }
    }
}
