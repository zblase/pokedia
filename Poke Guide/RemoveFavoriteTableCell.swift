//
//  RemoveFavoriteTableCell.swift
//  Poke Guide
//
//  Created by Zack Blase on 10/1/21.
//

import UIKit

class RemoveFavoriteTableCell: UITableViewCell {
    static let identifier = "RemoveFavoriteTableCell"

    @IBOutlet var removeIcon: UIImageView!
    @IBOutlet var pokemonIcon: UIImageView!
    @IBOutlet var pokemonName: UILabel!
    @IBOutlet var iconStackView: UIStackView!
    @IBOutlet var typeViewA: UIView!
    @IBOutlet var typeViewB: UIView!
    @IBOutlet var typeViewC: UIView!
    
    var favPoke: FavPokemonJson.FavJson!
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(fav: FavPokemonJson.FavJson, hidden: Bool) {
        self.removeIcon.isHidden = hidden
        self.favPoke = fav
        
        let pokemon = pokemonArray.first(where: { $0.data.name == fav.name })!
        pokemonIcon.image = pokemon.image
        pokemonIcon.contentMode = .scaleAspectFit
        
        let names = pokemon.data.name.split(separator: "-")
        pokemonName.text = String(names[0]).capitalizingFirstLetter()
        
        typeViewA.isHidden = true
        typeViewB.isHidden = true
        typeViewC.isHidden = true
        
        if fav.types.count > 0 {
            let typeA = typeDict[fav.types[0].lowercased()]!
            typeViewA.backgroundColor = typeA.appearance.getColor()
            typeViewA.layer.cornerRadius = typeViewA.bounds.height / 2
            
            let labelA = typeViewA.subviews[0] as! UILabel
            labelA.text = typeA.appearance.name
            
            typeViewA.isHidden = false
        }
        if fav.types.count > 1 {
            let typeB = typeDict[fav.types[1].lowercased()]!
            typeViewB.backgroundColor = typeB.appearance.getColor()
            typeViewB.layer.cornerRadius = typeViewA.bounds.height / 2
            
            let labelB = typeViewB.subviews[0] as! UILabel
            labelB.text = typeB.appearance.name
            
            typeViewB.isHidden = false
        }
        if fav.types.count > 2 {
            let typeC = typeDict[fav.types[2].lowercased()]!
            typeViewC.backgroundColor = typeC.appearance.getColor()
            typeViewC.layer.cornerRadius = typeViewA.bounds.height / 2
            
            let labelC = typeViewC.subviews[0] as! UILabel
            labelC.text = typeC.appearance.name
            
            typeViewC.isHidden = false
        }
    }
    

}
