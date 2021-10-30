//
//  FavoritesViewController.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/27/21.
//

import UIKit

class FavoritesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UIViewControllerTransitioningDelegate {
    
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var filterView: UIView!
    @IBOutlet var shadowView: UIView!
    @IBOutlet var filterViewHeight: NSLayoutConstraint!
    @IBOutlet var toggleOrderView: UIStackView!
    @IBOutlet var attackFilterStack: UIStackView!
    @IBOutlet var defenseFilterStack: UIStackView!
    
    
    struct orderVal {
        var selected: Bool
        var ascending: Bool
        
        init(sel: Bool = false, asc: Bool = true) {
            self.selected = sel
            self.ascending = asc
        }
    }
    
    var dateOrderVal: orderVal = orderVal(sel: true)
    var nameOrderVal: orderVal = orderVal()
    let typeNames: [String] = ["normal", "fire", "water", "grass", "electric", "ice", "fighting", "poison", "ground", "flying", "psychic", "bug", "rock", "ghost", "dark", "dragon", "steel", "fairy"]
    
    var favPokemon: [FavPokemonJson.FavJson] = []
    var filteredResults: [FavPokemonJson.FavJson] = []
    var selectedAtkFilters: [TypeStruct] = []
    var selectedDefFilters: [TypeStruct] = []
    
