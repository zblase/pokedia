//
//  PokemonDM.swift
//  Poke Guide
//
//  Created by Zack Blase on 9/20/21.
//

import Foundation
import UIKit


var pokeUrlArray: PokemonArrayResult?
var pokemonDict: [String: Pokemon] = [:]
var pokemonArray: [Pokemon] = []
var favPokemon: FavPokemonJson?
var genArray: [Generation] = []

struct Pokemon {
    let data: PokemonData
    let image: UIImage
    let moveTypes: [String]
}

struct PokemonArrayResult: Codable {
    var urlArray: [PokemonUrl]
    
    enum CodingKeys: String, CodingKey {
        case urlArray = "results"
    }
    
    struct PokemonUrl: Codable {
        let name: String
        let url: String
    }
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
    let pokemon: Pokemon
    var score: Double = 0.0
    
    init(poke: Pokemon) {
        self.pokemon = poke
    }
}




class PokemonDataController {
    
    let mainGroup = DispatchGroup()
    let groupA = DispatchGroup()
    let groupB = DispatchGroup()
    let groupC = DispatchGroup()
    let groupD = DispatchGroup()
    
    var genUrls: GenerationArrayResult?
    
    func getAllPokemonData(homeController: HomeCollectionViewController, completion: @escaping(_ success: Bool) -> Void) {
        fetchPokemonUrls()
        fetchGenUrls()
        
        mainGroup.notify(queue: .main) {
            homeController.collectionView.dataSource = homeController.self
            homeController.collectionView.delegate = homeController.self
            homeController.updateResultsList()
            
            for url in self.genUrls!.results {
                self.fetchGeneration(urlStr: url.url)
            }
            
            for i in 0...20 {
                self.fetchPokemonData(group: self.groupA, url: pokeUrlArray!.urlArray[i].url, index: i)
            }
            
            self.groupA.notify(queue: .main) {
                pokemonArray.sort(by: { $0.data.id < $1.data.id })
                homeController.updateResultsList()
                
                for i in 21...60 {
                    self.fetchPokemonData(group: self.groupB, url: pokeUrlArray!.urlArray[i].url, index: i)
                }
                
                self.groupB.notify(queue: .main) {
                    pokemonArray.sort(by: { $0.data.id < $1.data.id })
                    homeController.updateResultsList()
                    
                    for i in 61...200 {
                        self.fetchPokemonData(group: self.groupC, url: pokeUrlArray!.urlArray[i].url, index: i)
                    }
                    
                    self.groupC.notify(queue: .main) {
                        pokemonArray.sort(by: { $0.data.id < $1.data.id })
                        homeController.updateResultsList()
                        
                        for i in 201...pokeUrlArray!.urlArray.count - 1 {
                            self.fetchPokemonData(group: self.groupD, url: pokeUrlArray!.urlArray[i].url, index: i)
                        }
                        
                        self.groupD.notify(queue: .main) {
                            pokemonArray.sort(by: { $0.data.id < $1.data.id })
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    func fetchPokemonUrls() {
        self.mainGroup.enter()
        URLSession.shared.dataTask(with: URL(string: "https://pokeapi.co/api/v2/pokemon?limit=1118")!, completionHandler: {data, response, error in
            guard let data = data, error == nil else {
                print(error!)
                return
            }
            
            do {
                pokeUrlArray = try JSONDecoder().decode(PokemonArrayResult.self, from: data)
                
                let blackList: [Int] = [10080, 10081, 10082, 10083, 10084, 10094, 10095, 10096, 10097, 10098, 10099, 10148, 10117,  10030, 10031, 10032, 10118, 10119, 10120, 10086, 10151, 10126, 10152, 10127, 772, 10155, 10156, 10157, 10178, 10179, 10183, 10184, 10185, 10218, 10219, 10220, 10022, 10023]
                
                pokeUrlArray?.urlArray.removeAll(where: { $0.name.contains("-gmax") || $0.name.contains("-totem")})
                
                for id in blackList {
                    pokeUrlArray!.urlArray.removeAll(where: { $0.url == "https://pokeapi.co/api/v2/pokemon/\(id)/"})
                }
                
                self.mainGroup.leave()
            }
            catch {
                print(error)
            }
            
        }).resume()
    }
    
    func fetchGenUrls() {
        self.mainGroup.enter()
        URLSession.shared.dataTask(with: URL(string: "https://pokeapi.co/api/v2/generation")!, completionHandler: {data, response, error in
            guard let data = data, error == nil else {
                print(error!)
                self.mainGroup.leave()
                return
            }
            
            do {
                self.genUrls = try JSONDecoder().decode(GenerationArrayResult.self, from: data)
                self.mainGroup.leave()
            }
            catch {
                print(error)
                self.mainGroup.leave()
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
                let pData = try JSONDecoder().decode(PokemonData.self, from: data)
                //pData.order = pData.order > 0 ? pData.order : pData.id
                self.fetchPokemonImage(group: group, pokeData: pData, index: index)
                
                group.leave()
            } catch let err {
                print("\(err) - ID: \(url)")
                group.leave()
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
                
                var moveTypes: [String] = []
                for move in pokeData.moves {
                    let typeName = moveDict[move.move.name]!.type.name
                    if !moveTypes.contains(where: { $0 == typeName }) {
                        moveTypes.append(typeName)
                    }
                }
                
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
}



struct FavPokemonJson: Encodable, Decodable {
    var favArray: [FavJson]
    
    struct FavJson: Encodable, Decodable, Equatable {
        let name: String
        let types: [String]
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

let blackList: [Int] = []


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
