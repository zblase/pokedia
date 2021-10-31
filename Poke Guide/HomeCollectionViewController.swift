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
    @IBOutlet var backToTopBtn: UIView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    //var currentResults: [PokemonArrayResult.PokemonUrl] = []
    var currentResults: [PokemonArrayResult.PokemonUrl] = []
    
    let dispatchGroup = DispatchGroup()
    let dataDispatchGroup = DispatchGroup()
    //let pokemonGroupA = DispatchGroup()
    let pokemonGroupB = DispatchGroup()
    let pokemonGroupC = DispatchGroup()
    
    var pokeDataList: [PokemonCellData] = []
    var result: PokemonArrayResult?
    
    var searchActive: Bool = false
    var searchText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //activityIndicator.hidesWhenStopped = true
        //activityIndicator.startAnimating()
        activityIndicator.isHidden = true
        
        backToTopBtn.isHidden = true
        
        let sNib = UINib(nibName: "MainButtonCell", bundle: nil)
        self.collectionView.register(sNib, forCellWithReuseIdentifier: "MainButtonCell")
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        
        
        self.currentResults = baseUrlArray
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let typeController = TypeDataController()
        typeController.getAllTypeData{ (success) -> Void in
            if success {
                
                let pokeController = PokemonDataController()
                pokeController.getAllPokemonData(homeController: self)
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
            self.currentResults = baseUrlArray
            //self.currentResults = pokemonArray
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
            self.currentResults = baseUrlArray
            //self.currentResults = pokemonArray
            self.collectionView.reloadData()
            return
        }
        
        searchActive = true
        self.currentResults = baseUrlArray.filter({ $0.name.contains(searchText.lowercased()) })
        //self.currentResults = pokemonArray.filter({ $0.data.name.contains(searchText.lowercased()) })
        self.collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {
            self.currentResults = baseUrlArray
            //self.currentResults = pokemonArray
            self.collectionView.reloadData()
            return
        }
        
        searchActive = true
        self.currentResults = baseUrlArray.filter({ $0.name.contains(searchText.lowercased()) })
        //self.currentResults = pokemonArray.filter({ $0.data.name.contains(searchText.lowercased()) })
        self.collectionView.reloadData()
        
        self.searchController.dismiss(animated: true, completion: nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchText = ""
        self.currentResults = baseUrlArray
        //self.currentResults = pokemonArray
        self.collectionView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = self.searchText
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "MainButtonCell", for: indexPath) as! MainButtonCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 70) / 3, height: (collectionView.frame.size.width - 70) / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        self.backToTopBtn.isHidden = collectionView.visibleCells.contains(where: { collectionView.indexPath(for: $0)?.row == 0 })
        
        let pCell = cell as! MainButtonCell
        pCell.configureCellIdentity(pokeUrl: self.currentResults[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MainButtonCell
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController {
            vc.pokeUrl = cell.pokeUrl
            self.show(vc, sender: self)
        }
    }
    
    @IBAction func scrollToTop(_ sender: Any?) {
        if currentResults.count > 0 {
            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        
        //self.backToTopBtn.isHidden = true
    }
    
    func showNextVC(pokemon: Pokemon) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController {
            //vc.pokemon = pokemon
            //vc.pokeUrl = pokeUrlArray?.urlArray.first(where: { $0.name == pokemon.data.name })
            self.show(vc, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is DetailsViewController {
            let vc = segue.destination as? DetailsViewController
            let pButton = sender as! PokemonButton
            
            vc?.pokeUrl = pButton.pokeUrl
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
