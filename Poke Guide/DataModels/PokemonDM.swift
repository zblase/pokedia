//
//  PokemonDM.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/20/21.
//

import Foundation
import UIKit


var pokeUrlArray: PokemonArrayResult?
var baseUrlArray: [PokemonArrayResult.PokemonUrl] = []
var pokemonDict: [String: Pokemon] = [:]
var pokemonArray: [Pokemon] = []
var favPokemon: FavPokemonJson?
var genArray: [Generation] = []
var genUrls: GenerationArrayResult!
var pokeImages: [String: UIImage] = [:]
var pokeImageArray: [PokeImage] = []

struct PokeImage {
    let id: String
    let image: UIImage
}

struct Pokemon {
    let data: PokemonData
    var image: UIImage?
    var moveTypes: [String] = []
    var favTypes: [String] = []
}

struct PokemonArrayResult: Codable {
    var urlArray: [PokemonUrl]
    
    enum CodingKeys: String, CodingKey {
        case urlArray = "results"
    }
    
    struct PokemonUrl: Codable {
        let name: String
        let url: String
        
        func getId() -> String {
            let trimmedUrl = String(self.url.dropLast())
            let startSuffix = trimmedUrl.index(trimmedUrl.lastIndex(of: "/")!, offsetBy: 1)
            return String(trimmedUrl[startSuffix...])
        }
        
        struct DisplayName {
            let name: String
            let subName: String
            
            init(name: String, sName: String = "Normal") {
                self.name = name
                self.subName = sName
            }
        }
        
        func getDisplayName() -> DisplayName {
            
            switch self.name {
            case "porygon-z":
                return DisplayName(name: "Porygon Z")
            case "ho-oh":
                return DisplayName(name: "Ho-Oh")
            case "mr-mime":
                return DisplayName(name: "Mr. Mime")
            case "nidoran-f":
                return DisplayName(name: "Nidoran (F)")
            case "nidoran-m":
                return DisplayName(name: "Nidoran (M)")
            case "pumpkaboo-average":
                return DisplayName(name: "Pumpkaboo", sName: "Average")
            case "zamazenta-hero":
                return DisplayName(name: "Zamazenta", sName: "Hero")
            case "zacian-hero":
                return DisplayName(name: "Zacian", sName: "Hero")
            default:
                let names = self.name.split(separator: "-")
                var subName = ""
                if names.count > 1 {
                    for i in 1...names.count - 1 {
                        subName += String(names[i]).capitalizingFirstLetter() + " "
                    }
                }
                
                return DisplayName(name: String(names[0]).capitalizingFirstLetter(), sName: subName == "" ? "Normal" : String(subName.dropLast()))
            }
        }
    }
}

struct PokeTypesResult: Codable {
    let results: [PokeTypesJSON]
}
struct PokeTypesJSON: Codable {
    let id: Int
    let types: [TypeJSON]
}
struct TypeJSON: Codable {
    let slot: Int
    let type: Int
}

struct PokemonData: Codable {
    let id: Int
    var name: String
    var order: Int
    let types: [TypeReference]
    let stats: [StatValue]
    let species: SpeciesUrl?
    let moves: [MoveUrlRef]
    
    init() {
        self.name = ""
        self.id = 0
        self.order = 0
        self.types = []
        self.stats = []
        self.species = nil
        self.moves = []
    }
    
    func getTypeStruct(slot: Int) -> TypeStruct {
        let typeRef = self.types.first(where: { $0.slot == slot })!
        return typeDict[typeRef.type.name]!
    }
    
    struct StatValue: Codable {
        let base_stat: Int
        let stat: StatName
        
        struct StatName: Codable {
            var name: String
        }
    }
    
    struct Sprites: Codable {
        var other: Other
        
        struct Other: Codable {
            var artwork: PokemonArtwork

            enum CodingKeys: String, CodingKey {
                case artwork = "official-artwork"
            }
            
            struct PokemonArtwork: Codable {
                let front_default: String
            }
        }
    }
    
