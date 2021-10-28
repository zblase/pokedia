//
//  FavoritesViewController.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/27/21.
//

import UIKit

class FavoritesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var filterView: UIView!
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
    
    //var favUrlArray: [PokemonArrayResult.PokemonUrl] = []
    var favPokemon: [FavPokemonJson.FavJson] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(self.toggleFilterView(_:)))
        
        
        let gray = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.75)
        
        let filterCells = attackFilterStack.subviews + defenseFilterStack.subviews
        for view in filterCells {
            let btn = view as! UIButton
            btn.layer.cornerRadius = 12.5
            btn.layer.borderWidth = 1
            btn.layer.borderColor = gray.cgColor
            btn.tintColor = gray
            btn.setTitle("", for: .normal)
            btn.setAttributedTitle(nil, for: .normal)
            btn.setTitleColor(gray, for: .normal)
            btn.backgroundColor = gray.withAlphaComponent(0.1)
        }
        
        
        toggleOrderView.layer.cornerRadius = 15
        toggleOrderView.layer.borderWidth = 1
        toggleOrderView.layer.borderColor = UIColor.link.cgColor
        filterView.layer.shadowColor = UIColor.black.cgColor
        filterView.layer.shadowRadius = 3.0
        //filterView.layer.shadowOpacity = 0.2
        filterView.layer.shadowOpacity = 1
        filterView.layer.shadowOffset = CGSize(width: 0, height: 3)
        filterView.layer.masksToBounds = false
        //filterView.layer.masksToBounds = true
        
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
        
    }
    
    @objc func toggleFilterView(_ sender:UIBarButtonItem!) {
        if filterViewHeight.constant > 0 {
            filterViewHeight.constant = 0
            filterView.layer.shadowOffset = CGSize(width: 0, height: 0)
            filterView.isHidden = true
        }
        else {
            filterViewHeight.constant = 140
            filterView.layer.shadowOffset = CGSize(width: 0, height: 3)
            filterView.isHidden = false
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
    
    @objc func attackTypeTapped(_ sender: Any) {
        let btn = sender as! UIButton
        let type = typeDict[btn.accessibilityIdentifier!]!
        btn.backgroundColor = btn.backgroundColor == type.appearance.getColor() ? .clear : type.appearance.getColor()
        btn.tintColor = btn.tintColor == .white ? type.appearance.getColor() : .white
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
        return favPokemon.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "MainButtonCell", for: indexPath) as! MainButtonCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 70) / 3, height: (collectionView.frame.size.width - 70) / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! MainButtonCell
        let url = pokeUrlArray!.urlArray.first(where: { $0.name == favPokemon[indexPath.row].name })
        cell.configureCellIdentity(pokeUrl: url!, favTypes: favPokemon[indexPath.row].types)
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
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
     return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
     }
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
     let width: CGFloat = view.frame.size.width / 3.5
     let spacing = (view.frame.size.width - (width * 3)) / 2
     
     return spacing - 10
     }*/
    
    /*func showNextVC(pokemon: Pokemon) {
     if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController {
     //vc.pokemon = pokemon
     vc.pokeUrl = pokeUrlArray?.urlArray.first(where: { $0.name == pokemon.data.name })
     self.show(vc, sender: self)
     }
     }*/
    
}
