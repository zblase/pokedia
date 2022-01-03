//
//  CheatSheetSlotView.swift
//  Poke Guide
//
//  Created by Zack Blase on 1/1/22.
//

import Foundation
import UIKit

class CheatSheetSlotView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var cheatSheetController: CheatSheetViewController!
    var index: Int = -1
    var empty = true
    var pokemon: FavPokemonJson.FavJson!
    var strongEffects: [TypeEffect] = []
    var weakEffects: [TypeEffect] = []
    
    
    var mainActivityIndicator: UIActivityIndicatorView! //1
    var contentView: UIView! //2
    var nameLabel: UIView! //3
    var imgActivityIndicator: UIActivityIndicatorView! //4
    var pokeImage: UIImageView! //5
    var strongView: UICollectionView! //6
    var weakView: UICollectionView! //7
    var moveAView: UIView! //8
    var moveBView: UIView! //9
    var moveCView: UIView! //10
    var moveViews: [UIView]!
    
    
    func configure(csController: CheatSheetViewController, index: Int) {
        self.cheatSheetController = csController
        self.index = index
        
        self.mainActivityIndicator = self.viewWithTag(1) as? UIActivityIndicatorView
        self.contentView = self.viewWithTag(2)
        self.nameLabel = self.viewWithTag(3)
        self.imgActivityIndicator = self.viewWithTag(4) as? UIActivityIndicatorView
        self.pokeImage = self.viewWithTag(5) as? UIImageView
        self.strongView = self.viewWithTag(6) as? UICollectionView
        self.weakView = self.viewWithTag(7) as? UICollectionView
        self.moveAView = self.viewWithTag(8)
        self.moveBView = self.viewWithTag(9)
        self.moveCView = self.viewWithTag(10)
        
        moveViews = [self.moveAView, self.moveBView, self.moveCView]
        
        mainActivityIndicator.stopAnimating()
        imgActivityIndicator.stopAnimating()
        
        layer.cornerRadius = 8
        layer.borderColor = UIColor(named: "ColorEmptySlotBorder")?.cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true
        
        strongView.superview!.layer.borderColor = UIColor.green.withAlphaComponent(0.4).cgColor
        strongView.superview!.layer.borderWidth = 0.5
        
        weakView.superview!.layer.borderColor = UIColor.red.withAlphaComponent(0.4).cgColor
        weakView.superview!.layer.borderWidth = 0.5
        
        strongView.delegate = self
        strongView.dataSource = self
        weakView.delegate = self
        weakView.dataSource = self
    }
    
    func addNewPokemon(pokeUrl: PokemonArrayResult.PokemonUrl, favTypes: [String]?) {
        let csParser = CheatSheetJsonParser()
        let types = (favTypes == nil ? [] : favTypes)!
        let poke = FavPokemonJson.FavJson(name: pokeUrl.name, types: types)
        csParser.addSlot(fav: poke)
        
        self.tryGetPokemon(pokeUrl: pokeUrl, favTypes: favTypes)
    }
    
    func tryGetPokemon(pokeUrl: PokemonArrayResult.PokemonUrl, favTypes: [String]?) {
        self.mainActivityIndicator.startAnimating()
        
        let mainLabel = self.nameLabel.subviews[0] as! UILabel
        let subLabel = self.nameLabel.subviews[1] as! UILabel
        mainLabel.text = pokeUrl.getDisplayName().name
        subLabel.text = pokeUrl.getDisplayName().subName
        subLabel.isHidden = subLabel.text == "Normal"
        
        self.tryGetImage(pokeUrl: pokeUrl)
        
        if let poke = pokemonDict[pokeUrl.name] {
            self.populate(pokemon: poke, favTypes: favTypes)
        }
        else {
            let pokeController = PokemonDataController()
            pokeController.requestPokemonData(url: pokeUrl.url, completion: {(success) -> Void in
                if success {
                    DispatchQueue.main.async {
                        self.populate(pokemon: pokemonDict[pokeUrl.name]!, favTypes: favTypes)
                    }
                }
                else {
                    self.tryGetPokemon(pokeUrl: pokeUrl, favTypes: favTypes)
                }
            })
        }
    }
    
    func populate(pokemon: Pokemon, favTypes: [String]?) {
        self.empty = false
        
        let effectsController = PokemonEffectsController(poke: pokemon)
        let effects = effectsController.getEffects()
        self.strongEffects = effects.filter({ $0.value < 100 }).sorted(by: { $0.value < $1.value })
        self.weakEffects = effects.filter({ $0.value > 100 }).sorted(by: { $0.value > $1.value })
        
        self.strongView.reloadData()
        self.weakView.reloadData()
        
        let types = favTypes != nil ? favTypes! : pokemon.data.types.compactMap({ $0.type.name })
        
        for i in 0...2 {
            if types.count > i {
                moveViews[i].isHidden = false
                formatMoveView(moveView: moveViews[i], type: typeDict[types[i]]!)
            }
            else {
                moveViews[i].isHidden = true
            }
        }
        
        self.contentView.isHidden = false
        self.mainActivityIndicator.stopAnimating()
    }
    
    func formatMoveView(moveView: UIView, type: TypeStruct) {
        (moveView.viewWithTag(11) as! UIImageView).tintColor = type.appearance.getColor()
        (moveView.viewWithTag(12) as! UIImageView).image = type.appearance.getImage()
        moveView.backgroundColor = type.appearance.getColor().withAlphaComponent(0.1)
        moveView.layer.borderColor = type.appearance.getColor().withAlphaComponent(0.5).cgColor
        moveView.layer.borderWidth = 0.5
        
        let effectiveTypes = type.data.damage_relations.double_damage_to.compactMap({ $0.name })
        let notEffectiveTypes = (type.data.damage_relations.half_damage_to + type.data.damage_relations.no_damage_to).compactMap({ $0.name })
        
        formatTypes(typeStack: moveView.viewWithTag(13) as! UIStackView, typeNames: effectiveTypes)
        formatTypes(typeStack: moveView.viewWithTag(14) as! UIStackView, typeNames: notEffectiveTypes)
    }
    
    func formatTypes(typeStack: UIStackView, typeNames: [String]) {
        
        for v in typeStack.subviews {
            v.isHidden = true
        }
        
        let size = min(typeStack.superview!.frame.size.height - 12, typeStack.superview!.bounds.size.width / CGFloat(typeNames.count))
        if let hConstraint = typeStack.constraints.first(where: { $0.identifier == "viewHeight"}) {
            hConstraint.constant = size
        }
        
        for i in 0...typeNames.count - 1 {
            let circle = typeStack.subviews[i].subviews[0] as! UIImageView
            let icon = typeStack.subviews[i].subviews[1] as! UIImageView
            circle.tintColor = typeDict[typeNames[i]]?.appearance.getColor()
            icon.image = typeDict[typeNames[i]]?.appearance.getImage()
            
            typeStack.subviews[i].isHidden = false
        }
    }
    
    func tryGetImage(pokeUrl: PokemonArrayResult.PokemonUrl) {
        self.imgActivityIndicator.startAnimating()
        
        if let img = pokeImageArray.first(where: { $0.id == pokeUrl.getId() }) {
            
            self.pokeImage.image = img.image
            self.pokeImage.layer.shadowColor = UIColor.black.cgColor
            self.pokeImage.layer.shadowRadius = 2.5
            self.pokeImage.layer.shadowOpacity = 0.45
            self.pokeImage.layer.shadowOffset = CGSize(width: 2.5, height: 4)
            
            self.imgActivityIndicator.stopAnimating()
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.tryGetImage(pokeUrl: pokeUrl)
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 6 {
            return self.strongEffects.count
        }
        else if collectionView.tag == 7 {
            return self.weakEffects.count
        }
        else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TypeCell", for: indexPath)
        
        var type: TypeStruct!
        
        if collectionView.tag == 6 {
            type = typeDict[strongEffects[indexPath.row].name]!
        }
        else {
            type = typeDict[weakEffects[indexPath.row].name]!
        }
        
        let circle = cell.contentView.subviews[0] as! UIImageView
        let icon = cell.contentView.subviews[1] as! UIImageView
        circle.tintColor = type.appearance.getColor()
        icon.image = type.appearance.getImage()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let size = min(collectionView.frame.size.width / 4 - 3, collectionView.frame.size.height / 2 - 2)
        let size = (collectionView.frame.size.width / 4)
        
        return CGSize(width: size, height: size)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return -2
    } 
}
