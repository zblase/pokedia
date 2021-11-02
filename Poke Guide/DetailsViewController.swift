//
//  DetailsViewController.swift
//  Poke Guide
//
//  Created by Zack Blase on 8/9/21.
//

import UIKit

class DetailsViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet var activityView: UIActivityIndicatorView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var mainView: DetailMainSubView!
    @IBOutlet var mainHeight: NSLayoutConstraint!
    @IBOutlet var mainRightBottomMargin: NSLayoutConstraint!
    @IBOutlet var statView: DetailStatsSubView!
    @IBOutlet var evolutionView: DetailEvolutionsSubView!
    @IBOutlet var strongView: DetailStrongSubView!
    @IBOutlet var strongHeight: NSLayoutConstraint!
    @IBOutlet var weakView: DetailWeakSubView!
    @IBOutlet var weakHeight: NSLayoutConstraint!
    @IBOutlet var movesetView: DetailMovesetSubView!
    @IBOutlet var movesetHeight: NSLayoutConstraint!
    @IBOutlet var toggleView: UIView!
    
    var pokeUrl: PokemonArrayResult.PokemonUrl?
    var pokemon: Pokemon?
    var formNames: [PokemonArrayResult.PokemonUrl] = []
    var attackEffects: [Move] = []
    var defenseEffects: [TypeEffect] = []
    var moveTypes: [String] = []
    var favTypes: [String]?
    var primaryColor: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for btn in toggleView.subviews {
            btn.isHidden = true
        }
        
        scrollView.isUserInteractionEnabled = false
        self.view.bringSubviewToFront(activityView)
        activityView.isHidden = false
        activityView.hidesWhenStopped = true
        activityView.startAnimating()
        
        self.mainView.rightView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.1)
        self.mainView.rightView.layer.cornerRadius = 10
        self.mainView.rightView.layer.borderWidth = 1
        self.mainView.rightView.layer.borderColor = UIColor.systemGray.cgColor
        
        self.mainView.numberLabel.text = "#\(pokeUrl!.getId())"
        self.mainView.nameLabel.text = String(pokeUrl!.name.split(separator: "-")[0]).capitalizingFirstLetter()
        
        self.statView.isHidden = true
        self.evolutionView.isHidden = true
        self.strongView.isHidden = true
        self.weakView.isHidden = true
        self.movesetView.isHidden = true
        
        self.tryGetPokemon()
    }
    
    func configure() {
        
        let typeARef = pokemon!.data.types.first(where: { $0.slot == 1 })
        let typeA: TypeStruct = typeDict[typeARef!.type.name]!
        self.primaryColor = typeA.appearance.getColor()
        self.toggleView.layer.borderColor = self.primaryColor.cgColor
        for view in self.toggleView.subviews {
            let btn = view as! UIButton
            if btn.backgroundColor != .clear {
                btn.backgroundColor = self.primaryColor
            }
            else {
                btn.tintColor = self.primaryColor
            }
        }
        
        if self.formNames.count == 0 {
            
            if self.pokeUrl!.name != "pumpkaboo-average" && self.pokeUrl!.name != "zamazenta-hero" && self.pokeUrl!.name != "zacian-hero" {
                if let url = pokeUrlArray?.urlArray.first(where: { $0.name == self.pokemon!.data.species?.name}) {
                    
                    self.formNames.append(url)
                }
                else {
                    
                    self.formNames.append(self.pokeUrl!)
                }
            }
            self.formNames.append(contentsOf: pokeUrlArray!.urlArray.filter({ $0.name.contains("\(self.pokemon!.data.species!.name)-") }))
            
            activityView.stopAnimating()
            scrollView.isUserInteractionEnabled = true
            
            if formNames.count > 1 {
                toggleView.isHidden = false
                mainRightBottomMargin.constant = 40
                mainHeight.constant = 181
                
                for i in 0...formNames.count - 1 {
                    let btn = toggleView.subviews[i] as! UIButton
                    btn.layer.cornerRadius = 12
                    btn.layer.masksToBounds = true
                    
                    let title = formNames[i].getDisplayName().subName
                    btn.setTitle(title, for: .normal)
                    btn.setAttributedTitle(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .regular), NSAttributedString.Key.underlineStyle : nil ]), for: .normal)
                    
                    if formNames[i].name == self.pokeUrl!.name {
                        btn.backgroundColor = self.primaryColor
                        btn.tintColor = .white
                    }
                    else {
                        btn.backgroundColor = .clear
                        btn.tintColor = self.primaryColor
                    }
                    
                    btn.titleLabel!.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                    
                    btn.isHidden = false
                }
            }
            else {
                toggleView.isHidden = true
                mainRightBottomMargin.constant = 0
                mainHeight.constant = 125
            }
            
            toggleView.layer.cornerRadius = 15
            toggleView.layer.borderWidth = 1
            toggleView.layer.borderColor = self.primaryColor.cgColor
        }
        
        
        let typeBRef = pokemon!.data.types.first(where: { $0.slot == 2 })
        let typeRef = typeBRef != nil ? typeBRef : pokemon!.data.types.first(where: { $0.slot == 1 })!
        let type: TypeStruct = typeDict[typeRef!.type.name]!
        //self.backgroundView.backgroundColor = type.appearance.getColor().withAlphaComponent(0.08)
        
        let favPoke = FavoriteJsonParser().readJson()
        
        
        var title = ""
        let names = pokemon!.data.name.split(separator: "-")
        for name in names {
            title += String(name).capitalizingFirstLetter() + " "
        }
        
        navigationItem.title = String(title.dropLast())
        
        if !favPoke.favArray.contains(where: { $0.name == pokemon?.data.name}) {
            self.removeAsFavorite()
        }
        else {
            self.setAsFavorite()
        }
        
        var testArray: [TypeEffect] = []
        var testDict: [String: Double] = [:]
        for url in typeUrlArray {
            testArray.append(TypeEffect(name: url.name, value: 0))
        }
        
        for typeRef in pokemon!.data.types {
            let type = typeDict[typeRef.type.name]!
            
            for rel in type.data.damage_relations.double_damage_from {
                if testDict[rel.name] != nil {
                    testDict[rel.name]! += 1
                }
                else {
                    testDict[rel.name] = 1
                }
            }
            for rel in type.data.damage_relations.half_damage_from {
                if testDict[rel.name] != nil {
                    testDict[rel.name]! -= 1
                }
                else {
                    testDict[rel.name] = -1
                }
            }
            for rel in type.data.damage_relations.no_damage_from {
                if testDict[rel.name] != nil {
                    testDict[rel.name]! -= 2
                }
                else {
                    testDict[rel.name] = -2
                }
            }
        }
        
        var suggestedStrong: [PokemonEffectScore] = []
        var suggestedWeak: [PokemonEffectScore] = []
        
        for poke in pokeUrlArray!.urlArray {
            guard let pokeDictVal = pokemonDict[poke.name] else { continue }
            var effScore = PokemonEffectScore(poke: pokeDictVal, types: pokeDictVal.data.types.map({ $0.type.name }))
            
            for typeRef in pokeDictVal.data.types {
                if let effect = testDict[typeRef.type.name], effect != 0 {
                    effScore.score += testDict[typeRef.type.name]!
                }
            }
            
            if !effScore.pokemon.data.name.contains("-mega") {
                if effScore.score < 0 {
                    suggestedStrong.append(effScore)
                }
                else if effScore.score > 0 {
                    suggestedWeak.append(effScore)
                }
            }
        }
        
        suggestedStrong.sort {
            ($0.score * -1, $0.pokemon.data.stats.first(where: { $0.stat.name == "attack" })!.base_stat) >
            ($1.score * -1, $1.pokemon.data.stats.first(where: { $0.stat.name == "attack" })!.base_stat)
        }
        
        suggestedWeak.sort {
            ($0.score, $0.pokemon.data.stats.first(where: { $0.stat.name == "attack" })!.base_stat) >
            ($1.score, $1.pokemon.data.stats.first(where: { $0.stat.name == "attack" })!.base_stat)
        }
        
        var strongFavs: [PokemonEffectScore] = []
        var weakFavs: [PokemonEffectScore] = []
        
        for poke in favPoke.favArray {
            guard let pokeDictVal = pokemonDict[poke.name] else { continue }
            var effScore = PokemonEffectScore(poke: pokeDictVal, types: poke.types)
            effScore.types = poke.types
            
            for typeRef in poke.types {
                if let effect = testDict[typeRef], effect != 0 {
                    effScore.score += testDict[typeRef]!
                }
            }
            
            if effScore.score < 0 {
                strongFavs.append(effScore)
            }
            else if effScore.score > 0 {
                weakFavs.append(effScore)
            }
        }
        
        strongFavs.sort {
            ($0.score * -1, $0.pokemon.data.stats.first(where: { $0.stat.name == "attack" })!.base_stat) >
            ($1.score * -1, $1.pokemon.data.stats.first(where: { $0.stat.name == "attack" })!.base_stat)
        }
        
        weakFavs.sort {
            ($0.score, $0.pokemon.data.stats.first(where: { $0.stat.name == "attack" })!.base_stat) >
            ($1.score, $1.pokemon.data.stats.first(where: { $0.stat.name == "attack" })!.base_stat)
        }
        
        var fromArray: [TypeEffect] = []
        
        for url in typeUrlArray {
            if let effect = testDict[url.name], effect != 0 {
                var val: Double
                switch effect {
                case 2:
                    val = 400
                case 1:
                    val = 200
                case -1:
                    val = 75
                case -2:
                    val = 50
                case -3:
                    val = 25
                case -4:
                    val = 0
                default:
                    val = 100
                }
                fromArray.append(TypeEffect(name: url.name, value: val))
            }
        }
        
        let strongArray = fromArray.filter({ $0.value < 100 }).sorted(by: { $0.value < $1.value })
        let weakArray = fromArray.filter({ $0.value > 100 }).sorted(by: { $0.value > $1.value })
        
        let strongRows = ceil(Double(strongArray.count) / 4.0)
        let weakRows = ceil(Double(weakArray.count) / 4.0)
        let movesetRows = ceil(Double(pokemon!.moveTypes.count) / 4.0)
        
        let rowHeight = (UIScreen.main.bounds.width) / 10
        
        self.strongHeight.constant = 160 + (rowHeight) * strongRows + 16 + (strongRows * 4)
        self.weakHeight.constant = 160 + (rowHeight) * weakRows + 16 + (weakRows * 4)
        //self.movesetHeight.constant = 250 + (rowHeight) * movesetRows + 16 + (movesetRows * 4)
        
        mainView.configure(pokemon: pokemon!, forms: self.formNames, fFunc: self.switchForm(url:))
        statView.configure(pokemon: pokemon!)
        evolutionView.configure(pokemon: pokemon!)
        strongView.configure(pokemon: pokemon!, effects: strongArray, suggAll: suggestedStrong, suggFav: strongFavs, detailVC: self)
        weakView.configure(pokemon: pokemon!, effects: weakArray, suggAll: suggestedWeak, suggFav: weakFavs, detailVC: self)
        movesetView.configure(pokemon: pokemon!, detailVC: self)
    }
    
    @IBAction func showForm(_ sender: Any) {
        for viewBtn in self.toggleView.subviews {
            let btn = viewBtn as! UIButton
            
            if btn == sender as! UIButton {
                btn.backgroundColor = self.primaryColor
                btn.tintColor = .white
                
                let title = String(btn.currentTitle!.replacingOccurrences(of: " ", with: "-").dropLast()).lowercased()
                
                let url = self.formNames.first(where: { $0.name.contains("-\(title)")}) ?? self.formNames[0]
                self.switchForm(url: url)
            }
            else {
                btn.backgroundColor = .clear
                btn.tintColor = self.primaryColor
            }
        }
    }
    
    @IBAction func pokemonClicked(sender: Any?) {
        let pb = sender as! PokemonButton
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController, pb.pokemon!.data.id != self.pokemon!.data.id {
            vc.pokemon = pb.pokemon
            vc.pokeUrl = pb.pokeUrl
            self.show(vc, sender: self)
        }
    }
    
    func showNextVC(pokemon: Pokemon, types: [String]? = nil) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController, pokemon.data.id != self.pokemon!.data.id {
            vc.pokemon = pokemon
            vc.pokeUrl = pokeUrlArray?.urlArray.first(where: { $0.name == pokemon.data.name })
            vc.favTypes = types
            self.show(vc, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is AddFavoriteViewController {
            let vc = segue.destination as? AddFavoriteViewController
            vc?.pokemon = self.pokemon!
        }
    }
    
    func typeCellTapped(cell: TypeButtonCell) {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "TypeDetailsViewController") as? TypeDetailsViewController {
            vc.type = cell.type
            self.show(vc, sender: self)
        }
    }
    
    func toggleTypeCell(cell: TypeButtonCell) {
        self.movesetView.typeCellTapped(cell: cell)
    }
    
    func showAddFavoriteModal() {
        let filterVC = self.storyboard?.instantiateViewController(withIdentifier: "TypeFilterController") as! TypeFilterController
        
        filterVC.titleStr = "Add Favorite"
        filterVC.labelStr = "Selected move types:"
        filterVC.saveCallback = self.addFavorite(types:)
        filterVC.selectedTypes = self.pokemon!.data.types.compactMap({ typeDict[$0.type.name]! })
        filterVC.saveWithNone = false
        filterVC.modalPresentationStyle = .custom
        filterVC.transitioningDelegate = self
        
        present(filterVC, animated: true, completion: { filterVC.backgroundButton.isHidden = false })
    }
    
    func showRemoveFavoriteModal() {
        let remVC = self.storyboard?.instantiateViewController(withIdentifier: "RemoveFavoriteViewController") as! RemoveFavoriteViewController
        
        remVC.pokemon = self.pokemon!
        remVC.detailVC = self
        remVC.modalPresentationStyle = .custom
        remVC.transitioningDelegate = self
        
        //present(favVC, animated: true)
        present(remVC, animated: true, completion: {
            remVC.backgroundButton.isHidden = false
            //remVC.tableView.setEditing(true, animated: true)
        })
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presentingViewController)
    }
    
    
    func addFavorite(types: [TypeStruct]) {
        FavoriteJsonParser().addFavorite(fav: FavPokemonJson.FavJson(name: pokemon!.data.name, types: types.compactMap({ $0.appearance.name.lowercased() })))
        
        self.setAsFavorite()
    }
    
    func setAsFavorite() {
        
        let menu = UIMenu(title: "", options: .destructive, children: [
            UIAction(title: "New", image: UIImage(systemName: "star")!, handler: { (_) in
                self.showAddFavoriteModal()
            }),
            UIAction(title: "Remove", image: UIImage(systemName: "trash")!, attributes: .destructive, handler: { (_) in
                
                let favs = favPokemon?.favArray.filter({ $0.name == self.pokemon!.data.name })
                if favs!.count > 1 {
                    self.showRemoveFavoriteModal()
                }
                else {
                    self.removeFavorites(favs: favs!)
                }
            })
        ])
        
        let navItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "star.fill"), primaryAction: nil, menu: menu)
        navItem.tintColor = .systemYellow
        
        self.navigationItem.rightBarButtonItem = navItem
    }
    
    func removeFavorites(favs: [FavPokemonJson.FavJson]) {
        
        for poke in favs {
            FavoriteJsonParser().removeFavorite(fav: poke)
        }
        
        if !FavoriteJsonParser().readJson().favArray.contains(where: { $0.name == pokemon!.data.name }) {
            self.removeAsFavorite()
        }
    }
    
    func removeAsFavorite() {
        
        let action = UIAction(title: "") { action in
            self.showAddFavoriteModal()
        }
        
        
        let navItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "star"), primaryAction: action, menu: nil)
        navItem.tintColor = .link
        
        self.navigationItem.rightBarButtonItem = navItem
    }
    
    
    func switchForm(url: PokemonArrayResult.PokemonUrl) {
        self.pokeUrl = url
        tryGetPokemon()
    }
    
    func tryGetPokemon() {
        
        if let poke = pokemonDict[pokeUrl!.name] {
            self.pokemon = poke
            configure()
        }
        else {
            
            self.mainView.numberLabel.text = "#\(self.pokeUrl!.getId())"
            
            let displayName = self.pokeUrl?.getDisplayName()
            self.mainView.nameLabel.text = displayName?.name
            self.mainView.subNameLabel.isHidden = displayName?.subName == "Normal"
            self.mainView.subNameLabel.text = displayName?.subName
            
            self.mainView.mainImage.image = nil
            
            self.statView.isHidden = true
            self.evolutionView.isHidden = true
            self.strongView.isHidden = true
            self.weakView.isHidden = true
            self.movesetView.isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.tryGetPokemon()
            })
        }
    }
}

class HalfSizePresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let bounds = containerView?.bounds else { return .zero }
        return CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + 34)
        //return CGRect(x: 0, y: bounds.height - (bounds.height / 1.5), width: bounds.width, height: bounds.height / 1.5)
    }
}
