//
//  RemoveFavoriteViewController.swift
//  Poke Guide
//
//  Created by Zack Blase on 10/1/21.
//

import UIKit

class RemoveFavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet var backgroundButton: UIButton!
    @IBOutlet var modalView: UIView!
    @IBOutlet var tableView: UITableView!
    
    var detailVC: DetailsViewController!
    var pokemon: Pokemon!
    var pokeArray: [Pokemon] = []
    var favArray: [FavPokemonJson.FavJson] = []
    var selectedPokemon: [FavPokemonJson.FavJson] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        modalView.layer.cornerRadius = 15
        modalView.layer.masksToBounds = true
        
        let fArray = FavoriteJsonParser().readJson()
        self.favArray = fArray.favArray.filter({ $0.name == pokemon!.data.name })
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        //tableView.setEditing(true, animated: true)
    }
    
    @IBAction func cancelTapped(_ sender: Any?) {
        self.backgroundButton.isHidden = true
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeTapped(_ sender: Any?) {
        
        detailVC?.removeFavorites(favs: selectedPokemon)
        
        self.backgroundButton.isHidden = true
        dismiss(animated: true, completion: nil)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RemoveFavoriteTableCell.identifier, for: indexPath) as! RemoveFavoriteTableCell
        cell.configure(fav: favArray[indexPath.row], hidden: !selectedPokemon.contains(favArray[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RemoveFavoriteTableCell
        //cell.setSelected(!cell.isSelected, animated: true)
        if selectedPokemon.contains(cell.favPoke) {
            //cell.contentView.backgroundColor = .clear
            //cell.removeIcon.isHidden = true
            selectedPokemon.removeAll(where: { $0 == cell.favPoke })
        }
        else {
            //cell.contentView.backgroundColor = .systemRed.withAlphaComponent(0.1)
            //cell.removeIcon.isHidden = false
            selectedPokemon.append(cell.favPoke)
        }
        
        self.tableView.reloadData()
    }
}