    struct SpeciesUrl: Codable {
        let name: String
        let url: String
    }
    
    struct MoveUrlRef: Codable {
        let move: TypeReference.TypeUrl
    }
}

struct GenerationArrayResult: Codable {
    let results: [PokemonArrayResult.PokemonUrl]
}

struct Generation: Codable {
    let name: String
    let pokemon_species: [PokemonArrayResult.PokemonUrl]
    let main_region: Region
    
    struct Region: Codable {
        let name: String
    }
}

struct Species: Codable {
    let evolution_chain: EvUrl
    
    struct EvUrl: Codable {
        let url: String
    }
}

struct EvolutionChain: Codable {
    let chain: Chain
    
    struct Chain: Codable {
        let evolves_to: [Evolution]
        let species: Evolution.ChainSubSpecies
    }
}

struct Evolution: Codable {
    let species: ChainSubSpecies
    let evolves_to: [Evolution]
    
    struct ChainSubSpecies: Codable {
        let name: String
    }
}

struct PokemonEffectScore {
    let pokemon: Pokemon?
    let pokeUrl: PokemonArrayResult.PokemonUrl
    var types: [String]
    var score: Double = 0.0
    
    init(poke: Pokemon?, url: PokemonArrayResult.PokemonUrl, types: [String] = []) {
        self.pokemon = poke
        self.pokeUrl = url
        self.types = types
    }
}




class PokemonDataController {
    
    var mainGroup = DispatchGroup()
    let groupA = DispatchGroup()
    let groupB = DispatchGroup()
    let groupC = DispatchGroup()
    let groupD = DispatchGroup()
    
    var typeEffectDict: [String: Double] = [:]
    
    
    
    func getPokemonUrls(loadingVC: LoadingViewController) {
        mainGroup = DispatchGroup()
        
        fetchPokemonUrls(loadingVC)
        fetchGenUrls(loadingVC)
        
        mainGroup.notify(queue: .main) {
            for url in genUrls!.results {
                self.fetchGeneration(urlStr: url.url)
            }
            
            loadingVC.finishedLoading()
        }
    }
    
    func getAllImages() {
        let gA = DispatchGroup()
        let gB = DispatchGroup()
        let gC = DispatchGroup()
        let gD = DispatchGroup()
        
        for i in 0...20 {
            self.newGetImage(group: gA, id: pokeUrlArray!.urlArray[i].getId())
        }
        
        gA.notify(queue: .main) {
            for i in 21...60 {
                self.newGetImage(group: gB, id: pokeUrlArray!.urlArray[i].getId())
            }
            
            gB.notify(queue: .main) {
                for i in 61...200 {
                    self.newGetImage(group: gC, id: pokeUrlArray!.urlArray[i].getId())
                }
                
                gC.notify(queue: .main) {
                    for i in 201...pokeUrlArray!.urlArray.count - 1 {
                        self.newGetImage(group: gD, id: pokeUrlArray!.urlArray[i].getId())
                    }
                    
                    gD.notify(queue: .main) {
                        
                    }
                }
            }
        }
    }
    
    func newGetImage(group: DispatchGroup, id: String) {
        group.enter()
        let url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")!
        var image: UIImage?
        URLSession.shared.dataTask(with: url) { (data, urlResponse, err) in
            if let err = err { print("\(err) - ID: \(url)") }
            guard let data = data else {
                group.leave()
                return
            }
            
            image = UIImage(data: data)
            if image != nil {
                pokeImages[id] = image!
                pokeImageArray.append(PokeImage(id: id, image: image!))
            }
            
            group.leave()
        }.resume()
    }
    
