//
//  DetailStatsSubView.swift
//  Poke Guide
//
//  Created by Zack Blase on 8/11/21.
//

import UIKit

class DetailStatsSubView: ToggleViewButton, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var viewButton: UIButton!
    @IBOutlet var chevron: UIImageView!
    @IBOutlet var divider: UIImageView!
    @IBOutlet var subView: UIView!
    
    var pokemon: Pokemon?
    let names: [String] = ["HP", "Attack", "Defense", "Sp. Attack", "Sp. Defense", "Speed"]
    let values: [Int] = [ 245, 141, 152, 186, 175, 148]
    let maxValues: [Int] = [294, 216, 216, 251, 251, 207]
    
    var primaryColor: UIColor?
    var secondaryColor: UIColor?
    
    public func configure(pokemon: Pokemon) {
        //self.isHidden = true;
        
        self.pokemon = pokemon
        primaryColor = pokemon.data.getTypeStruct(slot: 1).appearance.getColor()
        secondaryColor = pokemon.data.types.count > 1 ? pokemon.data.getTypeStruct(slot: 2).appearance.getColor() : primaryColor
        
        configureButton(button: viewButton, color: primaryColor!, chevron: chevron, divider: divider)
        
        configureSubView(subView: subView, color: secondaryColor!)
        
        if !self.isHidden {
            highlightButton(button: viewButton, color: primaryColor!)
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        animateCells()
    }
    
    @IBAction func toggleView(sender: Any?) {
        self.isHidden = !self.isHidden
        
        if self.deg == .pi {
            
            setOpenButton(button: viewButton, color: primaryColor!, chevron: chevron)
            
            animateCells()
        }
        else {
            
            setClosedButton(button: viewButton, color: primaryColor!, chevron: chevron)
        }
    }
    
    func animateCells() {
        for i in 0...5 {
            if i > collectionView.visibleCells.count - 1 {
                return
            }
            let cell = collectionView.visibleCells[i] as! StatCollectionViewCell
            cell.configure(stat: pokemon!.data.stats[i], color: secondaryColor!)
            cell.doAnimation()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatCollectionViewCell.identifier, for: indexPath) as! StatCollectionViewCell
        
        let i = indexPath.row
        cell.configure(stat: pokemon!.data.stats[i], color: secondaryColor!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //return CGSize(width: self.frame.size.width / 3.5, height: self.frame.size.width / 3.5)
        return CGSize(width: self.frame.size.width / 3.5, height: self.frame.size.height / 2.25)
    }
}
