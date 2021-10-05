//
//  TestViewController.swift
//  Poke Guide
//
//  Created by Zack Blase on 8/10/21.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet var chevron: UIImageView!
    @IBOutlet var yellowView: UIView!
    @IBOutlet var greenView: UIView!
    
    @IBOutlet var img: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var num: UILabel!
    
    var deg: CGFloat = .pi
    override func viewDidLoad() {
        super.viewDidLoad()

        yellowView.isHidden = true
        img.image = UIImage(named: "charmeleon copy")
        name.text = "Charmeleon"
        num.text = "#5"
    }
    
    @IBAction func toggleView(sender: Any?) {
        /*greenView.isHidden = !greenView.isHidden
        if greenView.isHidden {
            chevron.image = UIImage( systemName: "chevron.down")
        }
        else {
            chevron.image = UIImage( systemName: "chevron.up")
        }*/
        yellowView.isHidden = !yellowView.isHidden
        
        UIView.animate(withDuration: 0.25, animations: {
            self.chevron.transform = CGAffineTransform(rotationAngle: self.deg)
        })
        
        if self.deg == .pi {
            self.deg = 0
        }
        else {
            self.deg = .pi
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
