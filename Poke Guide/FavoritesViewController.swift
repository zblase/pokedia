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
    
    //var favUrlArray: [PokemonArrayResult.PokemonUrl] = []
    var favPokemon: [FavPokemonJson.FavJson] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
