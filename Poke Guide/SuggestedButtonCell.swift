//
//  SuggestedButtonCell.swift
//  Poke Guide
//
//  Created by Zack Blase on 10/5/21.
//

import UIKit

class SuggestedButtonCell: UICollectionViewCell {

    @IBOutlet var cellIcon: UIImageView!
    @IBOutlet var cellName: UILabel!
    @IBOutlet var cellSubName: UILabel!
    @IBOutlet var cellButton: UIButton!
    @IBOutlet var typeImgA: UIImageView!
    @IBOutlet var typeImgB: UIImageView!
    @IBOutlet var typeImgC: UIImageView!
    
    var pokemon: Pokemon!
    var movesetView: DetailMovesetSubView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(pokemon: Pokemon, color: UIColor, types: [String], msView: DetailMovesetSubView) {
        self.pokemon = pokemon
        self.movesetView = msView
        
        self.cellIcon.image = pokemon.image
        
        typeImgA.isHidden = true
        typeImgB.isHidden = true
        typeImgC.isHidden = true
        
        if types.count > 0 {
            let type = typeDict[types[0]]!
            typeImgA.isHidden = false
            typeImgA.image = type.appearance.getImage().withRenderingMode(.alwaysTemplate)
            typeImgA.tintColor = type.appearance.getColor()
        }
        if types.count > 1 {
            let type = typeDict[types[1]]!
            typeImgB.isHidden = false
            typeImgB.image = type.appearance.getImage().withRenderingMode(.alwaysTemplate)
            typeImgB.tintColor = type.appearance.getColor()
        }
        if types.count > 2 {
            let type = typeDict[types[2]]!
            typeImgC.isHidden = false
            typeImgC.image = type.appearance.getImage().withRenderingMode(.alwaysTemplate)
            typeImgC.tintColor = type.appearance.getColor()
        }
        
        self.cellButton.backgroundColor = color.withAlphaComponent(0.35)
        self.cellButton.layer.cornerRadius = 10
        self.cellButton.layer.borderWidth = 1
        self.cellButton.layer.borderColor = color.cgColor
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.15 : 0.4
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.cellButton.bounds, cornerRadius: self.cellButton.layer.cornerRadius).cgPath
        
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 10
        
        let names = pokemon.data.name.split(separator: "-")
        self.cellName.text = String(names[0]).capitalizingFirstLetter()
        if names.count > 1 {
            self.cellSubName.isHidden = false
            self.cellSubName.text = String(names[1]).capitalizingFirstLetter()
            
            if names.count > 2 {
                self.cellSubName.text! += " \(String(names[2]).capitalizingFirstLetter())"
            }
        }
        else {
            self.cellSubName.isHidden = true
        }
        
    }
    
    @IBAction func pokemonTapped(_ sender: Any?) {
        self.movesetView.pokeCellTapped(poke: self.pokemon)
    }
}
