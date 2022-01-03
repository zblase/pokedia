//
//  CheatSheetViewController.swift
//  Poke Guide
//
//  Created by Zack Blase on 12/22/21.
//

import UIKit

class CheatSheetViewController: UIViewController {
    
    @IBOutlet var viewA: CheatSheetSlotView!
    @IBOutlet var viewB: CheatSheetSlotView!
    @IBOutlet var viewC: CheatSheetSlotView!
    
    var slotArray: [CheatSheetSlotView] = []
    var strongEffects: [TypeEffect] = []
    var weakEffects: [TypeEffect] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slotArray = [viewA, viewB, viewC]
        for i in 0...2 {
            slotArray[i].configure(csController: self, index: i)
        }
        
        self.refreshCheatSheet()
    }
    
    @IBAction func showAddListView(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeController") as! HomeCollectionViewController
        vc.title = "Add to Cheat Sheet"
        vc.addSlotFunction = self.addNewPokemon(pokeUrl: favTypes:)
        vc.cvMarginValue = 36
        self.show(vc, sender: self)
    }
    
    func addNewPokemon(pokeUrl: PokemonArrayResult.PokemonUrl, favTypes: [String]?) {
        let csParser = CheatSheetJsonParser()
        let types = (favTypes == nil ? [] : favTypes)!
        let poke = FavPokemonJson.FavJson(name: pokeUrl.name, types: types)
        csParser.addSlot(fav: poke)
        
        self.refreshCheatSheet()
    }
    
    func refreshCheatSheet() {
        let cheatSheetParser = CheatSheetJsonParser()
        let pokeArray = cheatSheetParser.readJson().favArray
        
        for i in 0...2 {
            if pokeArray.count > i {
                var types: [String]? = pokeArray[i].types
                if types?.count == 0 {
                    types = nil
                }
                
                self.slotArray[i].tryGetPokemon(pokeUrl: pokeUrlArray!.urlArray.first(where: { $0.name == pokeArray[i].name })!, favTypes: types)
            }
            else {
                self.slotArray[i].viewWithTag(2)!.isHidden = true
            }
        }
    }
    
    
    @IBAction func clearSlot(_ sender: Any) {
        let closeBtn = sender as! UIButton
        
        let slotView = closeBtn.superview!.superview!.superview! as! CheatSheetSlotView
        
        let csParser = CheatSheetJsonParser()
        let slotPokes = csParser.readJson()
        csParser.removeSlot(fav: slotPokes.favArray[slotView.index])
        
        self.refreshCheatSheet()
    }
}
