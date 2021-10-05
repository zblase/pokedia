//
//  DetailWeakSubView.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/17/21.
//

import UIKit

class DetailWeakSubView: ToggleViewButton {
    
    @IBOutlet var effectView: WeakEffectCollectionView!
    @IBOutlet var suggestedCollection: WeakSuggestedCollectionView!
    @IBOutlet var viewButton: UIButton!
    @IBOutlet var chevron: UIImageView!
    @IBOutlet var divider: UIImageView!
    @IBOutlet var subView: UIView!
    @IBOutlet var checkbox: UIButton!
    @IBOutlet var noFavLabel: UILabel!
    
    var primaryColor: UIColor?
    var secondaryColor: UIColor?
    
    var suggestAll: Bool = true
    
    public func configure(pokemon: Pokemon, effects: [TypeEffect]) {
        self.isHidden = true
        
        primaryColor = pokemon.data.getTypeStruct(slot: 1).appearance.getColor()
        secondaryColor = pokemon.data.types.count > 1 ? pokemon.data.getTypeStruct(slot: 2).appearance.getColor() : primaryColor
        
        configureButton(button: viewButton, color: primaryColor!, chevron: chevron, divider: divider)
        configureSubView(subView: subView, color: secondaryColor!)
        
        self.checkbox.layer.cornerRadius = 4
        self.checkbox.layer.borderWidth = 1
        self.checkbox.layer.borderColor = primaryColor!.withAlphaComponent(0.75).cgColor
        self.checkbox.imageView!.tintColor = .white
        self.checkbox.backgroundColor = primaryColor!.withAlphaComponent(0.1)
        self.checkbox.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        
        effectView.configure(pokemon: pokemon, effects: effects)
    }
    
    @IBAction func toggleView(sender: Any?) {
        self.isHidden = !self.isHidden
        
        if self.deg == .pi {
            setOpenButton(button: viewButton, color: primaryColor!, chevron: chevron)
            
            effectView.animateCells()
        }
        else {
            setClosedButton(button: viewButton, color: primaryColor!, chevron: chevron)
        }
    }
    
    @IBAction func toggleFavorites(sender: Any?) {
        if suggestAll {
            self.suggestedCollection.currentExamples = self.suggestedCollection.favPokemon
            self.checkbox.backgroundColor = primaryColor
            self.checkbox.setImage(UIImage(systemName: "checkmark"), for: .normal)
            //self.checkbox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        }
        else {
            self.suggestedCollection.currentExamples = self.suggestedCollection.allPokemon
            self.checkbox.backgroundColor = primaryColor!.withAlphaComponent(0.1)
            self.checkbox.setImage(nil, for: .normal)
            //self.checkbox.setImage(UIImage(systemName: "square"), for: .normal)
        }
        
        suggestAll = !suggestAll
        self.noFavLabel.isHidden = self.suggestedCollection.currentExamples.count > 0
        self.suggestedCollection.reloadData()
    }
}
