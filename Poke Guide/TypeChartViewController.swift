//
//  TypeChartViewController.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/27/21.
//

import UIKit

class TypeChartViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    
    let typeNames: [String] = ["normal", "fire", "water", "grass", "electric", "ice", "fighting", "poison", "ground", "flying", "psychic", "bug", "rock", "ghost", "dark", "dragon", "steel", "fairy"]
    var typeAppearanceDict: [String: TypeAppearance] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        let typeController = TypeDataController()
        self.typeAppearanceDict = typeController.parseTypeAppearances()!
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 19 * 19
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chartCell", for: indexPath)
        
        if indexPath.row > 0 {
            if indexPath.row < 19 {
                configureTypeCell(cell: cell, type: typeDict[typeNames[indexPath.row - 1]]!.appearance)
            }
            else if indexPath.row % 19 == 0 {
                configureTypeCell(cell: cell, type: typeDict[typeNames[(indexPath.row / 19) - 1]]!.appearance)
            }
            else {
                configureEffectCell(cell: cell, row: indexPath.row / 19, column: indexPath.row % 19)
            }
        }
        
        //cell.contentView.frame = CGRect(x: 0.5, y: 0.5, width: cell.layer.bounds.width - 1, height: cell.layer.bounds.height - 1)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width / 19), height: (collectionView.frame.size.width / 19))
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "chartHeader", for: indexPath)
    }
    
    
    func configureTypeCell(cell: UICollectionViewCell, type: TypeAppearance) {
        let img = UIImageView()
        cell.addSubview(img)
        
        let imgFrame: CGRect = CGRect(x: 4, y: 4, width: cell.layer.bounds.width - 8, height: cell.layer.bounds.height - 8)
        img.frame = imgFrame
        
        let fSize = type.fontSize != nil ? type.fontSize : 16.0
        let symConfig: UIImage.SymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont(name: "Helvetica Neue", size: CGFloat(fSize!))!)
        
        img.tintColor = type.getColor()
        img.image = type.getImage().withConfiguration(symConfig).withRenderingMode(.alwaysTemplate)
        img.contentMode = .scaleAspectFit
    }
    
    func configureEffectCell(cell: UICollectionViewCell, row: Int, column: Int) {
        
        let atkType = typeNames[row - 1]
        let defType = typeNames[column - 1]
        
        
        if typeDict[atkType]!.data.damage_relations.no_damage_to.contains(where: { $0.name == defType }) {
            cell.backgroundColor = .systemGray
        }
        else if typeDict[atkType]!.data.damage_relations.half_damage_to.contains(where: { $0.name == defType }) {
            cell.backgroundColor = .systemRed.withAlphaComponent(0.75)
        }
        else if typeDict[atkType]!.data.damage_relations.double_damage_to.contains(where: { $0.name == defType }) {
            cell.backgroundColor = .systemGreen.withAlphaComponent(0.75)
        }
        else {
            cell.backgroundColor = .clear
        }
    }

}