    func getAllPokemonData(homeController: HomeCollectionViewController) {
        //fetchPokemonUrls()
        //fetchGenUrls()
        
        
        for url in genUrls!.results {
            self.fetchGeneration(urlStr: url.url)
        }
        
        for i in 0...20 {
            self.fetchPokemonData(group: self.groupA, url: pokeUrlArray!.urlArray[i].url, index: i)
        }
        
        self.groupA.notify(queue: .main) {
            pokemonArray.sort(by: { $0.data.id < $1.data.id })
            //homeController.updateResultsList()
            
            for i in 21...60 {
                self.fetchPokemonData(group: self.groupB, url: pokeUrlArray!.urlArray[i].url, index: i)
            }
            
            self.groupB.notify(queue: .main) {
                pokemonArray.sort(by: { $0.data.id < $1.data.id })
                //homeController.updateResultsList()
                
                for i in 61...200 {
                    self.fetchPokemonData(group: self.groupC, url: pokeUrlArray!.urlArray[i].url, index: i)
                }
                
                self.groupC.notify(queue: .main) {
                    pokemonArray.sort(by: { $0.data.id < $1.data.id })
                    //homeController.updateResultsList()
                    
                    for i in 201...pokeUrlArray!.urlArray.count - 1 {
                        self.fetchPokemonData(group: self.groupD, url: pokeUrlArray!.urlArray[i].url, index: i)
                    }
                    
                    self.groupD.notify(queue: .main) {
                        pokemonArray.sort(by: { $0.data.id < $1.data.id })
                        //self.getPokeTypes()
                        
                    }
                }
            }
        }
    }
    
    func getPokeTypes() {
        
        let dict: [String: Int] = ["normal": 1, "fire": 2, "water": 3, "grass": 4, "electric": 5, "ice": 6, "fighting": 7, "poison": 8, "ground": 9, "flying": 10, "psychic": 11, "bug": 12, "rock": 13, "ghost": 14, "dark": 15, "dragon": 16, "steel": 17, "fairy": 18]
        var test: [PokeTypesJSON] = []
        for poke in pokemonArray {
            var types: [TypeJSON] = []
            for type in poke.data.types {
                print(type.type.name)
                types.append(TypeJSON(slot: type.slot, type: dict[type.type.name]!))
            }
            test.append(PokeTypesJSON(id: poke.data.id, types: types))
        }
        
        do {
            let json = try JSONEncoder().encode(test)
            print(json.prettyPrintedJSONString!)
        }
        catch {
            
        }
    }
    
    func fetchPokemonUrls(_ loadingVC: LoadingViewController) {
        self.mainGroup.enter()
        URLSession.shared.dataTask(with: URL(string: "https://pokeapi.co/api/v2/pokemon?limit=1118")!, completionHandler: {data, response, error in
            guard let data = data, error == nil else {
                print(error!)
                loadingVC.showError(errorStr: error.debugDescription)
                return
            }
            
            do {
                
                
                pokeUrlArray = try JSONDecoder().decode(PokemonArrayResult.self, from: data)
                
                
                
                let blackList: [Int] = [10080, 10081, 10082, 10083, 10084, 10085, 10094, 10095, 10096, 10097, 10098, 10099, 10148, 10117,  10030, 10031, 10032, 10118, 10119, 10120, 10086, 10151, 10126, 10152, 10127, 772, 10155, 10156, 10157, 10178, 10179, 10183, 10184, 10185, 10218, 10219, 10220, 10022, 10023]
                
                //let blackList: [Int] = []
                
                let hyphNames: [String] = ["porygon-z", "ho-oh", "mr-mime", "nidoran-f", "nidoran-m", "pumpkaboo-average", "zamazenta-hero", "zacian-hero"]
                
                pokeUrlArray?.urlArray.removeAll(where: { $0.name.contains("-gmax") || $0.name.contains("-totem")})
                
                for id in blackList {
                    pokeUrlArray!.urlArray.removeAll(where: { $0.url == "https://pokeapi.co/api/v2/pokemon/\(id)/"})
                }
                
                baseUrlArray.append(contentsOf: pokeUrlArray!.urlArray.filter({ !$0.name.contains("-") || hyphNames.contains($0.name) }))
                
                self.mainGroup.leave()
            }
            catch {
                print(error)
                loadingVC.showError(errorStr: error.localizedDescription)
            }
            
        }).resume()
    }
    
