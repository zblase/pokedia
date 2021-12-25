//
//  WeakSuggestedCollectionView.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/17/21.
//

import UIKit

class WeakSuggestedCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var detailVC: DetailsViewController!
    
    var allPokemon: [PokemonEffectScore] = []
    var favPokemon: [PokemonEffectScore] = []
    var currentExamples: [PokemonEffectScore] = []
    
    public func configure(pokemon: [PokemonEffectScore], favPokemon: [PokemonEffectScore]) {
        self.allPokemon = pokemon
        self.currentExamples = pokemon
        self.favPokemon = favPokemon
        
        self.dataSource = self
        self.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(currentExamples.count, 6)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeakSuggestedCell.identifier, for: indexPath) as! WeakSuggestedCell
        
        cell.configure(url: currentExamples[indexPath.row].pokeUrl)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.frame.size.width / 6
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.visibleCells[indexPath.row] as! WeakSuggestedCell
        detailVC.showNextVC(pokemon: cell.pokeUrl)
    }
}
