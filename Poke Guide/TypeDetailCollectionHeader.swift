//
//  TypeDetailCollectionHeader.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/25/21.
//

import UIKit

class TypeDetailCollectionHeader: UICollectionReusableView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    static let identifier = "TypeDetailCollectionHeader"
    
    @IBOutlet var defView: UIView!
    @IBOutlet var atkView: UIView!
    @IBOutlet var defCollection: UICollectionView!
    @IBOutlet var atkCollection: UICollectionView!
    //@IBConstraint var test: NSLayoutConstraint!
    @IBOutlet var defHeight: NSLayoutConstraint!
    
    var type: TypeStruct?
    
    var defEffects: [TypeEffect] = []
    var atkEffects: [TypeEffect] = []
    
    func configure(type: TypeStruct) {
        
        self.type = type
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.masksToBounds = false
        
        defView.layer.backgroundColor = type.appearance.getColor().withAlphaComponent(0.05).cgColor
        defView.layer.borderColor = type.appearance.getColor().withAlphaComponent(0.2).cgColor
        defView.layer.borderWidth = 1
        defView.layer.cornerRadius = 10
        
        atkView.layer.backgroundColor = type.appearance.getColor().withAlphaComponent(0.05).cgColor
        atkView.layer.borderColor = type.appearance.getColor().withAlphaComponent(0.2).cgColor
        atkView.layer.borderWidth = 1
        atkView.layer.cornerRadius = 10
        
        for rel in self.type!.data.damage_relations.no_damage_from {
            defEffects.append(TypeEffect(name: rel.name, value: 0))
        }
        for rel in self.type!.data.damage_relations.half_damage_from {
            defEffects.append(TypeEffect(name: rel.name, value: 50))
        }
        for rel in self.type!.data.damage_relations.double_damage_from {
            defEffects.append(TypeEffect(name: rel.name, value: 200))
        }
        
        for rel in self.type!.data.damage_relations.double_damage_to {
            atkEffects.append(TypeEffect(name: rel.name, value: 200))
        }
        for rel in self.type!.data.damage_relations.half_damage_to {
            atkEffects.append(TypeEffect(name: rel.name, value: 50))
        }
        for rel in self.type!.data.damage_relations.no_damage_to {
            atkEffects.append(TypeEffect(name: rel.name, value: 0))
        }
        
        defCollection.dataSource = self
        defCollection.delegate = self
        atkCollection.delegate = self
        atkCollection.dataSource = self
        
        print("\(UIScreen.main.bounds.width)")
        if defEffects.count < 8 {
            defHeight.constant = (UIScreen.main.bounds.width / 7) + 26
            //defHeight.constant = 83
        }
        else {
            defHeight.constant = (UIScreen.main.bounds.width / 3.5) + 22
            //defHeight.constant = 132
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.defCollection {
            return self.defEffects.count
        }
        else {
            return self.atkEffects.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //return collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath)
        if collectionView == self.defCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypeEffectCellDefense.identifier, for: indexPath) as! TypeEffectCellDefense
            
            cell.configure(effect: self.defEffects[indexPath.row])
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypeEffectCellAttack.identifier, for: indexPath) as! TypeEffectCellAttack
            
            cell.configure(effect: self.atkEffects[indexPath.row])
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size: CGFloat = 0
        
        if collectionView == self.defCollection {
            size = self.defCollection.frame.size.width / 7
        }
        else {
            size = self.atkCollection.frame.size.width / 7
        }
        
        return CGSize(width: size, height: size)
    }
}
