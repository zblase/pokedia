//
//  TypeEffectCellAttack.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/26/21.
//

import UIKit

class TypeEffectCellAttack: UICollectionViewCell {
    static let identifier = "TypeEffectCellAttack"
    
    @IBOutlet var typeIcon: UIImageView!
    @IBOutlet var backImage: UIImageView!
    @IBOutlet var cellValue: UILabel!
    @IBOutlet var cellButton: UIButton!
    
    func configure(effect: TypeEffect) {
        let type = typeDict[effect.name]!
        typeIcon.image = type.appearance.getImage()
        backImage.tintColor = type.appearance.getColor()
        cellValue.text = "\(Int(effect.value))%"
        cellValue.textColor = effect.value > 100 ? .systemGreen : .systemRed
        
        cellButton.layer.cornerRadius = 8
        cellButton.backgroundColor = type.appearance.getColor().withAlphaComponent(0.075)
        cellButton.layer.borderWidth = 0.75
        cellButton.layer.borderColor = type.appearance.getColor().withAlphaComponent(0.4).cgColor
        cellButton.layer.masksToBounds = true
    }
}
