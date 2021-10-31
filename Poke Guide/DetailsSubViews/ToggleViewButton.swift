//
//  ToggleViewButton.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/15/21.
//

import UIKit

class ToggleViewButton: UIView {

    var deg: CGFloat = .pi

    
    public func configureButton(button: UIButton, color: UIColor, chevron: UIImageView, divider: UIImageView) {
        button.layer.cornerRadius = 17.5
        button.layer.borderWidth = 0
        //chevron.tintColor = color.withAlphaComponent(0.5)
        //chevron.tintColor = UIColor(named: "ColorLabelPrimary")
        divider.backgroundColor = color.withAlphaComponent(0.5)
        
        unhighlightButton(button: button, color: color)
    }
    
    public func configureSubView(subView: UIView, color: UIColor) {
        
        subView.backgroundColor = color.withAlphaComponent(0.1)
        subView.layer.borderWidth = 1
        //subView.layer.borderColor = color.withAlphaComponent(0.35).cgColor
        subView.layer.borderColor = color.cgColor
        subView.layer.cornerRadius = 10
        subView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    public func setClosedButton(button: UIButton, color: UIColor, chevron: UIImageView) {
        
        rotateChevron(chevron: chevron)
        
        self.deg = .pi
        
        unhighlightButton(button: button, color: color)
    }
    
    public func setOpenButton(button: UIButton, color: UIColor, chevron: UIImageView) {
        
        rotateChevron(chevron: chevron)
        
        self.deg = 0
        
        highlightButton(button: button, color: color)
    }
    
    func highlightButton(button: UIButton, color: UIColor) {
        //button.backgroundColor = .tertiarySystemBackground
        button.backgroundColor = color
        //button.layer.borderColor = UIColor(named: "ColorHomeCellBorder")!.cgColor
        button.layer.borderColor = color.cgColor
        button.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    func unhighlightButton(button: UIButton, color: UIColor) {
        button.backgroundColor = color.withAlphaComponent(0.75)
        //button.backgroundColor = .tertiarySystemBackground
        button.layer.borderColor = color.withAlphaComponent(0.5).cgColor
        //button.layer.borderColor = UIColor(named: "ColorHomeCellBorder")!.cgColor
        button.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    func rotateChevron(chevron: UIImageView) {
        UIView.animate(withDuration: 0.1, animations: {
            chevron.transform = CGAffineTransform(rotationAngle: self.deg)
        })
    }
}
