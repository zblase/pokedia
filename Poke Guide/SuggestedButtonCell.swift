//
//  SuggestedButtonCell.swift
//  Poke Guide
//
//  Created by Zack Blase on 10/5/21.
//

import UIKit

class SuggestedButtonCell: UICollectionViewCell {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var cellIcon: UIImageView!
    @IBOutlet var cellName: UILabel!
    @IBOutlet var cellSubName: UILabel!
    @IBOutlet var cellButton: UIButton!
    @IBOutlet var typeImgA: UIImageView!
    @IBOutlet var typeImgB: UIImageView!
    @IBOutlet var typeImgC: UIImageView!
    
    //var pokemon: Pokemon!
    var pokeUrl: PokemonArrayResult.PokemonUrl!
    var types: [String]?
    var selectFunc: ((PokemonArrayResult.PokemonUrl, [String]?) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(url: PokemonArrayResult.PokemonUrl, color: UIColor, types: [String], sFunc: ((PokemonArrayResult.PokemonUrl, [String]?) -> ())?) {
        //self.pokemon = pokemon
        self.pokeUrl = url
        self.types = types
        self.selectFunc = sFunc
        
        //self.cellIcon.image = pokeImages[self.pokeUrl.getId()]
        
        typeImgA.isHidden = true
        typeImgB.isHidden = true
        typeImgC.isHidden = true
        
        if types.count > 0 {
            let type = typeDict[types[0]]!
            typeImgA.isHidden = false
            typeImgA.image = type.appearance.getImage().withRenderingMode(.alwaysTemplate)
            typeImgA.tintColor = type.appearance.getColor()
        }
        if types.count > 1 {
            let type = typeDict[types[1]]!
            typeImgB.isHidden = false
            typeImgB.image = type.appearance.getImage().withRenderingMode(.alwaysTemplate)
            typeImgB.tintColor = type.appearance.getColor()
        }
        if types.count > 2 {
            let type = typeDict[types[2]]!
            typeImgC.isHidden = false
            typeImgC.image = type.appearance.getImage().withRenderingMode(.alwaysTemplate)
            typeImgC.tintColor = type.appearance.getColor()
        }
        
        self.cellButton.backgroundColor = color.withAlphaComponent(0.5)
        self.cellButton.layer.cornerRadius = 10
        self.cellButton.layer.borderWidth = 1
        self.cellButton.layer.borderColor = UIColor(named: "ColorButtonBorder")?.cgColor
        
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        self.layer.shadowRadius = 0.75
        self.layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.2 : 0.4
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        
        
        self.cellName.text = self.pokeUrl.getDisplayName().name
        let subName = self.pokeUrl.getDisplayName().subName
        self.cellSubName.text = subName
        self.cellSubName.isHidden = subName == "Normal"
        
        tryGetImage()
    }
    
    @IBAction func pokemonTapped(_ sender: Any?) {
        
        if self.selectFunc != nil {
            self.selectFunc!(self.pokeUrl, self.types)
        }
    }
    
    func tryGetImage() {
        if let img = pokeImageArray.first(where: { $0.id == self.pokeUrl.getId() }){
            self.activityIndicator.stopAnimating()
            self.cellIcon.image = img.image
        }
        else {
            self.cellIcon.image = nil
            self.activityIndicator.startAnimating()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.tryGetImage()
            })
        }
    }
}
