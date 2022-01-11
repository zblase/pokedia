//
//  TypeDetailCollectionHeader.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/25/21.
//

import UIKit

class TypeDetailCollectionHeader: UIView {
    
    static let identifier = "TypeDetailCollectionHeader"
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var defView: UIView!
    @IBOutlet var atkView: UIView!
    
    var type: TypeStruct?
    
    var defEffects: [TypeEffect] = []
    var atkEffects: [TypeEffect] = []
    var selectFunc: ((TypeCellButton) -> Void)!
    
    func configure(type: TypeStruct, sFunc: @escaping (TypeCellButton) -> Void) {
        
        self.type = type
        self.selectFunc = sFunc
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.masksToBounds = false
        
        defView.backgroundColor = type.appearance.getColor().withAlphaComponent(0.1)
        defView.layer.borderColor = type.appearance.getColor().withAlphaComponent(0.5).cgColor
        defView.layer.borderWidth = 1
        defView.layer.cornerRadius = 12
        
        atkView.backgroundColor = type.appearance.getColor().withAlphaComponent(0.1)
        atkView.layer.borderColor = type.appearance.getColor().withAlphaComponent(0.5).cgColor
        atkView.layer.borderWidth = 1
        atkView.layer.cornerRadius = 12
        
        defView.viewWithTag(5)!.backgroundColor = type.appearance.getColor().withAlphaComponent(0.15)
        atkView.viewWithTag(5)!.backgroundColor = type.appearance.getColor().withAlphaComponent(0.15)
        
        for rel in self.type!.data.damage_relations.no_damage_from {
            defEffects.append(TypeEffect(name: rel.name, value: 0))
        }
        for rel in self.type!.data.damage_relations.half_damage_from {
            defEffects.append(TypeEffect(name: rel.name, value: 50))
        }
        for rel in self.type!.data.damage_relations.double_damage_from {
            defEffects.append(TypeEffect(name: rel.name, value: 200))
        }
        
        formatTypes(stackView: self.viewWithTag(1) as! UIStackView, effects: self.defEffects.filter({ $0.value < 100 }), attack: false)
        formatTypes(stackView: self.viewWithTag(2) as! UIStackView, effects: self.defEffects.filter({ $0.value > 100 }), attack: false)
        
        for rel in self.type!.data.damage_relations.double_damage_to {
            atkEffects.append(TypeEffect(name: rel.name, value: 200))
        }
        for rel in self.type!.data.damage_relations.half_damage_to {
            atkEffects.append(TypeEffect(name: rel.name, value: 50))
        }
        for rel in self.type!.data.damage_relations.no_damage_to {
            atkEffects.append(TypeEffect(name: rel.name, value: 0))
        }
        
        formatTypes(stackView: self.viewWithTag(3) as! UIStackView, effects: self.atkEffects.filter({ $0.value > 100 }), attack: true)
        formatTypes(stackView: self.viewWithTag(4) as! UIStackView, effects: self.atkEffects.filter({ $0.value < 100 }), attack: true)
        
        var viewHeight = max(self.defEffects.filter({ $0.value < 100 }).count / 2, self.defEffects.filter({ $0.value > 100 }).count / 2)
        viewHeight += max(self.atkEffects.filter({ $0.value < 100 }).count / 2, self.atkEffects.filter({ $0.value > 100 }).count / 2)
        
        //return CGFloat(viewHeight + 30)
    }
    
    func formatTypes(stackView: UIStackView, effects: [TypeEffect], attack: Bool) {
        for subView in stackView.subviews {
            subView.subviews[0].isHidden = true
            subView.subviews[1].isHidden = true
            subView.isHidden = true
        }
        
        if effects.count == 0 {
            return
        }
        
        for i in 0...effects.count - 1 {
            let type = typeDict[effects[i].name]!
            let subViewIndex: Int = i / 2
            let typeViewIndex: Int = i % 2
            
            let subView = stackView.subviews[subViewIndex]
            let typeView = subView.subviews[typeViewIndex]
            
            subView.isHidden = false
            typeView.isHidden = false
            
            (typeView.subviews[2] as! TypeCellButton).type = type
            
            typeView.layer.cornerRadius = typeView.frame.size.height / 2
            typeView.layer.borderWidth = 1.5
            typeView.layer.borderColor = type.appearance.getColor().cgColor
            let typeImgView = typeView.subviews[0] as! UIImageView
            typeImgView.image = type.appearance.getImage().withRenderingMode(.alwaysTemplate)
            typeImgView.tintColor = type.appearance.getColor()
            
            let valueLabel = typeView.subviews[1] as! UILabel
            valueLabel.text = "\(Int(effects[i].value))%"
            
            typeView.backgroundColor = valueLabel.tintColor.withAlphaComponent(0.075)
        }
    }
    
    @IBAction func cellTapped(_ sender: Any) {
        let typeButton = sender as! TypeCellButton
        self.selectFunc(typeButton)
    }
}
