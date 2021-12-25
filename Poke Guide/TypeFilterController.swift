//
//  TypeFilterController.swift
//  Poke Guide
//
//  Created by Zack Blase on 10/27/21.
//

import UIKit

class TypeFilterController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var backgroundButton: UIButton!
    @IBOutlet var modalView: UIView!
    @IBOutlet var navTitle: UINavigationItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var mainLabel: UILabel!
    @IBOutlet var subLabel: UILabel!
    @IBOutlet var selectedTypeView: UIStackView!
    @IBOutlet var collectionView: UICollectionView!
    
    var titleStr: String = ""
    var labelStr: String = "Selected types:"
    var selectedTypes: [TypeStruct]!
    var cellCount = 3
    var saveWithNone: Bool = true
    var saveCallback: (([TypeStruct]) -> Void)!
    
    
    let typeNames: [String] = ["normal", "fire", "water", "grass", "electric", "ice", "fighting", "poison", "ground", "flying", "psychic", "bug", "rock", "ghost", "dark", "dragon", "steel", "fairy"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(UIDevice.current.name)
        modalView.layer.cornerRadius = 15
        /*switch UIDevice.current.name {
        case "iPhone 13":
            modalView.layer.cornerRadius = 20
        case "iPhone 13 Pro":
            modalView.layer.cornerRadius = 20
        case "iPhone 13 Pro Max":
            modalView.layer.cornerRadius = 20
        case "iPhone 13 mini":
            modalView.layer.cornerRadius = 20
        case "iPhone 12":
            modalView.layer.cornerRadius = 20
        case "iPhone 12 Pro":
            modalView.layer.cornerRadius = 44
        case "iPhone 12 Pro Max":
            modalView.layer.cornerRadius = 20
        case "iPhone 12 mini":
            modalView.layer.cornerRadius = 20
        case "iPhone 11":
            modalView.layer.cornerRadius = 20
        case "iPhone 11 Pro":
            modalView.layer.cornerRadius = 20
        case "iPhone 11 Pro Max":
            modalView.layer.cornerRadius = 20
        case "iPhone SE":
            modalView.layer.cornerRadius = 20
        case "iPhone X":
            modalView.layer.cornerRadius = 20
        case "iPhone Xs":
            modalView.layer.cornerRadius = 20
        case "iPhone Xs Max":
            modalView.layer.cornerRadius = 20
        case "iPhone Xr":
            modalView.layer.cornerRadius = 20
        case "iPhone 8":
            modalView.layer.cornerRadius = 20
        case "iPhone 8 Plus":
            modalView.layer.cornerRadius = 20
        default:
            modalView.layer.cornerRadius = 14
        }*/
        //modalView.layer.cornerRadius = 12.5
        modalView.layer.masksToBounds = true
        
        self.navTitle.title = titleStr
        
        self.mainLabel.text = labelStr
        let countStr = cellCount == 2 ? "two" : "three"
        self.subLabel.text = "Select up to \(countStr) types"
        
        for i in 0...self.selectedTypeView.subviews.count - 1 {
            self.selectedTypeView.subviews[i].isHidden = i >= cellCount
        }
        
        for view in self.selectedTypeView.subviews {
            view.layer.cornerRadius = 12.5
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.75).cgColor
            view.backgroundColor = .clear
            view.subviews[0].isHidden = true
            view.subviews[1].isHidden = true
            view.subviews[2].isHidden = true
        }
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        refreshSelectedTypes()
    }
    
    
    
    @IBAction func clearSelectedType(_ sender: Any?) {
        let btn = sender as! UIButton
        let cell = btn.superview!
        cell.backgroundColor = .clear
        cell.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.75).cgColor
        
        let index = cell.tag
        self.selectedTypes.remove(at: index)
        refreshSelectedTypes()
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        self.saveCallback(self.selectedTypes)
        
        self.backgroundButton.isHidden = true
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.backgroundButton.isHidden = true
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let type = typeDict[typeNames[indexPath.row]]!
        cell.tag = indexPath.row
        cell.contentView.layer.cornerRadius = 12.5
        cell.contentView.layer.borderColor = type.appearance.getColor().cgColor
        cell.contentView.layer.borderWidth = 1
        cell.layer.masksToBounds = true
        
        let img = cell.contentView.subviews[0] as! UIImageView
        img.image = type.appearance.getImage().withRenderingMode(.alwaysTemplate)
        
        let name = cell.contentView.subviews[1] as! UILabel
        name.text = type.appearance.name
        
        if selectedTypes.contains(where: { $0.appearance.name == type.appearance.name }) {
            cell.contentView.backgroundColor = type.appearance.getColor()
            img.tintColor = .white
            name.textColor = .white
        }
        else {
            cell.contentView.backgroundColor = .clear
            img.tintColor = type.appearance.getColor()
            name.textColor = type.appearance.getColor()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 30) / 4, height: 25)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = self.collectionView.viewWithTag(indexPath.row) as! UICollectionViewCell
        let type = typeDict[typeNames[indexPath.row]]!
        if self.selectedTypes.contains(where: { $0.appearance.name == type.appearance.name }) {
            self.selectedTypes.removeAll(where: { $0.appearance.name == type.appearance.name })
            
            cell.contentView.backgroundColor = .clear
            let img = cell.contentView.subviews[0] as! UIImageView
            img.tintColor = type.appearance.getColor()
            
            let name = cell.contentView.subviews[1] as! UILabel
            name.textColor = type.appearance.getColor()
        }
        else {
            if self.selectedTypes.count == cellCount {
                self.selectedTypes[cellCount - 1] = type
            }
            else {
                self.selectedTypes.append(type)
            }
            
            cell.contentView.backgroundColor = type.appearance.getColor()
            let img = cell.contentView.subviews[0] as! UIImageView
            img.tintColor = .white
            
            let name = cell.contentView.subviews[1] as! UILabel
            name.textColor = .white
        }
        
        refreshSelectedTypes()
    }
    
    func refreshSelectedTypes() {
        
        for view in self.selectedTypeView.subviews {
            view.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.75).cgColor
            view.backgroundColor = .clear
            view.subviews[0].isHidden = true
            view.subviews[1].isHidden = true
            view.subviews[2].isHidden = true
        }
        
        if self.selectedTypes.count > 0 {
            configureSelectedType(cell: self.selectedTypeView.subviews[0], type: self.selectedTypes[0])
        }
        if self.selectedTypes.count > 1 {
            configureSelectedType(cell: self.selectedTypeView.subviews[1], type: self.selectedTypes[1])
        }
        if self.selectedTypes.count > 2 {
            configureSelectedType(cell: self.selectedTypeView.subviews[2], type: self.selectedTypes[2])
        }
        
        for cell in self.collectionView.visibleCells {
            let type = typeDict[typeNames[cell.tag]]!
            let iconView = cell.contentView.subviews[0] as! UIImageView
            let nameLabel = cell.contentView.subviews[1] as! UILabel
            
            if self.selectedTypes.contains(where: { $0.appearance.name.lowercased() == typeNames[cell.tag]}) {
                cell.contentView.backgroundColor = type.appearance.getColor()
                iconView.tintColor = .white
                nameLabel.textColor = .white
            }
            else {
                cell.contentView.backgroundColor = .clear
                iconView.tintColor = type.appearance.getColor()
                nameLabel.textColor = type.appearance.getColor()
            }
        }
        
        if !self.saveWithNone {
            self.saveButton.isEnabled = self.selectedTypes.count > 0
        }
    }
    
    func configureSelectedType(cell: UIView, type: TypeStruct) {
        cell.layer.borderColor = type.appearance.getColor().cgColor
        cell.backgroundColor = type.appearance.getColor()
        let iconView = cell.subviews[0] as! UIImageView
        iconView.image = type.appearance.getImage()
        iconView.isHidden = false
        let nameLabel = cell.subviews[1] as! UILabel
        nameLabel.text = type.appearance.name
        nameLabel.isHidden = false
        cell.subviews[2].isHidden = false
    }
}
