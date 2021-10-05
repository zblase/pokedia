//
//  TypesViewController.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/24/21.
//

import UIKit

class TypesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypeCollectionCell.identifier, for: indexPath) as! TypeCollectionCell
        
        cell.configureCell(appearance: self.typeAppearanceDict[typeNames[indexPath.row]]!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.size.width / 2) - 17.5, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TypeCollectionHeader.identifier, for: indexPath) as! TypeCollectionHeader
        header.configure()
        return header
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is TypeDetailsViewController {
            let vc = segue.destination as? TypeDetailsViewController
            let tButton = sender as! TypeCellButton
            vc?.type = tButton.type
        }
    }

}
