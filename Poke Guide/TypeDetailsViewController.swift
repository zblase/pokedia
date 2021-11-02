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
        
        let sNib = UINib(nibName: "MainButtonCell", bundle: nil)
        self.collectionView.register(sNib, forCellWithReuseIdentifier: "MainButtonCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TypeDetailCollectionHeader.identifier, for: indexPath) as! TypeDetailCollectionHeader
        header.configure(type: type!, sFunc: self.typeCellTapped(cell:))
        return header
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return type!.data.pokemon.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "MainButtonCell", for: indexPath) as! MainButtonCell
        /*let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        if indexPath.row < type!.data.pokemon.count {
            cell.configureCellIdentity(pokeUrl: type!.data.pokemon[indexPath.row].pokemon)
        }
        
        return cell*/
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 70) / 3, height: (collectionView.frame.size.width - 70) / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let pCell = cell as! MainButtonCell
        pCell.configureCellIdentity(pokeUrl: self.type!.data.pokemon[indexPath.row].pokemon)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MainButtonCell
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController {
            vc.pokeUrl = cell.pokeUrl
            self.show(vc, sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        //var height: CGFloat = 76 + (self.view.frame.size.width / 3.5)
        
        let cellHeight = 25.0
        
        let defEffects = type!.data.damage_relations.double_damage_from + type!.data.damage_relations.half_damage_from + type!.data.damage_relations.no_damage_from
        let defRows = ceil(Double(defEffects.count) / 4)
        let defHeight = defRows * cellHeight + ((defRows - 1) * 8) + 38
        
        let atkEffects = type!.data.damage_relations.double_damage_to + type!.data.damage_relations.half_damage_to + type!.data.damage_relations.no_damage_to
        let atkRows = ceil(Double(atkEffects.count) / 4)
        print(atkRows)
        let atkHeight = atkRows * cellHeight + ((atkRows - 1) * 8) + 38
        
        /*if (type!.data.damage_relations.double_damage_from + type!.data.damage_relations.half_damage_from + type!.data.damage_relations.no_damage_from).count > 7 {
            height += (self.view.frame.size.width / 7) - 2
        }
        if (type!.data.damage_relations.double_damage_to + type!.data.damage_relations.half_damage_to + type!.data.damage_relations.no_damage_to).count > 7 {
            height += (self.view.frame.size.width / 7) - 2
        }*/
        
        return CGSize(width: self.collectionView.frame.size.width, height: defHeight + atkHeight + 26)
    }
    
    func typeCellTapped(cell: TypeButtonCell) {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "TypeDetailsViewController") as? TypeDetailsViewController {
            vc.type = cell.type
            self.show(vc, sender: self)
        }
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
