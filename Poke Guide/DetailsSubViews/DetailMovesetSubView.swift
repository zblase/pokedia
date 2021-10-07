//
//  DetailMovesetSubView.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/23/21.
//

import UIKit

class DetailMovesetSubView: ToggleViewButton, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var chevron: UIImageView!
    @IBOutlet var viewButton: UIButton!
    @IBOutlet var divider: UIImageView!
    @IBOutlet var subView: UIView!
    @IBOutlet var moveViewA: UIView!
    @IBOutlet var moveViewB: UIView!
    @IBOutlet var moveViewC: UIView!
    @IBOutlet var typeCollection: UICollectionView!
    @IBOutlet var suggestedCollection: UICollectionView!
    
    var primaryColor: UIColor?
    var secondaryColor: UIColor?
    var moveTypes: [TypeStruct] = []
    var suggestedPokemon: [PokemonEffectScore] = []
    var detailVC: DetailsViewController!
    var selectedTypes: [TypeStruct] = []
    
    var titles: [String] = ["charmander", "mew", "onix", "caterpie", "gengar", "machoke", "machamp", "dragonite", "venusaur", "bulbasaur", "ivysaur", "sandslash-alola"]
    
    public func configure(pokemon: Pokemon, detailVC: DetailsViewController) {
        self.isHidden = true
        self.detailVC = detailVC
        subView.layer.masksToBounds = true
        primaryColor = pokemon.data.getTypeStruct(slot: 1).appearance.getColor()
        secondaryColor = pokemon.data.types.count > 1 ? pokemon.data.getTypeStruct(slot: 2).appearance.getColor() : primaryColor
        
        configureButton(button: viewButton, color: primaryColor!, chevron: chevron, divider: divider)
        configureSubView(subView: subView, color: secondaryColor!)
        
        for type in pokemon.moveTypes {
            moveTypes.append(typeDict[type]!)
        }
        
        for type in pokemon.data.types {
            selectedTypes.append(typeDict[type.type.name]!)
        }
        
        
        moveViewA.superview?.backgroundColor = .secondarySystemBackground
        moveViewA.superview?.layer.masksToBounds = false
        moveViewA.superview?.layer.cornerRadius = 8
        moveViewA.superview?.layer.borderWidth = 1
        moveViewA.superview?.layer.borderColor = UIColor.gray.cgColor
        moveViewB.superview?.backgroundColor = .secondarySystemBackground
        moveViewB.superview?.layer.masksToBounds = false
        moveViewB.superview?.layer.cornerRadius = 8
        moveViewB.superview?.layer.borderWidth = 1
        moveViewB.superview?.layer.borderColor = UIColor.gray.cgColor
        moveViewC.superview?.backgroundColor = .secondarySystemBackground
        moveViewC.superview?.layer.masksToBounds = false
        moveViewC.superview?.layer.cornerRadius = 8
        moveViewC.superview?.layer.borderWidth = 1
        moveViewC.superview?.layer.borderColor = UIColor.gray.cgColor
        
        refreshSelectedTypes()
        
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
        
        var newFrame = self.frame

        newFrame.size.width = self.frame.width
        newFrame.size.height = 400
        self.frame = newFrame
        
        self.layer.frame.size = CGSize(width: self.layer.frame.size.width, height: self.typeCollection.layer.frame.size.height + 20)
        
        self.suggestedCollection.reloadData()
    }
    
    func configureSelectedTypeBase(view: UIView) {
        
        view.superview?.layer.shadowColor = UIColor.black.cgColor
        view.superview?.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.superview?.layer.shadowRadius = 1.0
        view.superview?.layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.15 : 0.4
        view.superview?.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius).cgPath
    }
    
    func refreshSelectedTypes() {
        moveViewA.isHidden = true
        moveViewB.isHidden = true
        moveViewC.isHidden = true
        
        if self.selectedTypes.count > 0 {
            configureSelectedType(cell: moveViewA, type: self.selectedTypes[0])
            configureSelectedTypeBase(view: moveViewA)
        }
        if self.selectedTypes.count > 1 {
            configureSelectedType(cell: moveViewB, type: self.selectedTypes[1])
            configureSelectedTypeBase(view: moveViewB)
        }
        if self.selectedTypes.count > 2 {
            configureSelectedType(cell: moveViewC, type: self.selectedTypes[2])
            configureSelectedTypeBase(view: moveViewC)
        }
        
        self.suggestedPokemon.removeAll()
        var relations: [String: Double] = [:]
        
        for typeStruct in selectedTypes {
            
            for rel in typeStruct.data.damage_relations.double_damage_to {
                if relations[rel.name] != nil {
                    relations[rel.name]! += 1
                }
                else {
                    relations[rel.name] = 1
                }
            }
            for rel in typeStruct.data.damage_relations.half_damage_to {
                if relations[rel.name] != nil {
                    relations[rel.name]! -= 1
                }
                else {
                    relations[rel.name] = -1
                }
            }
            for rel in typeStruct.data.damage_relations.no_damage_to {
                if relations[rel.name] != nil {
                    relations[rel.name]! -= 2
                }
                else {
                    relations[rel.name] = -2
                }
            }
        }
        
        for poke in pokeUrlArray!.urlArray {
            guard let pokeDictVal = pokemonDict[poke.name] else { continue }
            var effScore = PokemonEffectScore(poke: pokeDictVal)
            
            for typeRef in pokeDictVal.data.types {
                if let effect = relations[typeRef.type.name], effect != 0 {
                    effScore.score += relations[typeRef.type.name]!
                }
            }
            
            if !effScore.pokemon.data.name.contains("-mega") {
                if effScore.score > 0 {
                    print("name: \(effScore.pokemon.data.name) - score: \(effScore.score)")
                    self.suggestedPokemon.append(effScore)
                }
            }
        }
        
        self.suggestedPokemon.sort {
            ($0.score, $0.pokemon.data.stats.first(where: { $0.stat.name == "defense" })!.base_stat) >
            ($1.score, $1.pokemon.data.stats.first(where: { $0.stat.name == "defense" })!.base_stat)
        }
        
        self.typeCollection.reloadData()
        self.suggestedCollection.reloadData()
    }
    
    func configureSelectedType(cell: UIView, type: TypeStruct) {
        cell.layer.cornerRadius = 8
        cell.layer.borderWidth = 1
        cell.layer.borderColor = type.appearance.getColor().cgColor
        cell.layer.backgroundColor = type.appearance.getColor().withAlphaComponent(0.35).cgColor
        
        let icon = cell.subviews[0] as! UIImageView
        let label = cell.subviews[1] as! UILabel
        
        icon.image = type.appearance.getImage().withRenderingMode(.alwaysTemplate)
        label.text = type.appearance.name
        
        cell.superview?.layer.borderWidth = 0
        cell.superview?.layer.shadowColor = UIColor.black.cgColor
        cell.superview?.layer.shadowOffset = CGSize(width: 2, height: 2)
        cell.superview?.layer.shadowRadius = 1.0
        cell.superview?.layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.15 : 0.4
        cell.superview?.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.layer.cornerRadius).cgPath
        cell.isHidden = false
    }
    
    @IBAction func clearSelectedType(_ sender: Any?) {
        let btn = sender as! UIButton
        configureUnselectedType(cell: btn.superview!)
    }
    
    func configureUnselectedType(cell: UIView) {
        cell.superview?.layer.borderWidth = 1
        cell.superview?.layer.shadowOpacity = 0
        cell.isHidden = true
        
        
        let index = cell.tag
        self.selectedTypes.remove(at: index)
        refreshSelectedTypes()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.suggestedCollection {
            return self.suggestedPokemon.count
        }
        else {
            return self.moveTypes.count
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
            sCell.configure(pokemon: suggestedPokemon[indexPath.row].pokemon, color: self.primaryColor!, types: types, msView: self)
        }
        else {
            let tCell = cell as! TypeButtonCell
            let type = moveTypes[indexPath.row]
            tCell.configure(type: type, text: type.appearance.name, msView: self, isSel: self.selectedTypes.contains(where: { $0.appearance.name == type.appearance.name }))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //print("didDisplay: \(indexPath)")
    }
    
    /*func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        if collectionView == self.suggestedCollection {
            print("title: \(title) - index: \(index)")
            guard let index = suggestedPokemon.firstIndex(where: { $0.data.name.prefix(1) == title }) else {
                return IndexPath(item: 0, section: 0)
            }
            return IndexPath(item: index, section: 0)
        }
        
        return IndexPath(item: 0, section: 0)
    }*/
    
    
    
    func typeCellTapped(cell: TypeButtonCell) {
        //self.detailVC.typeCellTapped(type: type)
        if !cell.isSel {
            
            if self.selectedTypes.count < 3 {
                self.selectedTypes.append(cell.type!)
            }
            else {
                self.selectedTypes[2] = cell.type!
            }
        }
        else {
            
            self.selectedTypes.removeAll(where: { $0.appearance.name == cell.type!.appearance.name })
        }
        
        refreshSelectedTypes()
    }
    
    func pokeCellTapped(poke: Pokemon) {
        self.detailVC.showNextVC(pokemon: poke)
    }
}
