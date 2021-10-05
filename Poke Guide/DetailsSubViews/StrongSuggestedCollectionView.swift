//
//  StrongSuggestedCollectionView.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/13/21.
//

import UIKit

class StrongSuggestedCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
        return currentExamples.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SuggestedCell.identifier, for: indexPath) as! SuggestedCell
        
        cell.configure(pokemon: currentExamples[indexPath.row].pokemon)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.frame.size.width / 6
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.visibleCells[indexPath.row] as! SuggestedCell
        detailVC.showNextVC(pokemon: cell.pokemon!)
    }

}
