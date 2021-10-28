//
//  MainButtonCell.swift
//  Poke Guide
//
//  Created by Zack Blase on 10/8/21.
//

import UIKit

class MainButtonCell: UICollectionViewCell {

    var pokeUrl: PokemonArrayResult.PokemonUrl?
    var pokemon: Pokemon?
    var favTypes: [String]?
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellName: UILabel!
    //@IBOutlet var cellSubName: UILabel!
    @IBOutlet var cellNumber: UILabel!
    //@IBOutlet var pokemonButton: PokemonButton!
    @IBOutlet var typeBtnA: UIImageView!
    @IBOutlet var typeBtnB: UIImageView!
    @IBOutlet var typeBtnC: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCellIdentity(pokeUrl: PokemonArrayResult.PokemonUrl, favTypes: [String]? = nil) {
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        self.pokeUrl = pokeUrl
        //self.pokemonButton.pokeUrl = pokeUrl
        self.favTypes = favTypes
        
        if pokeUrl.name == "nidoran-f" {
            cellName.text = "Nidoran (F)"
        }
        else if pokeUrl.name == "nidoran-m" {
            cellName.text = "Nidoran (M)"
        }
        else {
            let names = pokeUrl.name.split(separator: "-")
            cellName.text = String(names[0]).capitalizingFirstLetter()
            if names.count > 1 {
                //cellSubName.text = String(names[1]).capitalizingFirstLetter()
                //cellSubName.isHidden = false
            }
            else {
                //cellSubName.isHidden = true
            }
        }
        
        
        
        cellNumber.text = "#\(pokeUrl.getId())"
        
        
        contentView.layer.cornerRadius = 12.0
        contentView.layer.borderWidth = 0.75
        contentView.layer.borderColor = UIColor(named: "ColorHomeCellBorder")!.cgColor
        contentView.backgroundColor = .tertiarySystemBackground
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowRadius = 1.0
        layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.2 : 0.4
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
        
        
        if poke.data.name == "nidoran-f" {
            cellName.text = "Nidoran (F)"
        }
        else if poke.data.name == "nidoran-m" {
            cellName.text = "Nidoran (M)"
        }
        else if poke.data.name == "mr-mime" {
            cellName.text = "Mr. Mime"
        }
        else if poke.data.name == "porygon-z" {
            cellName.text = "Porygon-Z"
        }
        else if poke.data.name == "ho-oh" {
            cellName.text = "Ho-Oh"
        }
        else {
            let names = poke.data.name.split(separator: "-")
            cellName.text = String(names[0]).capitalizingFirstLetter()
            if names.count > 1 {
                //cellSubName.text = String(names[1]).capitalizingFirstLetter()
                //cellSubName.isHidden = false
            }
            else {
                //cellSubName.isHidden = true
            }
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
        //self.pokemonButton.pokemon = poke
        cellImage.image = poke.image
        cellNumber.text = "#\(poke.data.id)"
        
        typeBtnA.isHidden = true
        typeBtnB.isHidden = true
        
        let typeArray = favTypes != nil ? favTypes : poke.data.types.sorted(by: { $0.slot < $1.slot }).map({ $0.type.name })
        
        if typeArray!.count > 0 {
            let type: TypeStruct = typeDict[typeArray![0].lowercased()]!
            configureTypeButton(imgView: typeBtnA, type: type.appearance)
        }
        
        if typeArray!.count > 1 {
            let type: TypeStruct = typeDict[typeArray![1].lowercased()]!
            configureTypeButton(imgView: typeBtnB, type: type.appearance)
        }
        
        if typeArray!.count > 2 {
            let type: TypeStruct = typeDict[typeArray![2].lowercased()]!
            configureTypeButton(imgView: typeBtnC, type: type.appearance)
        }
    }
    
    
    func configureTypeButton(imgView: UIImageView, type: TypeAppearance) {
        
        let fSize = type.fontSize != nil ? type.fontSize : 16.0
        let symConfig: UIImage.SymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont(name: "Helvetica Neue", size: CGFloat(fSize!))!)
        
        imgView.isHidden = false
        imgView.tintColor = type.getColor()
        imgView.image = type.getImage().withConfiguration(symConfig).withRenderingMode(.alwaysTemplate)
        imgView.contentMode = .scaleAspectFit
        //button.imageEdgeInsets = UIEdgeInsets(top: 1, left: 1, bottom: 0, right: 1)
        
    }
    
    func configureAsFav(fav: FavPokemonJson.FavJson) {
        //configure types and maybe name
        tryGetPokemon(name: fav.name)
    }
    
    func tryGetPokemon(name: String) {
        if name != self.pokeUrl!.name {
            return
        }
        
        if let poke = pokemonDict[name] {
            configureCellData(poke: poke)
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.tryGetPokemon(name: name)
            })
        }
    }
}
