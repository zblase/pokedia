//
//  DetailsViewController.swift
//  Poke Guide
//
//  Created by Zack Blase on 8/9/21.
//

import UIKit

class DetailsViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet var mainView: DetailMainSubView!
    @IBOutlet var statView: DetailStatsSubView!
    @IBOutlet var evolutionView: DetailEvolutionsSubView!
    @IBOutlet var strongView: DetailStrongSubView!
    @IBOutlet var weakView: DetailWeakSubView!
    @IBOutlet var strongSuggestedView: StrongSuggestedCollectionView!
    @IBOutlet var weakSuggestedView: WeakSuggestedCollectionView!
    @IBOutlet var movesetView: DetailMovesetSubView!
    @IBOutlet var movesetHeight: NSLayoutConstraint!
    
    var pokemon: Pokemon?
    var attackEffects: [Move] = []
    var defenseEffects: [TypeEffect] = []
    var moveTypes: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let rows = ceil(Double(pokemon!.moveTypes.count) / 4.0)
        
        let rowHeight = (UIScreen.main.bounds.width) / 10
        
        self.movesetHeight.constant = 250 + (rowHeight) * rows + 16 + (rows * 4)
        
        let favPoke = FavoriteJsonParser().readJson()
        
        navigationItem.title = pokemon!.data.name.capitalizingFirstLetter()
        
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
            var effScore = PokemonEffectScore(poke: pokeDictVal)
            
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
            var effScore = PokemonEffectScore(poke: pokeDictVal)
            
            for typeRef in pokeDictVal.data.types {
                if let effect = testDict[typeRef.type.name], effect != 0 {
                    effScore.score += testDict[typeRef.type.name]!
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
        
        mainView.configure(pokemon: pokemon!)
        statView.configure(pokemon: pokemon!)
        evolutionView.configure(pokemon: pokemon!)
        strongView.configure(pokemon: pokemon!, effects: fromArray.filter({ $0.value < 100 }).sorted(by: { $0.value < $1.value }))
        strongSuggestedView.configure(pokemon: suggestedStrong, favPokemon: strongFavs)
        weakView.configure(pokemon: pokemon!, effects: fromArray.filter({ $0.value > 100 }).sorted(by: { $0.value > $1.value }))
        weakSuggestedView.configure(pokemon: suggestedWeak, favPokemon: weakFavs)
        movesetView.configure(pokemon: pokemon!, detailVC: self)
    }
    
    @IBAction func pokemonClicked(sender: Any?) {
        let pb = sender as! PokemonButton
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController, pb.pokemon!.data.id != self.pokemon!.data.id {
            vc.pokemon = pb.pokemon
            self.show(vc, sender: self)
        }
    }
    
    func showNextVC(pokemon: Pokemon) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController, pokemon.data.id != self.pokemon!.data.id {
            vc.pokemon = pokemon
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
    
    func typeCellTapped(type: TypeStruct) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "TypeDetailsViewController") as? TypeDetailsViewController {
            vc.type = type
            self.show(vc, sender: self)
        }
    }
    
    func showAddFavoriteModal() {
        let favVC = self.storyboard?.instantiateViewController(withIdentifier: "AddFavoriteViewController") as! AddFavoriteViewController
        
        favVC.pokemon = self.pokemon!
        favVC.detailVC = self
        favVC.modalPresentationStyle = .custom
        favVC.transitioningDelegate = self
        
        //present(favVC, animated: true)
        present(favVC, animated: true, completion: { favVC.backgroundButton.isHidden = false })
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
    
    
    func setAsFavorite() {
        
        let menu = UIMenu(title: "", options: .destructive, children: [
            UIAction(title: "New", image: UIImage(systemName: "star")!, handler: { (_) in
                self.showAddFavoriteModal()
            }),
            UIAction(title: "Remove", image: UIImage(systemName: "trash")!, attributes: .destructive, handler: { (_) in
                self.showRemoveFavoriteModal()
            })
        ])
        
        let navItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "star.fill"), primaryAction: nil, menu: menu)
        navItem.tintColor = .systemYellow
        
        self.navigationItem.rightBarButtonItem = navItem
    }
    
    func removeAsFavorite() {
        
        let action = UIAction(title: "") { action in
            self.showAddFavoriteModal()
        }
        
        
        let navItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "star"), primaryAction: action, menu: nil)
        navItem.tintColor = .link
        
        self.navigationItem.rightBarButtonItem = navItem
    }
}

class HalfSizePresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let bounds = containerView?.bounds else { return .zero }
        return CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + 34)
        //return CGRect(x: 0, y: bounds.height - (bounds.height / 1.5), width: bounds.width, height: bounds.height / 1.5)
    }
}
