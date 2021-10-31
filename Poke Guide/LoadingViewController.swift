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
        
        
        
        let typeDC = TypeDataController()
        typeDC.getAllTypeData{ (success) -> Void in
            if success {
                let pokeDC = PokemonDataController()
                pokeDC.getPokemonUrls(loadingVC: self)
            }
        }
    }
    
    func finishedLoading() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeCollectionViewController") {
            self.show(vc, sender: self)
        }
    }

}
