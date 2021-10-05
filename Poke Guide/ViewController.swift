//
//  ViewController.swift
//  Poke Guide
//
//  Created by Zack Blase on 8/5/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var test: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //test.menu = addMenuItem()
        //test.showsMenuAsPrimaryAction = true
    }

    @IBAction func didTapButton() {
        let vc = UIViewController()
        vc.view.backgroundColor = .yellow
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func addMenuItem() -> UIMenu {
        let menuItems = UIMenu(title: "", options: .destructive, children: [
                                UIAction(title: "Water", image: UIImage(systemName: "drop.fill"), handler: { (_) in
                                    
                                })
        ])
        
        return menuItems
    }
}

