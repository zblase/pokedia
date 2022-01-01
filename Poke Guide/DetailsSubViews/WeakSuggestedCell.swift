//
//  WeakSuggestedCell.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/17/21.
//

import UIKit

class WeakSuggestedCell: UICollectionViewCell {
    public static var identifier: String = "WeakSuggestedCell"
    
    @IBOutlet var pokemonImage: UIImageView!
    @IBOutlet var pokemonName: UILabel!
    
    var pokemon: Pokemon?
    var pokeUrl: PokemonArrayResult.PokemonUrl!
    
    public func configure (url: PokemonArrayResult.PokemonUrl) {
        //self.pokemon = pokemon
        self.pokeUrl = url
        //self.pokemonImage.image = pokeImages[url.getId()]
        self.tryGetImage(id: url.getId())
        //let names = pokemon.data.name.split(separator: "-")
        //self.pokemonName.text = String(names[0]).capitalizingFirstLetter()
        self.pokemonName.text = url.getDisplayName().name
        contentView.layer.masksToBounds = true
    }
    
    func tryGetImage(id: String) {
        if let img = pokeImageArray.first(where: { $0.id == id }) {
            self.pokemonImage.image = img.image
        }
        else {
            self.tryGetImage(id: id)
        }
    }
    
}
