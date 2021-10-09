//
//  DetailWeakSubView.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/17/21.
//

import UIKit

class DetailWeakSubView: ToggleViewButton, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var typeCollection: UICollectionView!
    @IBOutlet var suggestedCollection: UICollectionView!
    @IBOutlet var suggestedBackground: UIView!
    @IBOutlet var viewButton: UIButton!
    @IBOutlet var chevron: UIImageView!
    @IBOutlet var divider: UIImageView!
    @IBOutlet var subView: UIView!
    @IBOutlet var checkbox: UIButton!
    @IBOutlet var noFavLabel: UILabel!
    
    var primaryColor: UIColor?
    var secondaryColor: UIColor?
    var typeEffects: [TypeEffect] = []
    var suggestedPokemon: [PokemonEffectScore] = []
    var detailVC: DetailsViewController!
    var selectedTypes: [TypeStruct] = []
    
    var suggestAll: Bool = true
    
    public func configure(pokemon: Pokemon, effects: [TypeEffect], suggAll: [PokemonEffectScore], suggFav: [PokemonEffectScore], detailVC: DetailsViewController) {
        self.isHidden = true
        self.typeEffects = effects
        self.suggestedPokemon = suggAll
        self.detailVC = detailVC
        
        self.subView.layer.masksToBounds = true
        
        primaryColor = pokemon.data.getTypeStruct(slot: 1).appearance.getColor()
        secondaryColor = pokemon.data.types.count > 1 ? pokemon.data.getTypeStruct(slot: 2).appearance.getColor() : primaryColor
        
        self.suggestedBackground.backgroundColor = secondaryColor?.withAlphaComponent(0.075)
        self.suggestedBackground.subviews[0].backgroundColor = secondaryColor?.withAlphaComponent(0.2)
        self.suggestedBackground.subviews[1].backgroundColor = secondaryColor?.withAlphaComponent(0.2)
        
        configureButton(button: viewButton, color: primaryColor!, chevron: chevron, divider: divider)
        configureSubView(subView: subView, color: secondaryColor!)
        
        self.checkbox.layer.cornerRadius = 4.5
        self.checkbox.layer.borderWidth = 1
        self.checkbox.layer.borderColor = primaryColor!.withAlphaComponent(0.75).cgColor
        self.checkbox.imageView!.tintColor = .white
        self.checkbox.backgroundColor = primaryColor!.withAlphaComponent(0.1)
        self.checkbox.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        
        let tNib = UINib(nibName: "TypeButtonCell", bundle: nil)
        self.typeCollection.register(tNib, forCellWithReuseIdentifier: "TypeButtonCell")
        self.typeCollection.delegate = self
        self.typeCollection.dataSource = self
        self.typeCollection.layer.masksToBounds = false
        
        let sNib = UINib(nibName: "SuggestedButtonCell", bundle: nil)
        self.suggestedCollection.register(sNib, forCellWithReuseIdentifier: "SuggestedButtonCell")
        self.suggestedCollection.delegate = self
        self.suggestedCollection.dataSource = self
        self.suggestedCollection.layer.masksToBounds = false
        
        //effectView.configure(pokemon: pokemon, effects: effects)
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
    
    @IBAction func toggleFavorites(sender: Any?) {
        if suggestAll {
            //self.suggestedCollection.currentExamples = self.suggestedCollection.favPokemon
            self.checkbox.backgroundColor = primaryColor
            self.checkbox.setImage(UIImage(systemName: "checkmark"), for: .normal)
            //self.checkbox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        }
        else {
            //self.suggestedCollection.currentExamples = self.suggestedCollection.allPokemon
            self.checkbox.backgroundColor = primaryColor!.withAlphaComponent(0.1)
            self.checkbox.setImage(nil, for: .normal)
            //self.checkbox.setImage(UIImage(systemName: "square"), for: .normal)
        }
        
        suggestAll = !suggestAll
        //self.noFavLabel.isHidden = self.suggestedCollection.currentExamples.count > 0
        self.suggestedCollection.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.suggestedCollection {
            return self.suggestedPokemon.count
        }
        else {
            return self.typeEffects.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.suggestedCollection {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestedButtonCell", for: indexPath) as! SuggestedButtonCell
        }
        else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "TypeButtonCell", for: indexPath) as! TypeButtonCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.suggestedCollection {
            return CGSize(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
        }
        else {
            return CGSize(width: (collectionView.frame.size.width - 30) / 4, height: (collectionView.frame.size.width - 30) / 10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.suggestedCollection {
            let sCell = cell as! SuggestedButtonCell
            let types = suggestedPokemon[indexPath.row].pokemon.data.types.map({ $0.type.name })
            sCell.configure(pokemon: suggestedPokemon[indexPath.row].pokemon, color: self.primaryColor!, types: types, vC: self.detailVC)
        }
        else {
            let tCell = cell as! TypeButtonCell
            let type = typeDict[typeEffects[indexPath.row].name]!
            tCell.configure(type: type, detailVC: self.detailVC, isSel: true)
            tCell.configureEffect(value: "\(Int(typeEffects[indexPath.row].value))%")
        }
    }
}
