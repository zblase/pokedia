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
    
    var favPokemon: [Pokemon] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFavTapped))
        
        /*let favArray = FavoriteJsonParser().readJson()
        
        for poke in favArray.favArray {
            self.favPokemon.append(pokemonDict[poke.name]!)
        }
        
        if self.favPokemon.count > 0 {
            self.emptyView.isHidden = true
        }*/
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let favArray = FavoriteJsonParser().readJson()
        
        self.favPokemon.removeAll()
        
        for poke in favArray.favArray {
            self.favPokemon.append(pokemonDict[poke.name]!)
        }
        
        if self.favPokemon.count > 0 {
            self.emptyView.isHidden = true
        }
        
        self.collectionView.reloadData()
    }
    
        
    @objc func addFavTapped() {
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favPokemon.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        if indexPath.row < favPokemon.count {
            cell.configureCellIdentity(pokeUrl: pokeUrlArray!.urlArray.first(where: { $0.name == favPokemon[indexPath.row].data.name})!)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width / 3.5, height: view.frame.size.width / 3.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let width: CGFloat = view.frame.size.width / 3.5
        let spacing = (view.frame.size.width - (width * 3)) / 2
        
        return spacing - 10
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is DetailsViewController {
            let vc = segue.destination as? DetailsViewController
            let pButton = sender as! PokemonButton
            vc?.pokemon = pButton.pokemon
        }
    }

}
