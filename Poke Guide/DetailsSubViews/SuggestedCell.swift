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
        //self.pokemonImage.image = pokemon.getImage()
        tryGetImage(id: String(pokemon.data.id))
        let names = pokemon.data.name.split(separator: "-")
        self.pokemonName.text = String(names[0]).capitalizingFirstLetter()
        contentView.layer.masksToBounds = true
    }
    
    func tryGetImage(id: String) {
        
        if let img = pokeImageArray.first(where: { $0.id == id }) {
            self.pokemonImage.image = img.image
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.tryGetImage(id: id)
            })
        }
    }
}
