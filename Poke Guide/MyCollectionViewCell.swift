//
//  MyCollectionViewCell.swift
//  Poke Guide
//
//  Created by Zack Blase on 8/8/21.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    static let identifier = "MyCollectionViewCell"
    
    var pokeUrl: PokemonArrayResult.PokemonUrl?
    var pokemon: Pokemon?
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellName: UILabel!
    @IBOutlet var cellSubName: UILabel!
    @IBOutlet var cellNumber: UILabel!
    @IBOutlet var pokemonButton: PokemonButton!
    @IBOutlet var typeBtnA: UIButton!
    @IBOutlet var typeBtnB: UIButton!
    
    func configureCellIdentity(pokeUrl: PokemonArrayResult.PokemonUrl) {
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        self.pokeUrl = pokeUrl
        self.pokemonButton.pokeUrl = pokeUrl
        
        let names = pokeUrl.name.split(separator: "-")
        cellName.text = String(names[0]).capitalizingFirstLetter()
        if names.count > 1 {
            cellSubName.text = String(names[1]).capitalizingFirstLetter()
            cellSubName.isHidden = false
        }
        else {
            cellSubName.isHidden = true
        }
        
        cellNumber.text = "#\(pokeUrl.getId())"
        
        
        contentView.layer.cornerRadius = 12.0
        contentView.layer.borderWidth = 0.75
        contentView.layer.borderColor = UIColor(named: "ColorHomeCellBorder")!.cgColor
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowRadius = 1.0
        layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.15 : 0.4
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        
        if pokemon == nil || pokemon!.data.name != pokeUrl.name {
            cellImage.image = UIImage()
            typeBtnA.isHidden = true
            typeBtnB.isHidden = true
            activityIndicator.startAnimating()
        }
        else {
            
            cellImage.layer.shadowColor = UIColor.black.cgColor
            cellImage.layer.shadowRadius = 2.5
            cellImage.layer.shadowOpacity = 0.45
            cellImage.layer.shadowOffset = CGSize(width: 2.5, height: 4)
            cellImage.layer.masksToBounds = false
        }
        
        tryGetPokemon(name: pokeUrl.name)
    }
    
    func configureCellData(poke: Pokemon) {
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        
        let names = poke.data.name.split(separator: "-")
        cellName.text = String(names[0]).capitalizingFirstLetter()
        if names.count > 1 {
            cellSubName.text = String(names[1]).capitalizingFirstLetter()
            cellSubName.isHidden = false
        }
        else {
            cellSubName.isHidden = true
        }
        
        contentView.layer.cornerRadius = 12.0
        contentView.layer.borderWidth = 0.75
        contentView.layer.borderColor = UIColor(named: "ColorHomeCellBorder")!.cgColor
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowRadius = 1.0
        layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.15 : 0.4
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        
        cellImage.layer.shadowColor = UIColor.black.cgColor
        cellImage.layer.shadowRadius = 2.5
        cellImage.layer.shadowOpacity = 0.45
        cellImage.layer.shadowOffset = CGSize(width: 2.5, height: 4)
        cellImage.layer.masksToBounds = false
        
        self.activityIndicator.stopAnimating()
        self.pokemon = poke
        self.pokemonButton.pokemon = poke
        //cellImage.image = poke.getImage()
        self.tryGetImage(id: self.pokeUrl!.getId())
        cellNumber.text = "#\(poke.data.id)"
        
        typeBtnA.isHidden = true
        typeBtnB.isHidden = true
        
        if poke.data.types.count > 0 {
            let typeARef = poke.data.types.first(where: { $0.slot == 1 })!
            let typeA: TypeStruct = typeDict[typeARef.type.name]!
            configureTypeButton(button: typeBtnA, type: typeA.appearance)
        }
        
        if poke.data.types.count > 1 {
            let typeBRef = poke.data.types.first(where: { $0.slot == 2 })
            let typeB: TypeStruct = typeDict[typeBRef!.type.name]!
            configureTypeButton(button: typeBtnB, type: typeB.appearance)
        }
    }
    
    
    func configureTypeButton(button: UIButton, type: TypeAppearance) {
        
        let fSize = type.fontSize != nil ? type.fontSize : 16.0
        let symConfig: UIImage.SymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont(name: "Helvetica Neue", size: CGFloat(fSize!))!)
        
        button.isHidden = false
        button.imageView?.tintColor = type.getColor()
        button.setImage(type.getImage().withConfiguration(symConfig).withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .clear
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 1, left: 1, bottom: 0, right: 1)
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = type.getImage().withConfiguration(symConfig).withRenderingMode(.alwaysTemplate)
            config.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    func tryGetImage(id: String) {
        
        if let img = pokeImageArray.first(where: { $0.id == id }) {
            cellImage.image = img.image
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.tryGetImage(id: id)
            })
        }
    }
    
    func tryGetPokemon(name: String) {
        if let poke = pokemonDict[name] {
            configureCellData(poke: poke)
            self.activityIndicator.stopAnimating()
        }
        else {
            self.cellImage.image = nil
            self.activityIndicator.startAnimating()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.tryGetPokemon(name: name)
            })
        }
    }
}
