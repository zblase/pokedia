//
//  TypeDM.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/20/21.
//

import Foundation
import UIKit


var typeDict: [String: TypeStruct] = [:]
var typeUrlArray: [TypeReference.TypeUrl] = []
var moveDict: [String: MoveData] = [:]

struct TypeStruct {
    let appearance: TypeAppearance
    let data: TypeData
    
    init(app: TypeAppearance, data: TypeData) {
        self.appearance = app
        self.data = data
    }
}

struct TypeData: Codable {
    let damage_relations: DamageRelation
    let pokemon: [TypePokemon]
    
    struct DamageRelation: Codable {
        let double_damage_from: [TypeReference.TypeUrl]
        let double_damage_to: [TypeReference.TypeUrl]
        let half_damage_from: [TypeReference.TypeUrl]
        let half_damage_to: [TypeReference.TypeUrl]
        let no_damage_from: [TypeReference.TypeUrl]
        let no_damage_to: [TypeReference.TypeUrl]
    }
    
    struct TypePokemon: Codable {
        let pokemon: PokemonArrayResult.PokemonUrl
    }
}

struct TypeReference: Codable {
    let slot: Int
    let type: TypeUrl
    
    struct TypeUrl: Codable {
        let name: String
        let url: String
    }
}

struct TypeArrayResult: Codable {
    let urlArray: [TypeReference.TypeUrl]
    
    enum CodingKeys: String, CodingKey {
        case urlArray = "results"
    }
}

struct TypeEffect: Codable {
    var name: String
    var value: Double
}

struct Move {
    let name: String
    let type: TypeStruct?
    var value: Double
    
    init(name: String = "", type: TypeStruct?, value: Double = 1.0) {
        self.name = name
        self.type = type
        self.value = value
    }
}

struct MoveArrayResult: Codable {
    let results: [TypeReference.TypeUrl]
    
    struct MoveUrl: Codable {
        let move: TypeReference.TypeUrl
    }
}

struct MoveData: Codable {
    let name: String
    let type: TypeReference.TypeUrl
}


class TypeDataController {
    
    var typeAppearanceDict: [String: TypeAppearance] = [:]
    var typeDataDict: [String: TypeData] = [:]
    var urlGroup = DispatchGroup()
    let typeGroup = DispatchGroup()
    var result: TypeArrayResult?
    var moveResult: MoveArrayResult?
    
    func printJson(_ data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            print(String(decoding: jsonData, as: UTF8.self))
        } else {
            print("json data malformed")
        }
    }
    
    func getAllTypeData(loadingVC: LoadingViewController, completion: @escaping (_ success: Bool) -> Void) {
        urlGroup = DispatchGroup()
        typeAppearanceDict = parseTypeAppearances()!
        fetchTypeUrls(loadingVC)
        //fetchMoveUrls(loadingVC)
        
        urlGroup.notify(queue: .main) {
            for url in self.result!.urlArray {
                self.fetchTypeData(url: url, loadingVC)
            }
            /*for url in self.moveResult!.results {
                self.fetchMoveData(url: url, loadingVC)
            }*/
            
            self.typeGroup.notify(queue: .main) {
                completion(true)
            }
        }
    }
    
    func parseTypeAppearances() -> [String: TypeAppearance]? {
        guard let path = Bundle.main.path(forResource: "TypeAttributes", ofType: "json") else {
            return nil
        }
        
        let url = URL(fileURLWithPath: path)
        
        var result: AppearanceJson?
        do {
            let jsonData = try Data(contentsOf: url)
            result = try JSONDecoder().decode(AppearanceJson.self, from: jsonData)
            
            if let result = result {
                return result.data.dict
            }
            else {
                print("error decoding type attributes")
            }
        }
        catch {
            print(error)
        }
        
        return nil
    }
    
    func fetchTypeUrls(_ loadingVC: LoadingViewController) {
        self.urlGroup.enter()
        URLSession.shared.dataTask(with: URL(string: "https://pokeapi.co/api/v2/type")!, completionHandler: {data, response, error in
            guard let data = data, error == nil else {
                print(error ?? "data != data")
                self.urlGroup.leave()
                loadingVC.showError(errorStr: error.debugDescription)
                return
            }
            
            do {
                self.result = try JSONDecoder().decode(TypeArrayResult.self, from: data)
                typeUrlArray = self.result!.urlArray
                //print("fetchTypeUrls")
                //self.printJson(data)
                self.urlGroup.leave()
            }
            catch {
                print(error)
                self.urlGroup.leave()
                loadingVC.showError(errorStr: error.localizedDescription)
            }
            
        }).resume()
    }

    func fetchTypeData(url: TypeReference.TypeUrl, _ loadingVC: LoadingViewController) {
        typeGroup.enter()
        
        URLSession.shared.dataTask(with: URL(string: url.url)!) { (data, urlResponse, err) in
            
            guard let data = data, err == nil else {
                self.typeGroup.leave()
                loadingVC.showError(errorStr: err.debugDescription)
                return
                
            }
            do {
                let tData = try JSONDecoder().decode(TypeData.self, from: data)
                
                typeDict[url.name] = TypeStruct(app: self.typeAppearanceDict[url.name]!, data: tData)
                
                //print("fetchTypeData")
                //self.printJson(data)
                
                self.typeGroup.leave()
            } catch let err {
                print("\(err) - ID: \(url)")
                self.typeGroup.leave()
                loadingVC.showError(errorStr: err.localizedDescription)
            }
        }.resume()
    }
    
    /*func fetchMoveUrls(_ loadingVC: LoadingViewController) {
        self.urlGroup.enter()
        URLSession.shared.dataTask(with: URL(string: "https://pokeapi.co/api/v2/move?limit=844")!, completionHandler: {data, response, error in
            guard let data = data, error == nil else {
                print("blah")
                self.urlGroup.leave()
                loadingVC.showError(errorStr: error.debugDescription)
                return
            }
            
            do {
                self.moveResult = try JSONDecoder().decode(MoveArrayResult.self, from: data)
                
                print("fetchMoveUrls")
                self.printJson(data)
                
                self.urlGroup.leave()
                
                
            }
            catch {
                print(error)
                self.urlGroup.leave()
                loadingVC.showError(errorStr: error.localizedDescription)
            }
            
        }).resume()
    }
    
    func fetchMoveData(url: TypeReference.TypeUrl, _ loadingVC: LoadingViewController) {
        typeGroup.enter()
        
        URLSession.shared.dataTask(with: URL(string: url.url)!) { (data, urlResponse, error) in
            
            guard let data = data, error == nil else {
                self.typeGroup.leave()
                loadingVC.showError(errorStr: error.debugDescription)
                return
                
            }
            do {
                let mData = try JSONDecoder().decode(MoveData.self, from: data)
                
                print("fetchMoveData")
                self.printJson(data)
                
                
                moveDict[url.name] = mData
                
                self.typeGroup.leave()
            } catch let err {
                print(err)
                self.typeGroup.leave()
                loadingVC.showError(errorStr: err.localizedDescription)
            }
        }.resume()
    }*/
    
}


