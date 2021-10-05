//
//  EffectiveTypeCell.swift
//  Poke Guide
//
//  Created by Zack Blase on 8/17/21.
//

import UIKit

class EffectiveTypeCell: UICollectionViewCell {
    public static var identifier = "EffectiveTypeCell"
    
    @IBOutlet var typeButton: UIButton!
    @IBOutlet var valueLabel: UILabel!
    
    
    var effectVal: Double = 0
    
    
    /// MAximum Count to which label will be Updated
    private var maxCount : Float?
    /// Count which is currently displayed in Label
    private var currentCount : Int = 0
    private var updateTimer : Timer?
    
    public func configure(effect: TypeEffect) {
        let cellType: TypeAppearance = typeDict[effect.name]!.appearance
        let color = cellType.getColor()
        self.effectVal = effect.value
        
        contentView.layer.backgroundColor = color.withAlphaComponent(0.05).cgColor
        contentView.layer.cornerRadius = 12.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = color.withAlphaComponent(0.25).cgColor
        contentView.layer.masksToBounds = true
        
        configureTypeButton(button: typeButton, type: cellType, value: effect.value)
    }
    
    func configureTypeButton(button: UIButton, type: TypeAppearance, value: Double) {
        
        let fSize = type.fontSize != nil ? type.fontSize : 16.0
        let symConfig: UIImage.SymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont(name: "Helvetica Neue", size: CGFloat(fSize!))!)
        
        button.imageView?.tintColor = .white
        button.setImage(type.getImage().withConfiguration(symConfig), for: .normal)
        button.tintColor = type.getColor()
        button.menu = addMenuItem(type)
        button.showsMenuAsPrimaryAction = true
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = type.getInsets()
        
    }
    
    func addMenuItem(_ type: TypeAppearance) -> UIMenu {
        let menuItems = UIMenu(title: "", options: .destructive, children: [
            UIAction(title: type.name, image: type.getImage().withTintColor(.black), handler: { (_) in
                                    
                                })
        ])
        
        return menuItems
    }
    
    func doAnimation() {
        
        DispatchQueue.main.async {
            self.maxCount = Float(self.effectVal)
            self.currentCount = 0
            self.updateTimer = Timer.scheduledTimer(timeInterval: 1 / CGFloat(self.effectVal), target: self, selector: #selector(self.updateLabel), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateLabel() {
        valueLabel?.text = String("\(currentCount)%")
        currentCount += 1
        if Float(currentCount) > maxCount! {
            /// Release All Values
            self.updateTimer?.invalidate()
            self.updateTimer = nil
            self.maxCount = nil
            self.currentCount = 0
        }
    }
}
