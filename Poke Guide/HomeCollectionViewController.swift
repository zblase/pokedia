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
    @IBOutlet var toggleView: UIView!
    @IBOutlet weak var collectionViewMargin: NSLayoutConstraint!
    var cvMarginValue = 0
    var addSlotFunction: ((PokemonArrayResult.PokemonUrl, [String]?) -> ())!
    
    let searchController = UISearchController(searchResultsController: nil)
    var cheatSheetVC: CheatSheetViewController!
    
    //var currentResults: [PokemonArrayResult.PokemonUrl] = []
    var currentResults: [Any] = []
    
    let dispatchGroup = DispatchGroup()
    let dataDispatchGroup = DispatchGroup()
    //let pokemonGroupA = DispatchGroup()
    let pokemonGroupB = DispatchGroup()
    let pokemonGroupC = DispatchGroup()
    
    var pokeDataList: [PokemonCellData] = []
    var result: PokemonArrayResult?
    
    var searchActive: Bool = false
    var searchText: String = ""
    
    var allBtn: UIButton!
    var favBtn: UIButton!
    var favPokes: FavPokemonJson!
    var baseResults: [Any]!
    var showFavs = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViewMargin.constant = CGFloat(cvMarginValue)
        activityIndicator.isHidden = true
        favPokes = FavoriteJsonParser().readJson()
        baseResults = baseUrlArray
        
        backToTopBtn.isHidden = true
        let topBtnImg = backToTopBtn.subviews[1] as! UIImageView
        topBtnImg.layer.shadowColor = UIColor.black.cgColor
        topBtnImg.layer.shadowRadius = 4
        topBtnImg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.75 : 1
        topBtnImg.layer.shadowOffset = CGSize(width: 0, height: 0)
        topBtnImg.layer.masksToBounds = false
        
        let sNib = UINib(nibName: "MainButtonCell", bundle: nil)
        self.collectionView.register(sNib, forCellWithReuseIdentifier: "MainButtonCell")
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        
        
        self.currentResults = baseUrlArray
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let pokeController = PokemonDataController()
        pokeController.getAllImages()
        
        self.toggleView.layer.cornerRadius = 15
        self.toggleView.layer.borderColor = UIColor.link.cgColor
        self.toggleView.layer.borderWidth = 1
        allBtn = self.toggleView.subviews[0] as? UIButton
        allBtn.layer.cornerRadius = 12
        allBtn.tintColor = .white
        favBtn = self.toggleView.subviews[1] as? UIButton
        favBtn.layer.cornerRadius = 12
        favBtn.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if searchController.searchBar.text != nil && !searchController.searchBar.text!.isEmpty {
            //self.present(searchController, animated: true, completion: nil)
            //searchController.isActive = true
        }
    }
    
    @IBAction func showFavorites(_ sender: Any) {
        self.showFavs = true
        
        allBtn.backgroundColor = UIColor.clear
        allBtn.tintColor = UIColor.link
        favBtn.backgroundColor = UIColor.link
        favBtn.tintColor = UIColor.white
        
        self.currentResults = favPokes.favArray
        self.collectionView.reloadData()
    }
    
    @IBAction func showAll(_ sender: Any) {
        self.showFavs = false
        
        allBtn.backgroundColor = UIColor.link
        allBtn.tintColor = UIColor.white
        favBtn.backgroundColor = UIColor.clear
        favBtn.tintColor = UIColor.link
        
        self.currentResults = baseUrlArray
        self.collectionView.reloadData()
    }
    
    func updateResultsList() {
        if !searchActive {
            self.currentResults = showFavs ? favPokes.favArray as [Any] : baseUrlArray as [Any]
            
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
            self.currentResults = showFavs ? favPokes.favArray as [Any] : baseUrlArray as [Any]
            
            self.collectionView.reloadData()
            return
        }
        
        searchActive = true
        if showFavs {
            self.currentResults = favPokes.favArray.filter({ $0.name.contains(searchText.lowercased()) })
        }
        else {
            self.currentResults = baseUrlArray.filter({ $0.name.contains(searchText.lowercased()) })
        }
        
        self.collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {
            self.currentResults = showFavs ? favPokes.favArray as [Any] : baseUrlArray as [Any]
            
            self.collectionView.reloadData()
            return
        }
        
        searchActive = true
        if showFavs {
            self.currentResults = favPokes.favArray.filter({ $0.name.contains(searchText.lowercased()) })
        }
        else {
            self.currentResults = baseUrlArray.filter({ $0.name.contains(searchText.lowercased()) })
        }
        
        self.collectionView.reloadData()
        
        self.searchController.dismiss(animated: true, completion: nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchText = ""
        self.currentResults = showFavs ? favPokes.favArray as [Any] : baseUrlArray as [Any]
        
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
        
        if showFavs {
            let fav: FavPokemonJson.FavJson = currentResults[indexPath.row] as! FavPokemonJson.FavJson
            let url = (pokeUrlArray?.urlArray.first(where: { $0.name == fav.name })!)!
            pCell.testConfig(pokeUrl: url, favTypes: fav.types)
        }
        else {
            pCell.testConfig(pokeUrl: self.currentResults[indexPath.row] as! PokemonArrayResult.PokemonUrl)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MainButtonCell
        
        if cvMarginValue == 0 {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController {
                vc.pokeUrl = cell.pokeUrl
                self.show(vc, sender: self)
            }
        }
        else {
            self.addSlotFunction(cell.pokeUrl!, cell.favTypes)
            
            self.navigationController?.popViewController(animated: true)
            //self.dismiss(animated: true, completion: {})
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
