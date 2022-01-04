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
    @IBOutlet var suggestedBackground: UIView!
    @IBOutlet var toggleView: UIView!
    
    var primaryColor: UIColor?
    var secondaryColor: UIColor?
    var moveTypes: [TypeStruct] = []
    var suggestedPokemon: [PokemonEffectScore] = []
    var suggestedAll: [PokemonEffectScore] = []
    var suggestedFav: [PokemonEffectScore] = []
    var detailVC: DetailsViewController!
    var selectedTypes: [TypeStruct] = []
    
    public func configure(pokemon: Pokemon, detailVC: DetailsViewController) {
        //self.isHidden = true
        self.detailVC = detailVC
        subView.layer.masksToBounds = true
        primaryColor = pokemon.data.getTypeStruct(slot: 1).appearance.getColor()
        secondaryColor = pokemon.data.types.count > 1 ? pokemon.data.getTypeStruct(slot: 2).appearance.getColor() : primaryColor
        
        self.toggleView.layer.cornerRadius = 15
        self.toggleView.layer.borderColor = primaryColor?.cgColor
        self.toggleView.layer.borderWidth = 1
        let allBtn = self.toggleView.subviews[0] as! UIButton
        allBtn.layer.cornerRadius = 12
        allBtn.backgroundColor = primaryColor
        allBtn.tintColor = .white
        let favBtn = self.toggleView.subviews[1] as! UIButton
        favBtn.layer.cornerRadius = 12
        favBtn.backgroundColor = .clear
        favBtn.tintColor = primaryColor
        
        
        configureButton(button: viewButton, color: primaryColor!, chevron: chevron, divider: divider)
        configureSubView(subView: subView, color: secondaryColor!)
        
        if !self.isHidden {
            highlightButton(button: viewButton, color: primaryColor!)
        }
        
        moveTypes.removeAll()
        for type in pokemon.moveTypes {
            moveTypes.append(typeDict[type]!)
        }
        
        selectedTypes.removeAll()
        let types = detailVC.favTypes != nil ? detailVC.favTypes : pokemon.data.types.map({ $0.type.name })
        for type in types! {
            selectedTypes.append(typeDict[type.lowercased()]!)
        }
        
        
        self.suggestedBackground.backgroundColor = secondaryColor?.withAlphaComponent(0.075)
        self.suggestedBackground.subviews[0].backgroundColor = secondaryColor?.withAlphaComponent(0.2)
        self.suggestedBackground.subviews[1].backgroundColor = secondaryColor?.withAlphaComponent(0.2)
        
        
        moveViewA.superview?.layer.masksToBounds = false
        moveViewA.superview?.layer.cornerRadius = 12.5
        moveViewA.superview?.layer.borderColor = UIColor.gray.cgColor
        moveViewB.superview?.layer.masksToBounds = false
        moveViewB.superview?.layer.cornerRadius = 12.5
        moveViewB.superview?.layer.borderColor = UIColor.gray.cgColor
        moveViewC.superview?.layer.masksToBounds = false
        moveViewC.superview?.layer.cornerRadius = 12.5
        moveViewC.superview?.layer.borderColor = UIColor.gray.cgColor
        
        refreshSelectedTypes()
        
        self.suggestedPokemon = self.suggestedAll
        
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
        
        self.suggestedCollection.reloadData()
        self.typeCollection.reloadData()
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
        else {
            configureUnselectedType(cell: moveViewA)
        }
        if self.selectedTypes.count > 1 {
            configureSelectedType(cell: moveViewB, type: self.selectedTypes[1])
            configureSelectedTypeBase(view: moveViewB)
        }
        else {
            configureUnselectedType(cell: moveViewB)
        }
        if self.selectedTypes.count > 2 {
            configureSelectedType(cell: moveViewC, type: self.selectedTypes[2])
            configureSelectedTypeBase(view: moveViewC)
        }
        else {
            configureUnselectedType(cell: moveViewC)
        }
        
        self.suggestedPokemon.removeAll()
        self.suggestedAll.removeAll()
        self.suggestedFav.removeAll()
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
            var effScore = PokemonEffectScore(poke: pokeDictVal, url: poke)
            
            for typeRef in pokeDictVal.data.types {
                if let effect = relations[typeRef.type.name], effect != 0 {
                    effScore.score += relations[typeRef.type.name]!
                }
            }
            
            if !effScore.pokeUrl.name.contains("-mega") {
                if effScore.score > 0 {
                    self.suggestedAll.append(effScore)
                }
            }
        }
        
        //FIND NEW METHOD FOR SORTING THAT DOESN'T INVOLVE REQUESTING EVERY POKEMON'S DATA
        /*self.suggestedAll.sort {
            ($0.score, $0.pokemon.data.stats.first(where: { $0.stat.name == "defense" })!.base_stat) >
            ($1.score, $1.pokemon.data.stats.first(where: { $0.stat.name == "defense" })!.base_stat)
        }*/
        
        guard let favPoke = favPokemon else {
            self.typeCollection.reloadData()
            self.suggestedCollection.reloadData()
            
            return
        }
        
        for poke in favPoke.favArray {
            guard let pokeDictVal = pokemonDict[poke.name] else { continue }
            var effScore = PokemonEffectScore(poke: pokeDictVal, url: (pokeUrlArray?.urlArray.first(where: { $0.name == poke.name }))!)
            
            for typeRef in pokeDictVal.data.types {
                if let effect = relations[typeRef.type.name], effect != 0 {
                    effScore.score += relations[typeRef.type.name]!
                }
            }
            
            if !effScore.pokeUrl.name.contains("-mega") {
                if effScore.score > 0 {
                    self.suggestedFav.append(effScore)
                }
            }
        }
        
        //FIND NEW METHOD FOR SORTING THAT DOESN'T INVOLVE REQUESTING EVERY POKEMON'S DATA
        /*self.suggestedFav.sort {
            ($0.score, $0.pokemon.data.stats.first(where: { $0.stat.name == "defense" })!.base_stat) >
            ($1.score, $1.pokemon.data.stats.first(where: { $0.stat.name == "defense" })!.base_stat)
        }*/
        
        self.typeCollection.reloadData()
        self.suggestedCollection.reloadData()
    }
    
    func configureSelectedType(cell: UIView, type: TypeStruct) {
        cell.layer.cornerRadius = 12.5
        cell.layer.borderWidth = 1
        cell.layer.borderColor = type.appearance.getColor().cgColor
        //cell.layer.borderColor = UIColor(named: "ColorButtonBorder")!.cgColor
        //cell.layer.backgroundColor = type.appearance.getColor().withAlphaComponent(0.45).cgColor
        cell.layer.backgroundColor = type.appearance.getColor().cgColor
        
        let icon = cell.subviews[0] as! UIImageView
        let label = cell.subviews[1] as! UILabel
        
        icon.image = type.appearance.getImage().withRenderingMode(.alwaysTemplate)
        label.text = type.appearance.name
        
        cell.superview?.backgroundColor = .secondarySystemBackground
        cell.superview?.layer.borderWidth = 0
        cell.superview?.layer.shadowColor = UIColor.black.cgColor
        cell.superview?.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        cell.superview?.layer.shadowRadius = 0.75
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
        cell.superview?.backgroundColor = .clear
        cell.isHidden = true
        
        
        let index = cell.tag
        if index < self.selectedTypes.count {
            self.selectedTypes.remove(at: index)
            refreshSelectedTypes()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.suggestedCollection {
            return self.suggestedPokemon.count
        }
        else {
            return 18
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
            return CGSize(width: (collectionView.frame.size.width - 30) / 4, height: 25)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.suggestedCollection {
            let sCell = cell as! SuggestedButtonCell
            let types = pokeTypes.first(where: { String($0.id) == suggestedPokemon[indexPath.row].pokeUrl.getId()})!.types.map({ typeNames[$0.type-1] })
            //let types = suggestedPokemon[indexPath.row].pokemon.data.types.map({ $0.type.name })
            sCell.configure(url: suggestedPokemon[indexPath.row].pokeUrl, color: self.primaryColor!, types: types, sFunc: self.detailVC.showNextVC(pokemon:types:))
        }
        else {
            let tCell = cell as! TypeButtonCell
            //let type = moveTypes[indexPath.row]
            let type = typeDict[typeNames[indexPath.row]]!
            tCell.configure(type: type, isSel: self.selectedTypes.contains(where: { $0.appearance.name == type.appearance.name }), sFunc: self.detailVC.toggleTypeCell(cell:))
            tCell.configureToggle(type: type)
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
        //self.detailVC.showNextVC(pokemon: poke)
    }
    
    @IBAction func showAll(_ sender: Any) {
        self.suggestedPokemon = self.suggestedAll
        
        let allBtn = self.toggleView.subviews[0] as! UIButton
        allBtn.backgroundColor = primaryColor
        allBtn.tintColor = .white
        
        let favBtn = self.toggleView.subviews[1] as! UIButton
        favBtn.backgroundColor = .clear
        favBtn.tintColor = primaryColor
        
        //self.noFavLabel.isHidden = self.suggestedPokemon.count > 0
        self.suggestedCollection.reloadData()
        
        if self.suggestedPokemon.count > 0 {
            self.suggestedCollection.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
        }
    }
    
    @IBAction func showFavorite(_ sender: Any) {
        self.suggestedPokemon = self.suggestedFav
        
        let allBtn = self.toggleView.subviews[0] as! UIButton
        allBtn.backgroundColor = .clear
        allBtn.tintColor = primaryColor
        
        let favBtn = self.toggleView.subviews[1] as! UIButton
        favBtn.backgroundColor = primaryColor
        favBtn.tintColor = .white
        
        //self.noFavLabel.isHidden = self.suggestedPokemon.count > 0
        self.suggestedCollection.reloadData()
        
        if self.suggestedPokemon.count > 0 {
            self.suggestedCollection.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
        }
    }
}
