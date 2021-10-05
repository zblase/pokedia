//
//  HomeCollectionViewController.swift
//  Poke Guide
//
//  Created by Zack Blase on 8/5/21.
//

import UIKit

class HomeCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate  {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var collectionView: UICollectionView!
    let searchController = UISearchController(searchResultsController: nil)
    
    //var currentResults: [PokemonArrayResult.PokemonUrl] = []
    var currentResults: [Pokemon] = []
    
    let dispatchGroup = DispatchGroup()
    let dataDispatchGroup = DispatchGroup()
    let pokemonGroupA = DispatchGroup()
    let pokemonGroupB = DispatchGroup()
    let pokemonGroupC = DispatchGroup()
    
    var pokeDataList: [PokemonCellData] = []
    var result: PokemonArrayResult?
    
    var searchActive: Bool = false
    var searchText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let typeController = TypeDataController()
        typeController.getAllTypeData{ (success) -> Void in
            if success {
                
                let pokeController = PokemonDataController()
                pokeController.getAllPokemonData(homeController: self) { (success) -> Void in
                    if success && !self.searchActive {
                        //self.currentResults = pokeUrlArray!.urlArray
                        self.currentResults = pokemonArray
                        self.collectionView.reloadData()
                        
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if searchController.searchBar.text != nil && !searchController.searchBar.text!.isEmpty {
            //self.present(searchController, animated: true, completion: nil)
            //searchController.isActive = true
        }
    }
    
    func updateResultsList() {
        if !searchActive {
            //self.currentResults = pokeUrlArray!.urlArray
            self.currentResults = pokemonArray
            self.collectionView.reloadData()
        }
        else {
            for vCell in self.collectionView.visibleCells {
                let cell = vCell as! MyCollectionViewCell
                cell.configureCellIdentity(pokeUrl: cell.pokeUrl!)
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        guard let text = searchBar.text, !text.isEmpty else {
            //self.currentResults = pokeUrlArray!.urlArray
            self.currentResults = pokemonArray
            self.collectionView.reloadData()
            return
        }
        
        searchActive = true
        //self.currentResults = pokeUrlArray!.urlArray.filter({ $0.name.contains(searchText.lowercased()) })
        self.currentResults = pokemonArray.filter({ $0.data.name.contains(searchText.lowercased()) })
        self.collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {
            //self.currentResults = pokeUrlArray!.urlArray
            self.currentResults = pokemonArray
            self.collectionView.reloadData()
            return
        }
        
        searchActive = true
        //self.currentResults = pokeUrlArray!.urlArray.filter({ $0.name.contains(searchText.lowercased()) })
        self.currentResults = pokemonArray.filter({ $0.data.name.contains(searchText.lowercased()) })
        self.collectionView.reloadData()
        
        self.searchController.dismiss(animated: true, completion: nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchText = ""
        //self.currentResults = pokeUrlArray!.urlArray
        self.currentResults = pokemonArray
        self.collectionView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = self.searchText
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        if indexPath.row < currentResults.count {
            //cell.configureCellIdentity(pokeUrl: currentResults[indexPath.row])
            //let test = collectionView.cellForItem(at: <#T##IndexPath#>)
            cell.configureCellData(poke: currentResults[indexPath.row])
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is DetailsViewController {
            let vc = segue.destination as? DetailsViewController
            let pButton = sender as! PokemonButton
            vc?.pokemon = pButton.pokemon
        }
    }
}

public struct PokemonCellData {
    let data: PokemonData
    let image: UIImage
    
    init(data: PokemonData, image: UIImage) {
        self.data = data
        self.image = image
    }
}
