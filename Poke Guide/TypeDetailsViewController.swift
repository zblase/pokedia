//
//  TypeDetailsViewController.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/25/21.
//

import UIKit

class TypeDetailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var defView: UIView!
    @IBOutlet var atkView: UIView!
    
    var type: TypeStruct?
    
    var defEffects: [TypeEffect] = []
    var atkEffects: [TypeEffect] = []
    
    var headerHeight: Int = 90
    
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
        
        for rel in self.type!.data.damage_relations.no_damage_from {
            defEffects.append(TypeEffect(name: rel.name, value: 0))
        }
        for rel in self.type!.data.damage_relations.half_damage_from {
            defEffects.append(TypeEffect(name: rel.name, value: 50))
        }
        for rel in self.type!.data.damage_relations.double_damage_from {
            defEffects.append(TypeEffect(name: rel.name, value: 200))
        }
        for rel in self.type!.data.damage_relations.double_damage_to {
            atkEffects.append(TypeEffect(name: rel.name, value: 200))
        }
        for rel in self.type!.data.damage_relations.half_damage_to {
            atkEffects.append(TypeEffect(name: rel.name, value: 50))
        }
        for rel in self.type!.data.damage_relations.no_damage_to {
            atkEffects.append(TypeEffect(name: rel.name, value: 0))
        }
        print("---\(self.type!.appearance.name)---")
        print(self.headerHeight)
        var maxDef = max(self.defEffects.filter({ $0.value < 100 }).count, self.defEffects.filter({ $0.value > 100 }).count)
        print(maxDef)
        maxDef += maxDef % 2
        print(maxDef)
        maxDef /= 2
        print(maxDef)
        self.headerHeight += maxDef * 30
        print(self.headerHeight)
        
        var maxAtk = max(self.atkEffects.filter({ $0.value < 100 }).count, self.atkEffects.filter({ $0.value > 100 }).count)
        print(maxAtk)
        maxAtk += maxAtk % 2
        print(maxAtk)
        maxAtk /= 2
        print(maxAtk)
        self.headerHeight += maxAtk * 30
        print(self.headerHeight)
        print("----------")
        
        let sNib = UINib(nibName: "MainButtonCell", bundle: nil)
        self.collectionView.register(sNib, forCellWithReuseIdentifier: "MainButtonCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.masksToBounds = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return type!.data.pokemon.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EffectsCell", for: indexPath)
            let mainView = cell.contentView.subviews[0] as! TypeDetailCollectionHeader
            mainView.configure(type: self.type!, sFunc: self.typeCellTapped(cell:))
            cell.contentView.layer.masksToBounds = false
            cell.layer.masksToBounds = false
            return cell
        }
        else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "MainButtonCell", for: indexPath) as! MainButtonCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: collectionView.frame.size.width - 28, height: CGFloat(self.headerHeight))
        }
        else {
            return CGSize(width: (collectionView.frame.size.width - 70) / 3, height: (collectionView.frame.size.width - 70) / 3)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            let pCell = cell as! MainButtonCell
            pCell.testConfig(pokeUrl: self.type!.data.pokemon[indexPath.row].pokemon)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MainButtonCell
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController {
            vc.pokeUrl = cell.pokeUrl
            self.show(vc, sender: self)
        }
    }
    
    func typeCellTapped(cell: TypeCellButton) {
        
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
