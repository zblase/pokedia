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
            slot.layer.borderColor = UIColor(named: "ColorEmptySlotBorder")?.cgColor
            slot.layer.borderWidth = 1
            slot.layer.masksToBounds = true
            (slot.subviews[2] as! UIActivityIndicatorView).stopAnimating()
            let strongView = slot.viewWithTag(2)!.superview!
            strongView.layer.borderColor = UIColor.green.withAlphaComponent(0.5).cgColor
            strongView.layer.borderWidth = 0.5
            let weakView = slot.viewWithTag(3)!.superview!
            weakView.layer.borderColor = UIColor.red.withAlphaComponent(0.5).cgColor
            weakView.layer.borderWidth = 0.5
            (slot.viewWithTag(2) as! UICollectionView).delegate = self
            (slot.viewWithTag(2) as! UICollectionView).dataSource = self
            (slot.viewWithTag(3) as! UICollectionView).delegate = self
            (slot.viewWithTag(3) as! UICollectionView).dataSource = self
        }
        
        let cheatSheetParser = CheatSheetJsonParser()
        let csPokes = cheatSheetParser.readJson()
        for poke in csPokes.favArray {
            var types: [String]? = poke.types
            if poke.types.count == 0 {
                types = nil
            }
            tryGetPokemon(pokeUrl: (pokeUrlArray?.urlArray.first(where: { $0.name == poke.name }))!, favTypes: types)
        }
    }
    
    @IBAction func showAddListView(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeController") as! HomeCollectionViewController
        vc.title = "Add to Cheat Sheet"
        vc.addSlotFunction = self.addNewPokemon(pokeUrl: favTypes:)
        vc.cvMarginValue = 30
        self.show(vc, sender: self)
    }
    
    func addNewPokemon(pokeUrl: PokemonArrayResult.PokemonUrl, favTypes: [String]?) {
        let csParser = CheatSheetJsonParser()
        let types = (favTypes == nil ? [] : favTypes)!
        let poke = FavPokemonJson.FavJson(name: pokeUrl.name, types: types)
        csParser.addSlot(fav: poke)
        
        self.tryGetPokemon(pokeUrl: pokeUrl, favTypes: favTypes)
    }
    
    func tryGetPokemon(pokeUrl: PokemonArrayResult.PokemonUrl, favTypes: [String]?) {
        let emptySlot = self.getFirstEmptySlot()
        (emptySlot.subviews[2] as! UIActivityIndicatorView).startAnimating()
        
        if let poke = pokemonDict[pokeUrl.name] {
            addPokemon(pokemon: poke, favTypes: favTypes)
        }
        else {
            let pokeController = PokemonDataController()
            pokeController.requestPokemonData(url: pokeUrl.url, completion: {(success) -> Void in
                if success {
                    DispatchQueue.main.async {
                        self.addPokemon(pokemon: pokemonDict[pokeUrl.name]!, favTypes: favTypes)
                    }
                }
                else {
                    self.tryGetPokemon(pokeUrl: pokeUrl, favTypes: favTypes)
                }
            })
        }
    }
    
    func addPokemon(pokemon: Pokemon, favTypes: [String]?) {
        
        let emptySlot = self.getFirstEmptySlot()
        
        let effectsController = PokemonEffectsController(poke: pokemon)
        let effects = effectsController.getEffects()
        self.strongEffects = effects.filter({ $0.value < 100 }).sorted(by: { $0.value < $1.value })
        self.weakEffects = effects.filter({ $0.value > 100 }).sorted(by: { $0.value > $1.value })
        
        (emptySlot.viewWithTag(13) as! UILabel).text = pokemon.data.name.capitalizingFirstLetter()
        let pokeImg = (emptySlot.viewWithTag(1) as! UIImageView)
        pokeImg.image = pokemon.image
        pokeImg.layer.shadowColor = UIColor.black.cgColor
        pokeImg.layer.shadowRadius = 2.5
        pokeImg.layer.shadowOpacity = 0.45
        pokeImg.layer.shadowOffset = CGSize(width: 2.5, height: 4)
        (emptySlot.viewWithTag(2) as! UICollectionView).reloadData()
        (emptySlot.viewWithTag(3) as! UICollectionView).reloadData()
        
        let types = favTypes != nil ? favTypes! : pokemon.data.types.compactMap({ $0.type.name })
        let typeA = typeDict[types[0]]!
        (emptySlot.viewWithTag(4)?.subviews[0] as! UIImageView).tintColor = typeA.appearance.getColor()
        (emptySlot.viewWithTag(4)?.subviews[1] as! UIImageView).image = typeA.appearance.getImage()
        emptySlot.viewWithTag(4)?.superview?.backgroundColor = typeA.appearance.getColor().withAlphaComponent(0.1)
        emptySlot.viewWithTag(4)?.superview?.layer.borderColor = typeA.appearance.getColor().withAlphaComponent(0.5).cgColor
        emptySlot.viewWithTag(4)?.superview?.layer.borderWidth = 0.5
        let typeAEffectives = typeA.data.damage_relations.double_damage_to.compactMap({ $0.name })
        let typeANotEffectives = (typeA.data.damage_relations.half_damage_to + typeA.data.damage_relations.no_damage_to).compactMap({ $0.name })
        
        formatTypes(view: emptySlot.viewWithTag(5)! as! UIStackView, typeNames: typeAEffectives)
        formatTypes(view: emptySlot.viewWithTag(6)! as! UIStackView, typeNames: typeANotEffectives)
        
        if types.count > 1 {
            let typeB = typeDict[types[1]]!
            (emptySlot.viewWithTag(7)?.subviews[0] as! UIImageView).tintColor = typeB.appearance.getColor()
            (emptySlot.viewWithTag(7)?.subviews[1] as! UIImageView).image = typeB.appearance.getImage()
            emptySlot.viewWithTag(7)?.superview?.backgroundColor = typeB.appearance.getColor().withAlphaComponent(0.1)
            emptySlot.viewWithTag(7)?.superview?.layer.borderColor = typeB.appearance.getColor().withAlphaComponent(0.5).cgColor
            emptySlot.viewWithTag(7)?.superview?.layer.borderWidth = 0.5
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
            emptySlot.viewWithTag(10)?.superview?.backgroundColor = typeC.appearance.getColor().withAlphaComponent(0.1)
            emptySlot.viewWithTag(10)?.superview?.layer.borderColor = typeC.appearance.getColor().withAlphaComponent(0.5).cgColor
            emptySlot.viewWithTag(10)?.superview?.layer.borderWidth = 0.5
            let typeCEffectives = typeC.data.damage_relations.double_damage_to.compactMap({ $0.name })
            let typeCNotEffectives = (typeC.data.damage_relations.half_damage_to + typeC.data.damage_relations.no_damage_to).compactMap({ $0.name })
            
            formatTypes(view: emptySlot.viewWithTag(11)! as! UIStackView, typeNames: typeCEffectives)
            formatTypes(view: emptySlot.viewWithTag(12)! as! UIStackView, typeNames: typeCNotEffectives)
        }
        else {
            emptySlot.viewWithTag(10)?.superview?.isHidden = true
        }
        
        emptySlot.subviews[1].isHidden = false
        (emptySlot.subviews[2] as! UIActivityIndicatorView).stopAnimating()
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
        
        let size = min(view.superview!.frame.size.height - 12, view.superview!.frame.size.width / CGFloat(typeNames.count))
        if let hConstraint = view.constraints.first(where: { $0.identifier == "viewHeight"}) {
            hConstraint.constant = size
        }
        
        for i in 0...typeNames.count - 1 {
            let circle = view.subviews[i].subviews[0] as! UIImageView
            let icon = view.subviews[i].subviews[1] as! UIImageView
            circle.tintColor = typeDict[typeNames[i]]?.appearance.getColor()
            icon.image = typeDict[typeNames[i]]?.appearance.getImage()
            
            view.subviews[i].isHidden = false
        }
    }
    
    @IBAction func clearSlot(_ sender: Any) {
        let closeBtn = sender as! UIButton
        
        let slotView = closeBtn.superview!
        let wrapperView = slotView.superview!.superview!
        let index = wrapperView.subviews.firstIndex(of: slotView.superview!)!
        
        let csParser = CheatSheetJsonParser()
        let slotPokes = csParser.readJson()
        csParser.removeSlot(fav: slotPokes.favArray[index])
        
        slotView.isHidden = true
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
        
        var size = min(collectionView.frame.size.width / 4 - 4, collectionView.frame.size.height / 3 - 4)
        size = collectionView.frame.size.width / 4 - 4
        
        return CGSize(width: size, height: size)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return -2
    }

}
