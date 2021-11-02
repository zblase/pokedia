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
    var selectFunc: ((TypeButtonCell) -> Void)!
    
    func configure(type: TypeStruct, sFunc: @escaping (TypeButtonCell) -> Void) {
        
        self.type = type
        self.selectFunc = sFunc
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.masksToBounds = false
        
        defView.backgroundColor = UIColor.clear
        defView.layer.borderColor = type.appearance.getColor().cgColor
        defView.layer.borderWidth = 1
        defView.layer.cornerRadius = 10
        
        atkView.backgroundColor = UIColor.clear
        atkView.layer.borderColor = type.appearance.getColor().cgColor
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
        
        let dNib = UINib(nibName: "TypeButtonCell", bundle: nil)
        self.defCollection.register(dNib, forCellWithReuseIdentifier: "TypeButtonCell")
        defCollection.dataSource = self
        defCollection.delegate = self
        
        let aNib = UINib(nibName: "TypeButtonCell", bundle: nil)
        self.atkCollection.register(aNib, forCellWithReuseIdentifier: "TypeButtonCell")
        atkCollection.delegate = self
        atkCollection.dataSource = self
        
        let defRows = ceil(Double(defEffects.count) / 4)
        //print(defRows)
        let cellHeight = 25.0
        
        defHeight.constant = defRows * cellHeight + ((defRows - 1) * 8) + 38
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
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "TypeButtonCell", for: indexPath) as! TypeButtonCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 30) / 4, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let tCell = cell as! TypeButtonCell
        
        if collectionView == self.defCollection {
            let type = typeDict[defEffects[indexPath.row].name]!
            tCell.configure(type: type, isSel: true, sFunc: self.selectFunc)
            let color = self.defEffects[indexPath.row].value > 100 ? UIColor.systemRed : UIColor.systemGreen
            tCell.configureEffect(value: "\(Int(self.defEffects[indexPath.row].value))%", type: type, labelCol: color)
        }
        else {
            let type = typeDict[atkEffects[indexPath.row].name]!
            tCell.configure(type: type, isSel: true, sFunc: self.selectFunc)
            let color = self.atkEffects[indexPath.row].value < 100 ? UIColor.systemRed : UIColor.systemGreen
            tCell.configureEffect(value: "\(Int(self.atkEffects[indexPath.row].value))%", type: type, labelCol: color)
        }
    }
}
