//
//  TypeCollectionHeader.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/24/21.
//

import UIKit

class TypeCollectionHeader: UICollectionReusableView {
        static let identifier = "TypeCollectionHeader"
    
    @IBOutlet var wrapperView: UIView!
    @IBOutlet var button: UIButton!
    @IBOutlet var image: UIImageView!
    @IBOutlet var label: UILabel!
    
    func configure() {
        
        wrapperView.layer.cornerRadius = 12.0
        wrapperView.layer.borderWidth = 0.75
        wrapperView.layer.borderColor = UIColor(named: "ColorHomeCellBorder")!.cgColor
        wrapperView.layer.masksToBounds = false
        wrapperView.layer.shadowColor = UIColor.black.cgColor
        wrapperView.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        wrapperView.layer.shadowRadius = 0.85
        wrapperView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.15 : 0.4
        wrapperView.layer.shadowPath = UIBezierPath(roundedRect: wrapperView.bounds, cornerRadius: wrapperView.layer.cornerRadius).cgPath
        
    }
}
