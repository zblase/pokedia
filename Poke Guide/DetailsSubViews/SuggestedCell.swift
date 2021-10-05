//
//  SuggestedCell.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/13/21.
//

import UIKit

class SuggestedCell: UICollectionViewCell {
    
    public static var identifier: String = "SuggestedCell"
    
    @IBOutlet var pokemonImage: UIImageView!
    @IBOutlet var pokemonName: UILabel!
    
    var pokemon: Pokemon?
    
    public func configure (pokemon: Pokemon) {
        self.pokemon = pokemon
        self.pokemonImage.image = pokemon.image
        let names = pokemon.data.name.split(separator: "-")
        self.pokemonName.text = String(names[0]).capitalizingFirstLetter()
        contentView.layer.masksToBounds = true
    }
}
