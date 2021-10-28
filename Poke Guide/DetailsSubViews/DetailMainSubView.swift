//
//  DetailMainSubView.swift
//  Poke Guide
//
//  Created by Zack Blase on 8/11/21.
//

import UIKit

class DetailMainSubView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var rightView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var subNameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var genLabel: UILabel!
    @IBOutlet var regionLabel: UILabel!
    @IBOutlet var typeButtonA: UIButton!
    @IBOutlet var typeButtonB: UIButton!
    @IBOutlet var typeButtonC: UIButton!
    
    let test = ["Normal", "Galar"]
    var primaryColor: UIColor!
    var pokemon: Pokemon!
    var formUrls: [PokemonArrayResult.PokemonUrl]!
    var switchForms: ((PokemonArrayResult.PokemonUrl) -> Void)!
    
    
    public func configure(pokemon: Pokemon, forms: [PokemonArrayResult.PokemonUrl], fFunc: ((PokemonArrayResult.PokemonUrl) -> Void)?) {
        self.pokemon = pokemon
        self.formUrls = forms
        self.switchForms = fFunc
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.masksToBounds = false
        
        mainImage.image = pokemon.image
        mainImage.layer.shadowColor = UIColor.black.cgColor
        mainImage.layer.shadowRadius = 4.0
        mainImage.layer.shadowOpacity = 0.5
        mainImage.layer.shadowOffset = CGSize(width: 0, height: 4)
        mainImage.layer.masksToBounds = false
        
        let typeARef = pokemon.data.types.first(where: { $0.slot == 1 })!
        let typeA: TypeStruct = typeDict[typeARef.type.name]!
        self.primaryColor = typeA.appearance.getColor()
        
        
        
        
        
        self.backgroundView.backgroundColor = typeA.appearance.getColor().withAlphaComponent(0.08)
        
        rightView.layer.backgroundColor = typeA.appearance.getColor().withAlphaComponent(0.08).cgColor
        rightView.layer.borderColor = typeA.appearance.getColor().withAlphaComponent(0.5).cgColor
        rightView.layer.borderWidth = 1
        rightView.layer.cornerRadius = 10
        
        genLabel.isHidden = false
        regionLabel.isHidden = false
        
        for gen in genArray {
            if gen.pokemon_species.contains(where: { $0.name == pokemon.data.name }) {
                let strArray = gen.name.split(separator: "-")
                genLabel.text = "Generation \(strArray[1].uppercased())"
                regionLabel.text = "\(gen.main_region.name.capitalizingFirstLetter()) Region"
            }
        }
        
        let names = pokemon.data.name.split(separator: "-")
        if names.count == 1 {
            subNameLabel.isHidden = true
        }
        else {
            subNameLabel.text = String(names[1]).capitalizingFirstLetter()
            subNameLabel.isHidden = false
            
            if names.count > 2 {
                subNameLabel.text! += " - \(String(names[2]).capitalizingFirstLetter())"
            }
        }
        nameLabel.text = String(names[0]).capitalizingFirstLetter()
        numberLabel.text = "#\(pokemon.data.id)"
        
        typeButtonA.isHidden = true
        typeButtonB.isHidden = true
        typeButtonC.isHidden = true
        
        if pokemon.data.types.count > 0 {
            configureTypeButton(button: typeButtonA, type: typeA.appearance)
        }
        
        if pokemon.data.types.count > 1 {
            let typeBRef = pokemon.data.types.first(where: { $0.slot == 2 })
            let typeB: TypeStruct = typeDict[typeBRef!.type.name]!
            configureTypeButton(button: typeButtonB, type: typeB.appearance)
            
            self.backgroundView.backgroundColor = typeB.appearance.getColor().withAlphaComponent(0.08)
        }
        
        
    }
    
    func configureTypeButton(button: UIButton, type: TypeAppearance) {
        
        let fSize = type.fontSize != nil ? type.fontSize : 16.0
        let symConfig: UIImage.SymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont(name: "Helvetica Neue", size: CGFloat(fSize!))!)
        
        button.isHidden = false
        button.imageView?.tintColor = .white
        button.setImage(type.getImage().withConfiguration(symConfig), for: .normal)
        button.tintColor = type.getColor()
        button.menu = addMenuItem(type)
        button.showsMenuAsPrimaryAction = true
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = type.getInsets()
    }
    
    func addMenuItem(_ type: TypeAppearance) -> UIMenu {
        let menuItems = UIMenu(title: "", options: .destructive, children: [
            UIAction(title: type.name, image: type.getImage().withTintColor(.black), handler: { (_) in
                                    
                                })
        ])
        
        return menuItems
    }
    
    
}
