//
//  DetailEvolutionsSubView.swift
//  Poke Guide
//
//  Created by Zack Blase on 8/12/21.
//

import UIKit

class DetailEvolutionsSubView: ToggleViewButton {
    
    @IBOutlet var buttonA: PokemonButton!
    @IBOutlet var viewB: UIView!
    @IBOutlet var buttonC: PokemonButton!
    @IBOutlet var viewD: UIView!
    @IBOutlet var buttonE: PokemonButton!
    @IBOutlet var chevron: UIImageView!
    @IBOutlet var viewButton: UIButton!
    @IBOutlet var divider: UIImageView!
    @IBOutlet var subView: UIView!
    
    var images: [UIImage] = []
    let arrow = UIImage(systemName: "arrow.right")?.withAlignmentRectInsets(UIEdgeInsets(top: -5, left: -5, bottom: -5, right: -5))
    
    
    var primaryColor: UIColor?
    var secondaryColor: UIColor?
    
    var imgDict: [Int: Pokemon] = [:]
    
    public func configure(pokemon: Pokemon) {
        //self.isHidden = true
        
        primaryColor = pokemon.data.getTypeStruct(slot: 1).appearance.getColor()
        secondaryColor = pokemon.data.types.count > 1 ? pokemon.data.getTypeStruct(slot: 2).appearance.getColor() : primaryColor
        
        configureButton(button: viewButton, color: primaryColor!, chevron: chevron, divider: divider)
        configureSubView(subView: subView, color: secondaryColor!)
        
        if !self.isHidden {
            highlightButton(button: viewButton, color: primaryColor!)
        }
        
        let pokemonController = PokemonDataController()
        pokemonController.fetchPokemonSpecies(urlStr: pokemon.data.species!.url, evView: self)
    }
    
    func configureData(ev: EvolutionChain) {
        
        let imageViewB = viewB.subviews[0] as! UIImageView?
        imageViewB!.tintColor = secondaryColor
        let imageViewD = viewD.subviews[0] as! UIImageView?
        imageViewD!.tintColor = secondaryColor
        
        buttonA.isHidden = true
        viewB.isHidden = true
        buttonC.isHidden = true
        viewD.isHidden = true
        buttonE.isHidden = true
        
        guard let firstPoke = pokemonDict[ev.chain.species.name] else { return }
        let urlA = pokeUrlArray?.urlArray.first(where: { $0.name == ev.chain.species.name })
        
        buttonA.isHidden = false
        buttonA.pokemon = firstPoke
        buttonA.pokeUrl = urlA
        buttonA.setImage(firstPoke.image, for: .normal)
        buttonA.contentMode = .center
        buttonA.imageView?.contentMode = .scaleAspectFit
        
        if ev.chain.evolves_to.count > 0 {
            guard let secondPoke = pokemonDict[ev.chain.evolves_to[0].species.name] else { return }
            let urlC = pokeUrlArray?.urlArray.first(where: { $0.name == ev.chain.evolves_to[0].species.name })
            
            viewB.isHidden = false
            buttonC.isHidden = false
            buttonC.pokemon = secondPoke
            buttonC.pokeUrl = urlC
            buttonC.setImage(secondPoke.image, for: .normal)
            buttonC.contentMode = .center
            buttonC.imageView?.contentMode = .scaleAspectFit
            
            if ev.chain.evolves_to[0].evolves_to.count > 0 {
                guard let thirdPoke = pokemonDict[ev.chain.evolves_to[0].evolves_to[0].species.name] else { return }
                let urlE = pokeUrlArray?.urlArray.first(where: { $0.name == ev.chain.evolves_to[0].evolves_to[0].species.name })
                
                viewD.isHidden = false
                buttonE.isHidden = false
                buttonE.pokemon = thirdPoke
                buttonE.pokeUrl = urlE
                buttonE.setImage(thirdPoke.image, for: .normal)
                buttonE.contentMode = .center
                buttonE.imageView?.contentMode = .scaleAspectFit
            }
        }
    }
    
    @IBAction func toggleView(sender: Any?) {
        self.isHidden = !self.isHidden
        
        if self.deg == .pi {
            setOpenButton(button: viewButton, color: primaryColor!, chevron: chevron)
        }
        else {
            setClosedButton(button: viewButton, color: primaryColor!, chevron: chevron)
        }
    }

}
