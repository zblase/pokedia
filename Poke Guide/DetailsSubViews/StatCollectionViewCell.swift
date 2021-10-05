//
//  StatCollectionViewCell.swift
//  Poke Guide
//
//  Created by Zack Blase on 8/11/21.
//

import UIKit

class StatCollectionViewCell: UICollectionViewCell {
    static let identifier = "StatCollectionViewCell"
    
    @IBOutlet var statName: UILabel!
    @IBOutlet var statValue: UILabel!
    @IBOutlet var statMax: UILabel!
    
    let shape = CAShapeLayer()
    let maxDeg: CGFloat = .pi * 1.5
    var deg: CGFloat = .pi
    
    var centerPoint: CGPoint?
    /// MAximum Count to which label will be Updated
    private var maxCount : Int?
    /// Count which is currently displayed in Label
    private var currentCount : Int? = 0
    private var updateTimer : Timer?
    
    var statVal: Int = 0
    
    public func configure(stat: PokemonData.StatValue, color: UIColor) {
        
        self.statVal = stat.base_stat
        var maxValue: CGFloat = 0
        
        if stat.stat.name == "hp" {
            maxValue = CGFloat(stat.base_stat) * 2 + 204
        }
        else {
            maxValue = (CGFloat(stat.base_stat) * 2 + 99) * 1.1
        }
        
        for layer in contentView.layer.sublayers! {
            
            if let shp = layer as? CAShapeLayer {
                let index = contentView.layer.sublayers?.firstIndex(of: shp)
                contentView.layer.sublayers?.remove(at: index!)
            }
        }
        
        switch stat.stat.name {
        case "hp":
            statName.text = "HP"
        case "special-attack":
            statName.text = "Sp Attack"
        case "special-defense":
            statName.text = "Sp Defense"
        default:
            statName.text = stat.stat.name.capitalizingFirstLetter()
        }
        
        statMax.text = "Max: \(Int(floor(maxValue)))"
        
        maxCount = Int(CGFloat(statVal).rounded())
        let factor: CGFloat = CGFloat(statVal) / maxValue
        var amount = ((.pi / 3.1) + (.pi * 1.5)) * factor
        amount = (-(.pi / 3.1)) + amount
        
        let center: CGPoint = statValue.center
        
        let circlePath = UIBezierPath(arcCenter: center,
                                      radius: 30,
                                      startAngle: -(.pi / 3.1),
                                      endAngle: amount,
                                      clockwise: true)
        
        let backgroundPath = UIBezierPath(arcCenter: center,
                                      radius: 30,
                                      startAngle: -(.pi / 3.1),
                                      endAngle: .pi * 1.5,
                                      clockwise: true)
        let backgroundShape = CAShapeLayer()
        backgroundShape.path = backgroundPath.cgPath
        backgroundShape.lineWidth = 9
        backgroundShape.lineCap = .round
        backgroundShape.strokeColor = color.withAlphaComponent(0.2).cgColor
        backgroundShape.fillColor = UIColor.clear.cgColor
        backgroundShape.strokeEnd = 0.9
        contentView.layer.addSublayer(backgroundShape)
        
        shape.path = circlePath.cgPath
        shape.lineWidth = 9
        shape.lineCap = .round
        shape.strokeColor = color.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeEnd = 0.1
        contentView.layer.addSublayer(shape)
    }
    
    public func doAnimation() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 0.9
        animation.duration = 1
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        shape.add(animation, forKey: "animation")
        
        DispatchQueue.main.async {
            self.currentCount = 0
            self.updateTimer = Timer.scheduledTimer(timeInterval: 1 / CGFloat(self.statVal), target: self, selector: #selector(self.updateLabel), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateLabel() {
        if currentCount != nil {
            statValue?.text = String(currentCount!)
            currentCount! += 1
            if currentCount! > maxCount! {
                /// Release All Values
                self.updateTimer?.invalidate()
                self.updateTimer = nil
                self.maxCount = nil
                self.currentCount = nil
            }
        }
    }
    
    
    
}