struct TypeAppearance: Codable {
    let name: String
    let color: String?
    let namedColor: String?
    let image: String?
    let systemImage: String?
    let fontSize: Double?
    let top: Int?
    let left: Int?
    let bottom: Int?
    let right: Int?
    
    init(name: String = "", color: String? = nil, namedColor: String? = nil, image: String? = nil, systemImage: String? = nil, fontSize: Double? = nil, top: Int? = nil, left: Int? = nil, bottom: Int? = nil, right: Int? = nil) {
        self.name = name
        self.color = color
        self.namedColor = namedColor
        self.image = image
        self.systemImage = systemImage
        self.fontSize = fontSize
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
    
    func getColor() -> UIColor {
        let uiColor = color != nil ? getSystemColor(colorName: color!) : UIColor(named: namedColor!)
        return uiColor!
    }
    
    func getImage() -> UIImage {
        let uiImage = image != nil ? UIImage(named: image!) : UIImage(systemName: systemImage!)
        return uiImage!
    }
    
    func getInsets() -> UIEdgeInsets {
        let t = top != nil ? CGFloat(top!) : CGFloat(0)
        let l = left != nil ? CGFloat(left!) : CGFloat(0)
        let b = bottom != nil ? CGFloat(bottom!) : CGFloat(0)
        let r = right != nil ? CGFloat(right!) : CGFloat(0)
        return UIEdgeInsets(top: CGFloat(t), left: CGFloat(l), bottom: CGFloat(b), right: CGFloat(r))
    }
    
    func getSystemColor(colorName: String) -> UIColor {
        switch colorName {
        case "gray":
            return UIColor.gray
        case "systemOrange":
            return UIColor.systemOrange
        case "systemBlue":
            return UIColor.systemBlue
        case "systemGreen":
            return UIColor.systemGreen
        case "systemYellow":
            return UIColor.systemYellow
        case "systemTeal":
            return UIColor.systemTeal
        case "systemRed":
            return UIColor.systemRed
        case "systemPurple":
            return UIColor.systemPurple
        case "brown":
            return UIColor.brown
        case "systemIndigo":
            return UIColor.systemIndigo
        default:
            return UIColor.magenta
        }
    }
}

struct AppearanceJson: Codable {
    let data: AppearanceData
}
struct AppearanceData: Codable {
    let dict: [String: TypeAppearance]
}

func parseTypeAppearances() -> [String: TypeAppearance] {
    var typeAppearanceDict: [String: TypeAppearance] = [:]
    guard let path = Bundle.main.path(forResource: "TypeAttributes", ofType: "json") else {
        return typeAppearanceDict
    }
    
    let url = URL(fileURLWithPath: path)
    
    var result: AppearanceJson?
    do {
        let jsonData = try Data(contentsOf: url)
        result = try JSONDecoder().decode(AppearanceJson.self, from: jsonData)
        
        if let result = result {
            typeAppearanceDict = result.data.dict
        }
        else {
            print("error decoding type attributes")
        }
    }
    catch {
        print(error)
    }
    
    return typeAppearanceDict
}