    func fetchGenUrls(_ loadingVC: LoadingViewController) {
        self.mainGroup.enter()
        URLSession.shared.dataTask(with: URL(string: "https://pokeapi.co/api/v2/generation")!, completionHandler: {data, response, error in
            guard let data = data, error == nil else {
                print(error!)
                loadingVC.showError(errorStr: error.debugDescription)
                //self.mainGroup.leave()
                return
            }
            
            do {
                genUrls = try JSONDecoder().decode(GenerationArrayResult.self, from: data)
                self.mainGroup.leave()
            }
            catch {
                print(error)
                loadingVC.showError(errorStr: error.localizedDescription)
                //self.mainGroup.leave()
            }
            
        }).resume()
    }
    
    func fetchGeneration(urlStr: String) {
        self.groupA.enter()
        URLSession.shared.dataTask(with: URL(string: urlStr)!, completionHandler: {data, response, error in
            guard let data = data, error == nil else {
                print(error!)
                return
            }
            
            do {
                let gen = try JSONDecoder().decode(Generation.self, from: data)
                genArray.append(gen)
                self.groupA.leave()
            }
            catch {
                print(error)
            }
            
        }).resume()
    }
    
    func fetchPokemonData(group: DispatchGroup, url: String, index: Int) {
        group.enter()
        
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, urlResponse, err) in
            if let err = err {
                print("\(err) - ID: \(url)")
                group.leave()
            }
            guard let data = data else { return }
            do {
                let hyphNames: [String] = ["porygon-z", "ho-oh", "mr-mime", "nidoran-f", "nidoran-m", "pumpkaboo-average"]
                var pData = try JSONDecoder().decode(PokemonData.self, from: data)
                
                
                if hyphNames.contains(pData.name) {
                    pData.name = pData.name.replacingOccurrences(of: "-", with: "_")
                }
                else if pData.name == "pumpkaboo-average" {
                    pData.name = "pumpkaboo"
                }
                
                //pData.order = pData.order > 0 ? pData.order : pData.id
                self.fetchPokemonImage(group: group, pokeData: pData, index: index)
                
                group.leave()
            } catch let err {
                print("\(err) - ID: \(url)")
                group.leave()
            }
        }.resume()
    }
    
    func requestPokemonData(url: String, completion: @escaping (_ success: Bool) -> Void) {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, urlResponse, err) in
            if let err = err {
                print("\(err) - ID: \(url)")
            }
            guard let data = data else { return }
            do {
                let hyphNames: [String] = ["porygon-z", "ho-oh", "mr-mime", "nidoran-f", "nidoran-m", "pumpkaboo-average"]
                var pData = try JSONDecoder().decode(PokemonData.self, from: data)
                
                
                if hyphNames.contains(pData.name) {
                    pData.name = pData.name.replacingOccurrences(of: "-", with: "_")
                }
                else if pData.name == "pumpkaboo-average" {
                    pData.name = "pumpkaboo"
                }
                
                //let img = pokeImages[String(pData.id)]
                let poke = Pokemon(data: pData)
                pokemonDict[pData.name] = poke
                pokemonArray.append(poke)
                
                completion(true)
                
            } catch let err {
                print("\(err) - ID: \(url)")
            }
        }.resume()
    }
    
    func fetchPokemonImage(group: DispatchGroup, pokeData: PokemonData, index: Int) {
        group.enter()
        let url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokeData.id).png")!
        var image: UIImage?
        URLSession.shared.dataTask(with: url) { (data, urlResponse, err) in
            if let err = err { print("\(err) - ID: \(url)") }
            guard let data = data else {
                group.leave()
                return
            }
            
            image = UIImage(data: data)
            if image != nil {
                
                let moveTypes: [String] = ["normal", "fire", "water", "grass", "electric", "ice", "fighting", "poison", "ground", "flying", "psychic", "bug", "rock", "ghost", "dark", "dragon", "steel", "fairy"]
                /*for move in pokeData.moves {
                    let typeName = moveDict[move.move.name]!.type.name
                    if !moveTypes.contains(where: { $0 == typeName }) {
                        moveTypes.append(typeName)
                    }
                }*/
                
                //pokeData.order = pokeData.order > 0 ? pokeData.order : pokeData.id
                let poke = Pokemon(data: pokeData, image: image!, moveTypes: moveTypes)
                pokemonDict[pokeData.name] = poke
                pokemonArray.append(poke)
            }
            
            group.leave()
        }.resume()
    }
    
    func fetchPokemonSpecies(urlStr: String, evView: DetailEvolutionsSubView) {
        URLSession.shared.dataTask(with: URL(string: urlStr)!) { (data, urlResponse, err) in
            if let err = err {
                print(err)
            }
            guard let data = data else { return }
            do {
                let species = try JSONDecoder().decode(Species.self, from: data)
                print(species.evolution_chain.url)
                self.fetchEvolutionChain(urlStr: species.evolution_chain.url, evView: evView)
                
            } catch let err {
                print(err)
            }
            
        }.resume()
    }
    
    func fetchEvolutionChain(urlStr: String, evView: DetailEvolutionsSubView) {
        URLSession.shared.dataTask(with: URL(string: urlStr)!) { (data, urlResponse, err) in
            if let err = err {
                print(err)
            }
            guard let data = data else { return }
            do {
                let ev = try JSONDecoder().decode(EvolutionChain.self, from: data)
                
                DispatchQueue.main.async {
                    evView.configureData(ev: ev)
                }
                
            } catch let err {
                print(err)
            }
            
        }.resume()
    }
    
    func configureTypeEffects() {
        
    }
}

