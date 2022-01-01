//
//  MainButtonCell.swift
//  Poke Guide
//
//  Created by Zack Blase on 10/8/21.
//

import UIKit

class MainButtonCell: UICollectionViewCell {

    var pokeUrl: PokemonArrayResult.PokemonUrl?
    var pokemon: Pokemon?
    var favTypes: [String]?
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellName: UILabel!
    //@IBOutlet var cellSubName: UILabel!
    @IBOutlet var cellNumber: UILabel!
    //@IBOutlet var pokemonButton: PokemonButton!
    @IBOutlet var typeBtnA: UIImageView!
    @IBOutlet var typeBtnB: UIImageView!
    @IBOutlet var typeBtnC: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func testConfig(pokeUrl: PokemonArrayResult.PokemonUrl, favTypes: [String]? = nil) {
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        self.pokeUrl = pokeUrl
        self.favTypes = favTypes
        
        cellName.text = pokeUrl.getDisplayName().name
        
        cellNumber.text = "#\(pokeUrl.getId())"
        
        contentView.layer.cornerRadius = 12.0
        contentView.layer.borderWidth = 0.75
        contentView.layer.borderColor = UIColor(named: "ColorHomeCellBorder")!.cgColor
        contentView.backgroundColor = .tertiarySystemBackground
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowRadius = 1.0
        layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.2 : 0.4
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        
        typeBtnA.isHidden = true
        typeBtnB.isHidden = true
        typeBtnC.isHidden = true
        
        let pokeTypes = pokeTypes.first(where: { String($0.id) == self.pokeUrl!.getId() })
        let typeArray = favTypes != nil ? favTypes : pokeTypes?.types.sorted(by: { $0.slot < $1.slot }).map({ typeNames[$0.type - 1] })
        
        if typeArray!.count > 0 {
            let type: TypeStruct = typeDict[typeArray![0].lowercased()]!
            configureTypeButton(imgView: typeBtnA, type: type.appearance)
        }
        
        if typeArray!.count > 1 {
            let type: TypeStruct = typeDict[typeArray![1].lowercased()]!
            configureTypeButton(imgView: typeBtnB, type: type.appearance)
        }
        
        if typeArray!.count > 2 {
            let type: TypeStruct = typeDict[typeArray![2].lowercased()]!
            configureTypeButton(imgView: typeBtnC, type: type.appearance)
        }
        
        tryGetImage(id: self.pokeUrl!.getId())
    }
    
    func configureTypeButton(imgView: UIImageView, type: TypeAppearance) {
        
        let fSize = type.fontSize != nil ? type.fontSize : 16.0
        let symConfig: UIImage.SymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont(name: "Helvetica Neue", size: CGFloat(fSize!))!)
        
        imgView.isHidden = false
        imgView.tintColor = type.getColor()
        imgView.image = type.getImage().withConfiguration(symConfig).withRenderingMode(.alwaysTemplate)
        imgView.contentMode = .scaleAspectFit
    }
    
    func configureImage(img: UIImage) {
        cellImage.layer.shadowColor = UIColor.black.cgColor
        cellImage.layer.shadowRadius = 2.5
        cellImage.layer.shadowOpacity = 0.45
        cellImage.layer.shadowOffset = CGSize(width: 2.5, height: 4)
        cellImage.layer.masksToBounds = false
        
        self.activityIndicator.stopAnimating()
        cellImage.image = img
    }
    
    func tryGetImage(id: String) {
        
        if id != self.pokeUrl!.getId() {
            return
        }
        if let img = pokeImageArray.first(where: { $0.id == id }) {
            self.configureImage(img: img.image)
        }
        /*if let img = pokeImages[id] {
            self.configureImage(img: img)
        }*/
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.tryGetImage(id: id)
            })
        }
    }
}
