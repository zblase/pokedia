//
//  TypeDetailsViewController.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/25/21.
//

import UIKit

class TypeDetailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    
    @IBOutlet var collectionView: UICollectionView!
    
    
    var type: TypeStruct?
    var headerHeight: CGFloat = 70
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navView = UIView()
        
        let label = UILabel()
        label.text = type!.appearance.name
        label.sizeToFit()
        label.center = navView.center
        label.textAlignment = NSTextAlignment.center
        
        let imgView = UIImageView()
        imgView.image = type!.appearance.getImage().withRenderingMode(.alwaysTemplate)
        imgView.tintColor = type!.appearance.getColor()
        imgView.frame = CGRect(x: label.frame.origin.x-label.frame.size.height - 6, y: label.frame.origin.y, width: label.frame.size.height, height: label.frame.size.height)
        imgView.contentMode = .scaleAspectFit
        
        navView.addSubview(label)
        navView.addSubview(imgView)
        
        self.navigationItem.titleView = navView
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TypeDetailCollectionHeader.identifier, for: indexPath) as! TypeDetailCollectionHeader
        header.configure(type: type!)
        return header
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return type!.data.pokemon.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        if indexPath.row < type!.data.pokemon.count {
            cell.configureCellIdentity(pokeUrl: type!.data.pokemon[indexPath.row].pokemon)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width / 3.5, height: view.frame.size.width / 3.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let width: CGFloat = view.frame.size.width / 3.5
        let spacing = (view.frame.size.width - (width * 3)) / 2
        
        return spacing - 10 
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var height: CGFloat = 76 + (self.view.frame.size.width / 3.5)
        if (type!.data.damage_relations.double_damage_from + type!.data.damage_relations.half_damage_from + type!.data.damage_relations.no_damage_from).count > 7 {
            height += (self.view.frame.size.width / 7) - 2
        }
        if (type!.data.damage_relations.double_damage_to + type!.data.damage_relations.half_damage_to + type!.data.damage_relations.no_damage_to).count > 7 {
            height += (self.view.frame.size.width / 7) - 2
        }
        
        return CGSize(width: self.collectionView.frame.size.width, height: height)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is DetailsViewController {
            let vc = segue.destination as? DetailsViewController
            let pButton = sender as! PokemonButton
            vc?.pokemon = pButton.pokemon
        }
    }
}