public class PokemonEffectsController {
    let pokemon: Pokemon!
    var typeEffectDict: [String: Double]!
    
    init(poke: Pokemon) {
        self.pokemon = poke
        self.typeEffectDict = [:]
        
        self.configureEffects()
    }
    
    func configureEffects() {
        for typeRef in pokemon!.data.types {
            let type = typeDict[typeRef.type.name]!
            
            for rel in type.data.damage_relations.double_damage_from {
                if typeEffectDict[rel.name] != nil {
                    typeEffectDict[rel.name]! += 1
                }
                else {
                    typeEffectDict[rel.name] = 1
                }
            }
            for rel in type.data.damage_relations.half_damage_from {
                if typeEffectDict[rel.name] != nil {
                    typeEffectDict[rel.name]! -= 1
                }
                else {
                    typeEffectDict[rel.name] = -1
                }
            }
            for rel in type.data.damage_relations.no_damage_from {
                if typeEffectDict[rel.name] != nil {
                    typeEffectDict[rel.name]! -= 2
                }
                else {
                    typeEffectDict[rel.name] = -2
                }
            }
        }
    }
    
    func getAll() -> SuggestedPokemon {
        var suggestedStrong: [PokemonEffectScore] = []
        var suggestedWeak: [PokemonEffectScore] = []
        
        for poke in pokeUrlArray!.urlArray {
            guard let tNames = pokeTypes.first(where: { String($0.id) == poke.getId() })?.types.map( { typeNames[$0.type-1] } ) else { continue }
            let pokeDictVal = pokemonDict[poke.name]
            var effScore = PokemonEffectScore(poke: pokeDictVal, url: poke, types: tNames)
            
            for typeRef in tNames {
                if let effect = typeEffectDict[typeRef], effect != 0 {
                    effScore.score += typeEffectDict[typeRef]!
                }
            }
            
            if !effScore.pokeUrl.name.contains("-mega") {
                if effScore.score < 0 {
                    suggestedStrong.append(effScore)
                }
                else if effScore.score > 0 {
                    suggestedWeak.append(effScore)
                }
            }
        }
        
        suggestedStrong.sort(by: { $0.score < $1.score })
        suggestedWeak.sort(by: { $0.score > $1.score })
        /*suggestedStrong.sort {
            ($0.score * -1, $0.pokemon.data.stats.first(where: { $0.stat.name == "attack" })!.base_stat) >
            ($1.score * -1, $1.pokemon.data.stats.first(where: { $0.stat.name == "attack" })!.base_stat)
        }
        
        suggestedWeak.sort {
            ($0.score, $0.pokemon.data.stats.first(where: { $0.stat.name == "attack" })!.base_stat) >
            ($1.score, $1.pokemon.data.stats.first(where: { $0.stat.name == "attack" })!.base_stat)
        }*/
        
        return SuggestedPokemon(strong: suggestedStrong, weak: suggestedWeak)
    }
    
