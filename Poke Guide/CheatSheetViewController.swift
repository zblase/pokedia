//
//  CheatSheetViewController.swift
//  Poke Guide
//
//  Created by Zack Blase on 12/22/21.
//

import UIKit

class CheatSheetViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var viewA: UIView!
    @IBOutlet var viewB: UIView!
    @IBOutlet var viewC: UIView!
    
    var slotArray: [UIView] = []
    var strongEffects: [TypeEffect] = []
    var weakEffects: [TypeEffect] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.homeCollectionVC.delegate = self
        
        slotArray = [viewA, viewB, viewC]
        
        for slot in slotArray {
            slot.layer.cornerRadius = 8
            slot.subviews[0].layer.borderColor = UIColor(named: "ColorEmptySlotBorder")?.cgColor
            slot.subviews[0].layer.borderWidth = 2
            slot.layer.masksToBounds = true
            (slot.viewWithTag(2) as! UICollectionView).delegate = self
            (slot.viewWithTag(2) as! UICollectionView).dataSource = self
            (slot.viewWithTag(3) as! UICollectionView).delegate = self
            (slot.viewWithTag(3) as! UICollectionView).dataSource = self
        }
    }
    
    func configure() {
        
    }
    
    @IBAction func showAddListView(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeController") as! HomeCollectionViewController
        vc.title = "Add to Cheat Sheet"
        vc.addSlotFunction = self.tryGetPokemon(pokeUrl: )
        vc.cvMarginValue = 30
        self.show(vc, sender: self)
    }
    
    func tryGetPokemon(pokeUrl: PokemonArrayResult.PokemonUrl) {
        
        if let poke = pokemonDict[pokeUrl.name] {
            addPokemon(pokemon: poke)
        }
        else {
            let pokeController = PokemonDataController()
            pokeController.requestPokemonData(url: pokeUrl.url, completion: {(success) -> Void in
                if success {
                    DispatchQueue.main.async {
                        self.addPokemon(pokemon: pokemonDict[pokeUrl.name]!)
                    }
                }
                else {
                    self.tryGetPokemon(pokeUrl: pokeUrl)
                }
            })
        }
    }
    
    func addPokemon(pokemon: Pokemon) {
        
        let emptySlot = self.getFirstEmptySlot()
        
        let effectsController = PokemonEffectsController(poke: pokemon)
        let effects = effectsController.getEffects()
        self.strongEffects = effects.filter({ $0.value < 100 }).sorted(by: { $0.value < $1.value })
        self.weakEffects = effects.filter({ $0.value > 100 }).sorted(by: { $0.value > $1.value })
        
        (emptySlot.viewWithTag(1) as! UIImageView).image = pokemon.image
        (emptySlot.viewWithTag(2) as! UICollectionView).reloadData()
        (emptySlot.viewWithTag(3) as! UICollectionView).reloadData()
        
        let types = pokemon.favTypes.count > 0 ? pokemon.favTypes : pokemon.data.types.compactMap({ $0.type.name })
        let typeA = typeDict[types[0]]!
        (emptySlot.viewWithTag(4)?.subviews[0] as! UIImageView).tintColor = typeA.appearance.getColor()
        (emptySlot.viewWithTag(4)?.subviews[1] as! UIImageView).image = typeA.appearance.getImage()
        emptySlot.viewWithTag(4)?.superview?.backgroundColor = typeA.appearance.getColor().withAlphaComponent(0.08)
        let typeAEffectives = typeA.data.damage_relations.double_damage_to.compactMap({ $0.name })
        let typeANotEffectives = (typeA.data.damage_relations.half_damage_to + typeA.data.damage_relations.no_damage_to).compactMap({ $0.name })
        
        formatTypes(view: emptySlot.viewWithTag(5)! as! UIStackView, typeNames: typeAEffectives)
        formatTypes(view: emptySlot.viewWithTag(6)! as! UIStackView, typeNames: typeANotEffectives)
        
        if types.count > 1 {
            let typeB = typeDict[types[1]]!
            (emptySlot.viewWithTag(7)?.subviews[0] as! UIImageView).tintColor = typeB.appearance.getColor()
            (emptySlot.viewWithTag(7)?.subviews[1] as! UIImageView).image = typeB.appearance.getImage()
            emptySlot.viewWithTag(7)?.superview?.backgroundColor = typeB.appearance.getColor().withAlphaComponent(0.08)
            let typeBEffectives = typeB.data.damage_relations.double_damage_to.compactMap({ $0.name })
            let typeBNotEffectives = (typeB.data.damage_relations.half_damage_to + typeB.data.damage_relations.no_damage_to).compactMap({ $0.name })
            
            formatTypes(view: emptySlot.viewWithTag(8)! as! UIStackView, typeNames: typeBEffectives)
            formatTypes(view: emptySlot.viewWithTag(9)! as! UIStackView, typeNames: typeBNotEffectives)
        }
        else {
            emptySlot.viewWithTag(7)?.superview?.isHidden = true
        }
        
        if types.count > 2 {
            let typeC = typeDict[types[2]]!
            (emptySlot.viewWithTag(10)?.subviews[0] as! UIImageView).tintColor = typeC.appearance.getColor()
            (emptySlot.viewWithTag(10)?.subviews[1] as! UIImageView).image = typeC.appearance.getImage()
            emptySlot.viewWithTag(10)?.superview?.backgroundColor = typeC.appearance.getColor().withAlphaComponent(0.08)
            let typeCEffectives = typeC.data.damage_relations.double_damage_to.compactMap({ $0.name })
            let typeCNotEffectives = (typeC.data.damage_relations.half_damage_to + typeC.data.damage_relations.no_damage_to).compactMap({ $0.name })
            
            formatTypes(view: emptySlot.viewWithTag(11)! as! UIStackView, typeNames: typeCEffectives)
            formatTypes(view: emptySlot.viewWithTag(12)! as! UIStackView, typeNames: typeCNotEffectives)
        }
        else {
            emptySlot.viewWithTag(10)?.superview?.isHidden = true
        }
        
        emptySlot.subviews[1].isHidden = false
    }
    
    func getFirstEmptySlot(i: Int = 0) -> UIView {
        if slotArray[i].subviews[1].isHidden {
            return slotArray[i]
        }
        else {
            return getFirstEmptySlot(i: i + 1)
        }
    }
    
    func formatTypes(view: UIStackView, typeNames: [String]) {
        
        for v in view.subviews {
            v.isHidden = true
        }
        for i in 0...typeNames.count - 1 {
            (view.subviews[i].subviews[0] as! UIImageView).tintColor = typeDict[typeNames[i]]?.appearance.getColor()
            (view.subviews[i].subviews[1] as! UIImageView).image = typeDict[typeNames[i]]?.appearance.getImage()
            
            view.subviews[i].isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 2 {
            return self.strongEffects.count
        }
        else if collectionView.tag == 3 {
            return self.weakEffects.count
        }
        else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TypeCell", for: indexPath)
        
        var type: TypeStruct!
        
        if collectionView.tag == 2 {
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
        
        let size = min(collectionView.frame.size.width / 4 - 4, collectionView.frame.size.height / 3 - 4)
        
        return CGSize(width: size, height: size)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return -2
    }

}
