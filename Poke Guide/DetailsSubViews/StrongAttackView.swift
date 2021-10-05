//
//  StrongAttackView.swift
//  Poke Guide
//
//  Created by Zack Blase on 8/12/21.
//

import UIKit

class StrongAttackView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var suggestedCollection: StrongSuggestedCollectionView!
    
    var pokemon: Pokemon?
    var strongEffects: [TypeEffect] = []
    var weakAttack: [Move] = []
    var strongDefense: [Move] = []
    var weakDefense: [Move] = []
    
    public func configure(pokemon: Pokemon, defenseEffects: [TypeEffect]) {
        //self.isHidden = true
        self.pokemon = pokemon
        
        strongEffects = defenseEffects
        
        self.dataSource = self
        self.delegate = self
    }
    
    func animateCells() {
        for vCell in self.visibleCells {
            let cell = vCell as! EffectiveTypeCell
            cell.doAnimation()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return strongEffects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EffectiveTypeCell.identifier, for: indexPath) as! EffectiveTypeCell
        
        cell.configure(effect: strongEffects[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let width = (self.frame.size.width - CGFloat(Double(strongEffects.count) * 7)) / 6
        //return CGSize(width: self.frame.size.width / 6.0, height: (self.frame.size.width / 6.0) / 2.5)
        return CGSize(width: self.frame.size.height, height: self.frame.size.height)
    }

}