    func getFavorites() -> SuggestedPokemon {
        var strongFavs: [PokemonEffectScore] = []
        var weakFavs: [PokemonEffectScore] = []
        let favPoke = FavoriteJsonParser().readJson()
        
        for poke in favPoke.favArray {
            let pUrl = pokeUrlArray?.urlArray.first(where: { $0.name == poke.name.lowercased() })
            guard let tNames = pokeTypes.first(where: { String($0.id) == pUrl!.getId() })?.types.map( { typeNames[$0.type-1] } ) else { continue }
            let pokeDictVal = pokemonDict[poke.name]
            var effScore = PokemonEffectScore(poke: pokeDictVal, url: (pokeUrlArray?.urlArray.first(where: { $0.name == poke.name }))!, types: tNames)
            effScore.types = poke.types
            
            for typeRef in tNames {
                if let effect = typeEffectDict[typeRef], effect != 0 {
                    effScore.score += typeEffectDict[typeRef]!
                }
            }
            
            if effScore.score < 0 {
                strongFavs.append(effScore)
            }
            else if effScore.score > 0 {
                weakFavs.append(effScore)
            }
        }
        
        strongFavs.sort(by: { $0.score < $1.score })
        weakFavs.sort(by: { $0.score > $1.score })
        /*strongFavs.sort {
            ($0.score * -1, $0.pokemon.data.stats.first(where: { $0.stat.name == "attack" })!.base_stat) >
            ($1.score * -1, $1.pokemon.data.stats.first(where: { $0.stat.name == "attack" })!.base_stat)
        }
        
        weakFavs.sort {
            ($0.score, $0.pokemon.data.stats.first(where: { $0.stat.name == "attack" })!.base_stat) >
            ($1.score, $1.pokemon.data.stats.first(where: { $0.stat.name == "attack" })!.base_stat)
        }*/
        
        return SuggestedPokemon(strong: strongFavs, weak: weakFavs)
    }
    
    func getEffects() -> [TypeEffect] {
        var fromArray: [TypeEffect] = []
        
        for url in typeUrlArray {
            if let effect = typeEffectDict[url.name], effect != 0 {
                var val: Double
                switch effect {
                case 2:
                    val = 400
                case 1:
                    val = 200
                case -1:
                    val = 75
                case -2:
                    val = 50
                case -3:
                    val = 25
                case -4:
                    val = 0
                default:
                    val = 100
                }
                fromArray.append(TypeEffect(name: url.name, value: val))
            }
        }
        
        return fromArray
    }
    
    public struct SuggestedPokemon {
        let strongPokemon: [PokemonEffectScore]!
        let weakPokemon: [PokemonEffectScore]!
        
        init(strong: [PokemonEffectScore], weak: [PokemonEffectScore]) {
            self.strongPokemon = strong
            self.weakPokemon = weak
        }
    }
}



struct FavPokemonJson: Encodable, Decodable {
    var favArray: [FavJson]
    
    struct FavJson: Encodable, Decodable, Equatable {
        let name: String
        var types: [String]
    }
}

class FavoriteJsonParser {
    
    
    func addFavorite(fav: FavPokemonJson.FavJson) {
        var favJson = readJson()
        favJson.favArray.append(fav)
        favPokemon = favJson
        writeJson(favData: favJson)
    }
    
