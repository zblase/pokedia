//
//  TypeButtonCell.swift
//  Poke Guide
//
//  Created by Zack Blase on 10/4/21.
//

import UIKit

class TypeButtonCell: UICollectionViewCell {

    @IBOutlet var typeIcon: UIImageView!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var cellButton: UIButton!
    
    var type: TypeStruct!
    var isToggle: Bool = false
    var isSel: Bool = false
    var selectFunc: ((TypeButtonCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(type: TypeStruct, isSel: Bool, sFunc: ((TypeButtonCell) -> Void)?) {
        self.type = type
        self.isSel = isSel
        self.selectFunc = sFunc
        
        contentView.layer.masksToBounds = true
        contentView.contentMode = .scaleAspectFit
        typeIcon.image = type.appearance.getImage().withRenderingMode(.alwaysTemplate)
        typeIcon.contentMode = .scaleAspectFit
        
        //cellButton.backgroundColor = type.appearance.getColor().withAlphaComponent(isSel ? 1.0 : 0.2)
        cellButton.layer.cornerRadius = 8
        cellButton.layer.borderWidth = 1
        
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        self.layer.shadowRadius = 0.75
        self.layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.2 : 0.4
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        
    }
    
    func configureToggle(type: TypeStruct) {
        self.isToggle = true
        
        typeLabel.adjustsFontSizeToFitWidth = true
        typeLabel.text = type.appearance.name
        typeLabel.textColor = isSel ? typeLabel.textColor.withAlphaComponent(1) : typeLabel.textColor.withAlphaComponent(0.5)
        typeIcon.tintColor = isSel ? typeIcon.tintColor.withAlphaComponent(1) : typeIcon.tintColor.withAlphaComponent(0.5)
        
        cellButton.backgroundColor = type.appearance.getColor().withAlphaComponent(isSel ? 1.0 : 0.2)
        cellButton.layer.borderColor = UIColor(named: "ColorButtonBorder")!.cgColor
    }
    
    func configureEffect(value: String, type: TypeStruct, labelCol: UIColor = .white) {
        typeLabel.text = value
        typeLabel.textColor = labelCol
        typeLabel.shadowColor = .black.withAlphaComponent(0.25)
        typeLabel.shadowOffset = CGSize(width: 0.5, height: 0.5)
        typeLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        cellButton.backgroundColor = type.appearance.getColor().withAlphaComponent(0.15)
        cellButton.layer.borderColor = type.appearance.getColor().cgColor
        cellButton.layer.borderWidth = 1.5
        
        typeIcon.tintColor = type.appearance.getColor()
    }
    
    @IBAction func typeClicked(_ sender: Any?) {
        if self.selectFunc != nil {
            self.selectFunc!(self)
        }
    }
}
