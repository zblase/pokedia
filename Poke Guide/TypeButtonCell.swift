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
        contentView.layer.cornerRadius = 12.5
        contentView.layer.borderWidth = 1
        contentView.backgroundColor = .clear
        //self.backgroundColor = .clear
        //cellButton.backgroundColor = .clear
        //cellButton.isHidden = true
        
        /*self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        self.layer.shadowRadius = 0.75
        self.layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.2 : 0.4
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath*/
        
    }
    
    func configureToggle(type: TypeStruct) {
        self.isToggle = true
        
        typeLabel.text = type.appearance.name
        typeLabel.textColor = isSel ? .white : type.appearance.getColor()
        typeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        typeIcon.tintColor = isSel ? .white : type.appearance.getColor()
        
        contentView.backgroundColor = type.appearance.getColor().withAlphaComponent(isSel ? 1.0 : 0)
        contentView.layer.borderColor = type.appearance.getColor().cgColor
    }
    
    func configureEffect(value: String, type: TypeStruct, labelCol: UIColor = .white) {
        
        typeLabel.text = value
        typeLabel.textColor = labelCol
        typeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        
        contentView.backgroundColor = labelCol.withAlphaComponent(0.08)
        contentView.layer.borderColor = type.appearance.getColor().cgColor
        contentView.layer.borderWidth = 1.5
        
        typeIcon.tintColor = type.appearance.getColor()
    }
    
    @IBAction func typeClicked(_ sender: Any?) {
        if self.selectFunc != nil {
            self.selectFunc!(self)
        }
    }
}