    let gray = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(self.toggleFilterView(_:)))
        
        let parser = FavoriteJsonParser()
        favPokemon = parser.readJson().favArray.sorted(by: { $0.name < $1.name })
        self.filteredResults.append(contentsOf: self.favPokemon)
        
        
        for view in attackFilterStack.subviews + defenseFilterStack.subviews {
            view.layer.cornerRadius = 12.5
            view.layer.borderColor = gray.cgColor
            view.layer.borderWidth = 1
            view.backgroundColor = gray.withAlphaComponent(0.05)
            
            view.subviews[0].isHidden = false
            view.subviews[1].isHidden = true
        }
        
        
        toggleOrderView.layer.cornerRadius = 15
        toggleOrderView.layer.borderWidth = 1
        toggleOrderView.layer.borderColor = UIColor.link.cgColor
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.2 : 1
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 3)
        shadowView.layer.masksToBounds = false
        
        let btn = toggleOrderView.subviews[1] as! UIButton
        
        if #available(iOS 15.0, *) {
            btn.configuration?.baseBackgroundColor = .clear
            btn.configuration?.baseForegroundColor = .link
            btn.configuration?.image = nil
        } else {
            btn.tintColor = .link
            btn.setTitleColor(.link, for: .normal)
            btn.backgroundColor = .clear
            btn.imageView?.image = nil
        }
        
        filterViewHeight.constant = 0
        filterView.isHidden = true
        filterView.layer.masksToBounds = true
        shadowView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let parser = FavoriteJsonParser()
        favPokemon = parser.readJson().favArray.sorted(by: { $0.name < $1.name })
    }
    
    @objc func toggleFilterView(_ sender:UIBarButtonItem!) {
        if filterViewHeight.constant > 0 {
            filterViewHeight.constant = 0
            filterView.isHidden = true
            shadowView.isHidden = true
        }
        else {
            filterViewHeight.constant = 140
            filterView.isHidden = false
            filterView.backgroundColor = UIColor(named: "ColorHeaderDetailBackground")
            shadowView.isHidden = false
        }
    }
    
    @IBAction func orderByDate(_ sender: Any?) {
        if dateOrderVal.selected {
            dateOrderVal.ascending = !dateOrderVal.ascending
        }
        
        dateOrderVal.selected = true
        nameOrderVal.selected = false
        
        self.highlightButton(btn: self.toggleOrderView.subviews[0] as! UIButton, asc: dateOrderVal.ascending)
        self.unhighlightButton(btn: self.toggleOrderView.subviews[1] as! UIButton)
        
        let parser = FavoriteJsonParser()
        favPokemon = parser.readJson().favArray
        
        if !dateOrderVal.ascending {
            favPokemon = favPokemon.reversed()
        }
        
        self.collectionView.reloadData()
    }
    
    @IBAction func orderByName(_ sender: Any?) {
        if nameOrderVal.selected {
            nameOrderVal.ascending = !nameOrderVal.ascending
        }
        
        nameOrderVal.selected = true
        dateOrderVal.selected = false
        
        self.highlightButton(btn: self.toggleOrderView.subviews[1] as! UIButton, asc: nameOrderVal.ascending)
        self.unhighlightButton(btn: self.toggleOrderView.subviews[0] as! UIButton)
        
        let parser = FavoriteJsonParser()
        favPokemon = parser.readJson().favArray.sorted(by: { $0.name < $1.name })
        
        if !nameOrderVal.ascending {
            favPokemon = favPokemon.reversed()
        }
        
        self.collectionView.reloadData()
    }
    
    @IBAction func attackFilterClicked(_ sender: Any) {
        
        let filterVC = self.storyboard?.instantiateViewController(withIdentifier: "TypeFilterController") as! TypeFilterController
        
        filterVC.titleStr = "Attack Filter"
        filterVC.saveCallback = self.applyAtkFilters(types:)
        filterVC.selectedTypes = self.selectedAtkFilters
        filterVC.modalPresentationStyle = .custom
        filterVC.transitioningDelegate = self
        
        present(filterVC, animated: true, completion: { filterVC.backgroundButton.isHidden = false })
    }
    
    @IBAction func defenseFilterClicked(_ sender: Any) {
        
        let filterVC = self.storyboard?.instantiateViewController(withIdentifier: "TypeFilterController") as! TypeFilterController
        
        filterVC.titleStr = "Defense Filter"
        filterVC.saveCallback = self.applyDefFilters(types:)
        filterVC.selectedTypes = self.selectedDefFilters
        filterVC.modalPresentationStyle = .custom
        filterVC.transitioningDelegate = self
        
        present(filterVC, animated: true, completion: { filterVC.backgroundButton.isHidden = false })
    }
    
    func applyAtkFilters(types: [TypeStruct]) {
        self.selectedAtkFilters = types
        self.applyAllFilters()
    }
    
    func applyDefFilters(types: [TypeStruct]) {
        self.selectedDefFilters = types
        self.applyAllFilters()
    }
    
    func applyAllFilters() {
        
        for view in attackFilterStack.subviews + defenseFilterStack.subviews {
            view.subviews[0].isHidden = false
            view.subviews[1].isHidden = true
            
            view.backgroundColor = gray.withAlphaComponent(0.05)
            view.layer.borderColor = gray.cgColor
        }
        
        if self.selectedAtkFilters.count > 0 {
            for i in 0...self.selectedAtkFilters.count - 1 {
                let type = self.selectedAtkFilters[i].appearance
                
                let filterCell = attackFilterStack.subviews[i]
                filterCell.backgroundColor = type.getColor()
                filterCell.layer.borderColor = type.getColor().cgColor
                
                filterCell.subviews[0].isHidden = true
                filterCell.subviews[1].isHidden = false
                
                let imgView = filterCell.subviews[1].subviews[0] as! UIImageView
                imgView.image = type.getImage().withRenderingMode(.alwaysTemplate)
                
                let label = filterCell.subviews[1].subviews[1] as! UILabel
                label.text = type.name
            }
        }
        
        if self.selectedDefFilters.count > 0 {
            for i in 0...self.selectedDefFilters.count - 1 {
                let type = self.selectedDefFilters[i].appearance
                
                let filterCell = defenseFilterStack.subviews[i]
                filterCell.backgroundColor = type.getColor()
                filterCell.layer.borderColor = type.getColor().cgColor
                
                filterCell.subviews[0].isHidden = true
                filterCell.subviews[1].isHidden = false
                
                let imgView = filterCell.subviews[1].subviews[0] as! UIImageView
                imgView.image = type.getImage().withRenderingMode(.alwaysTemplate)
                
                let label = filterCell.subviews[1].subviews[1] as! UILabel
                label.text = type.name
            }
        }
        
        self.filteredResults.removeAll()
        
        filterLoop: for poke in self.favPokemon {
            for filter in self.selectedAtkFilters {
                if !poke.types.contains(where: { $0 == filter.appearance.name.lowercased() }) {
                    continue filterLoop
                }
            }
            for filter in self.selectedDefFilters {
                if !pokemonDict[poke.name]!.data.types.contains(where: {$0.type.name == filter.appearance.name.lowercased() }) {
                    continue filterLoop
                }
            }
            
            self.filteredResults.append(poke)
        }
        
        self.collectionView.reloadData()
    }
    
    func highlightButton(btn: UIButton, asc: Bool) {
        if #available(iOS 15.0, *) {
            btn.configuration?.baseBackgroundColor = .link
            btn.configuration?.baseForegroundColor = .white
        } else {
            btn.tintColor = .white
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = .link
        }
        
        let img = asc ? UIImage(systemName: "arrow.up") : UIImage(systemName: "arrow.down")
        btn.setImage(img, for: .normal)
    }
    
    func unhighlightButton(btn: UIButton) {
        if #available(iOS 15.0, *) {
            btn.configuration?.baseBackgroundColor = .clear
            btn.configuration?.baseForegroundColor = .link
            btn.configuration?.image = nil
        } else {
            btn.tintColor = .link
            btn.setTitleColor(.link, for: .normal)
            btn.backgroundColor = .clear
            btn.imageView?.image = nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        tryGetUrlArray()
        
        let sNib = UINib(nibName: "MainButtonCell", bundle: nil)
        self.collectionView.register(sNib, forCellWithReuseIdentifier: "MainButtonCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func configure() {
        
        self.favPokemon = FavoriteJsonParser().readJson().favArray
        
        self.emptyView.isHidden = self.favPokemon.count > 0
        
        self.collectionView.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "MainButtonCell", for: indexPath) as! MainButtonCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 70) / 3, height: (collectionView.frame.size.width - 70) / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! MainButtonCell
        let url = pokeUrlArray!.urlArray.first(where: { $0.name == filteredResults[indexPath.row].name })
        cell.configureCellIdentity(pokeUrl: url!, favTypes: filteredResults[indexPath.row].types)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MainButtonCell
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController {
            vc.pokeUrl = cell.pokeUrl
            vc.favTypes = cell.favTypes
            self.show(vc, sender: self)
        }
    }
    
    func tryGetUrlArray() {
        if pokeUrlArray != nil {
            self.configure()
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.tryGetUrlArray()
            })
        }
    }
    
}
