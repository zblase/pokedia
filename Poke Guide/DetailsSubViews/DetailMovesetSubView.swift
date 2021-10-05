//
//  DetailMovesetSubView.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/23/21.
//

import UIKit

class DetailMovesetSubView: ToggleViewButton, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var chevron: UIImageView!
    @IBOutlet var viewButton: UIButton!
    @IBOutlet var divider: UIImageView!
    @IBOutlet var subView: UIView!
    @IBOutlet var moveViewA: UIView!
    @IBOutlet var moveViewB: UIView!
    @IBOutlet var moveViewC: UIView!
    @IBOutlet var collectionView: UICollectionView!
    
    var primaryColor: UIColor?
    var secondaryColor: UIColor?
    var moveTypes: [TypeStruct] = []
    var detailVC: DetailsViewController!
    var selectedTypes: [TypeStruct] = []
    
    public func configure(pokemon: Pokemon, detailVC: DetailsViewController) {
        self.isHidden = true
        self.detailVC = detailVC
        primaryColor = pokemon.data.getTypeStruct(slot: 1).appearance.getColor()
        secondaryColor = pokemon.data.types.count > 1 ? pokemon.data.getTypeStruct(slot: 2).appearance.getColor() : primaryColor
        
        configureButton(button: viewButton, color: primaryColor!, chevron: chevron, divider: divider)
        configureSubView(subView: subView, color: secondaryColor!)
        
        for type in pokemon.moveTypes {
            moveTypes.append(typeDict[type]!)
        }
        
        moveViewA.superview?.layer.cornerRadius = 8
        moveViewA.superview?.layer.borderWidth = 1
        moveViewA.superview?.layer.borderColor = UIColor.gray.cgColor
        moveViewB.superview?.layer.cornerRadius = 8
        moveViewB.superview?.layer.borderWidth = 1
        moveViewB.superview?.layer.borderColor = UIColor.gray.cgColor
        moveViewC.superview?.layer.cornerRadius = 8
        moveViewC.superview?.layer.borderWidth = 1
        moveViewC.superview?.layer.borderColor = UIColor.gray.cgColor
        
        let nib = UINib(nibName: "TypeButtonCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "TypeButtonCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        var newFrame = self.frame

        newFrame.size.width = self.frame.width
        newFrame.size.height = 400
        self.frame = newFrame
        
        self.layer.frame.size = CGSize(width: self.layer.frame.size.width, height: self.collectionView.layer.frame.size.height + 20)
    }
    
    func refreshSelectedTypes() {
        moveViewA.isHidden = true
        moveViewA.superview?.layer.borderWidth = 1
        moveViewB.isHidden = true
        moveViewB.superview?.layer.borderWidth = 1
        moveViewC.isHidden = true
        moveViewC.superview?.layer.borderWidth = 1
        
        if self.selectedTypes.count > 0 {
            configureSelectedType(cell: moveViewA, type: self.selectedTypes[0])
        }
        if self.selectedTypes.count > 1 {
            configureSelectedType(cell: moveViewB, type: self.selectedTypes[1])
        }
        if self.selectedTypes.count > 2 {
            configureSelectedType(cell: moveViewC, type: self.selectedTypes[2])
        }
        
        self.collectionView.reloadData()
    }
    
    func configureSelectedType(cell: UIView, type: TypeStruct) {
        cell.layer.cornerRadius = 8
        cell.layer.borderWidth = 1
        cell.layer.borderColor = type.appearance.getColor().cgColor
        cell.layer.backgroundColor = type.appearance.getColor().withAlphaComponent(0.75).cgColor
        
        let icon = cell.subviews[0] as! UIImageView
        let label = cell.subviews[1] as! UILabel
        
        icon.image = type.appearance.getImage().withRenderingMode(.alwaysTemplate)
        label.text = type.appearance.name
        
        cell.superview?.layer.borderWidth = 0
        cell.isHidden = false
    }
    
    @IBAction func clearSelectedType(_ sender: Any?) {
        let btn = sender as! UIButton
        configureUnselectedType(cell: btn.superview!)
    }
    
    func configureUnselectedType(cell: UIView) {
        cell.superview?.layer.borderWidth = 1
        cell.isHidden = true
        
        
        let index = cell.tag
        self.selectedTypes.remove(at: index)
        refreshSelectedTypes()
    }
    
    @IBAction func toggleView(sender: Any?) {
        self.isHidden = !self.isHidden
        
        if self.deg == .pi {
            setOpenButton(button: viewButton, color: primaryColor!, chevron: chevron)
        }
        else {
            setClosedButton(button: viewButton, color: primaryColor!, chevron: chevron)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moveTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TypeButtonCell", for: indexPath) as! TypeButtonCell
        
        if indexPath.row < moveTypes.count {
            let type = moveTypes[indexPath.row]
            cell.configure(type: type, text: type.appearance.name, msView: self)
        }
        
        return cell
    }
    
    func typeCellTapped(type: TypeStruct) {
        self.detailVC.typeCellTapped(type: type)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 30) / 4, height: (collectionView.frame.size.width - 30) / 10)
    }
}
