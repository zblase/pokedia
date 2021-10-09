//
//  AddFavoriteViewController.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/27/21.
//

import UIKit

class AddFavoriteViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet var backgroundButton: UIButton!
    @IBOutlet var modalView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var subNameLabel: UILabel!
    @IBOutlet var moveViewA: UIView!
    @IBOutlet var moveViewB: UIView!
    @IBOutlet var moveViewC: UIView!
    @IBOutlet var collectionView: UICollectionView!
    
    var pokemon: Pokemon?
    var selectedTypes: [TypeStruct] = []
    var detailVC: DetailsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalView.layer.masksToBounds = true
        modalView.layer.cornerRadius = 10

        let names = pokemon!.data.name.split(separator: "-")
        nameLabel.text = String(names[0]).capitalizingFirstLetter()
        
        if names.count > 1 {
            subNameLabel.isHidden = false
            
            for i in 1...names.count - 1 {
                subNameLabel.text = "\(String(names[i]).capitalizingFirstLetter()) "
            }
        }
        else {
            subNameLabel.isHidden = true
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
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        backgroundButton.isHidden = true
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
    
    @IBAction func cancelTapped(_ sender: Any?) {
        self.backgroundButton.isHidden = true
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any?) {
        
        var typeArray: [String] = []
        for type in self.selectedTypes {
            typeArray.append(type.appearance.name.lowercased())
        }
        
        //self.navItem!.image = UIImage(systemName: "star.fill")
        detailVC?.setAsFavorite()
        
        FavoriteJsonParser().addFavorite(fav: FavPokemonJson.FavJson(name: pokemon!.data.name, types: typeArray))
        
        self.backgroundButton.isHidden = true
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemon!.moveTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddFavoriteTypeCell.identifier, for: indexPath) as! AddFavoriteTypeCell
        
        let isSel = self.selectedTypes.contains(where: { $0.appearance.name.lowercased() == pokemon!.moveTypes[indexPath.row] })
        cell.configure(typeName: pokemon!.moveTypes[indexPath.row], isSel: isSel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 64) / 6, height: (collectionView.frame.size.width - 64) / 6)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AddFavoriteTypeCell
        
        if !cell.isSel {
            
            if self.selectedTypes.count < 3 {
                self.selectedTypes.append(cell.type!)
            }
            else {
                self.selectedTypes[2] = cell.type!
            }
        }
        else {
            
            self.selectedTypes.removeAll(where: { $0.appearance.name == cell.type!.appearance.name })
        }
        
        refreshSelectedTypes()
    }
}
