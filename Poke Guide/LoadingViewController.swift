//
//  LoadingViewController.swift
//  Poke Guide
//
//  Created by Zack Blase on 10/30/21.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet var activityView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityView.startAnimating()
        
        
        
        loadData()
    }
    
    func loadData() {
        
        let typeDC = TypeDataController()
        typeDC.getAllTypeData(loadingVC: self, completion: {(success) -> Void in
            if success {
                let pokeDC = PokemonDataController()
                pokeDC.getPokemonUrls(loadingVC: self)
            }
        })
    }
    
    func showError(errorStr: String) {
        let alert = UIAlertController(title: "Error loading data", message: errorStr, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { action in
            self.loadData()
        }))

        self.present(alert, animated: true)
    }
    
    func finishedLoading() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeCollectionViewController") {
            self.show(vc, sender: self)
        }
    }

}
