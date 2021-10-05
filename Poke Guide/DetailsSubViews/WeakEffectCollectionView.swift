//
//  WeakEffectCollectionView.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/17/21.
//

import UIKit

class WeakEffectCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var suggestedCollection: WeakSuggestedCollectionView!
    
    var pokemon: Pokemon?
    var weakEffects: [TypeEffect] = []
    
    public func configure(pokemon: Pokemon, effects: [TypeEffect]) {
        
        self.pokemon = pokemon
        
        weakEffects = effects
        
        self.dataSource = self
        self.delegate = self
    }
    
    func animateCells() {
        for vCell in self.visibleCells {
            let cell = vCell as! WeakEffectCell
            cell.doAnimation()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return weakEffects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeakEffectCell.identifier, for: indexPath) as! WeakEffectCell
        
        cell.configure(effect: weakEffects[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.size.height, height: self.frame.size.height)
    }
}