    func removeFavorite(fav: FavPokemonJson.FavJson) {
        var favJson = readJson()
        favJson.favArray.removeAll(where: { $0 == fav })
        favPokemon = favJson
        writeJson(favData: favJson)
    }
    
    func readJson() -> FavPokemonJson {
        var favJson = FavPokemonJson(favArray: [])
        let fileManager = FileManager.default

        guard let docDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return favJson }

        let inputFileURL = docDirectoryURL.appendingPathComponent("favPokemon")

        guard fileManager.fileExists(atPath: inputFileURL.path)
        else {
            print("File Doesn't exist. Try typing a name and hitting 'Save' First.")
            return favJson
        }

        do {
            print("Attempting to read from \("favPokemon")")
            print("Reading from file at path \(inputFileURL.deletingLastPathComponent().path)")
            let inputData = try Data(contentsOf: inputFileURL)
            let decoder = JSONDecoder()
            favJson = try decoder.decode(FavPokemonJson.self, from: inputData)
            
            for var poke in favJson.favArray {
                poke.types = poke.types.compactMap({ $0.lowercased() })
            }
            
            favPokemon = favJson
        } catch {
            print("Failed to open file contents for display!")
        }
        
        return favJson
    }
    
    func writeJson(favData: FavPokemonJson) {
        guard let docDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                else { return }

        // Build final output URL.
        let outputURL = docDirectoryURL.appendingPathComponent("favPokemon")

        do {
            // Encoder, to encode our data.
            let jsonEncoder = JSONEncoder()

            // Convert our Object into a Data object.
            let jsonCodedData = try jsonEncoder.encode(favData)

            // Write the data to output.
            try jsonCodedData.write(to: outputURL)
        } catch {
            // Error Handling.
            print("Failed to write to file \(error.localizedDescription)")
            return
        }
    }
}

class CheatSheetJsonParser {
    
    
    func addSlot(fav: FavPokemonJson.FavJson) {
        var favJson = readJson()
        favJson.favArray.append(fav)
        //favPokemon = favJson
        writeJson(cheatSheetData: favJson)
    }
    
    func removeSlot(fav: FavPokemonJson.FavJson) {
        var favJson = readJson()
        favJson.favArray.removeAll(where: { $0 == fav })
        //favPokemon = favJson
        writeJson(cheatSheetData: favJson)
    }
    
    func readJson() -> FavPokemonJson {
        var favJson = FavPokemonJson(favArray: [])
        let fileManager = FileManager.default

        guard let docDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return favJson }

        let inputFileURL = docDirectoryURL.appendingPathComponent("cheatSheetPokemon")

        guard fileManager.fileExists(atPath: inputFileURL.path)
        else {
            print("File Doesn't exist. Try typing a name and hitting 'Save' First.")
            return favJson
        }

        do {
            print("Attempting to read from \("cheatSheetPokemon")")
            print("Reading from file at path \(inputFileURL.deletingLastPathComponent().path)")
            let inputData = try Data(contentsOf: inputFileURL)
            let decoder = JSONDecoder()
            favJson = try decoder.decode(FavPokemonJson.self, from: inputData)
            
            for var poke in favJson.favArray {
                poke.types = poke.types.compactMap({ $0.lowercased() })
            }
            
            //favPokemon = favJson
        } catch {
            print("Failed to open file contents for display!")
        }
        
        return favJson
    }
    
    func writeJson(cheatSheetData: FavPokemonJson) {
        guard let docDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                else { return }

        // Build final output URL.
        let outputURL = docDirectoryURL.appendingPathComponent("cheatSheetPokemon")

        do {
            // Encoder, to encode our data.
            let jsonEncoder = JSONEncoder()

            // Convert our Object into a Data object.
            let jsonCodedData = try jsonEncoder.encode(cheatSheetData)

            // Write the data to output.
            try jsonCodedData.write(to: outputURL)
        } catch {
            // Error Handling.
            print("Failed to write to file \(error.localizedDescription)")
            return
        }
    }
}


extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}

extension Int {
    static func parse(from string: String) -> Int? {
        return Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}
