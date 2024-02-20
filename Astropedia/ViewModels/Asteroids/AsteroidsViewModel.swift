//
//  AsteroidsViewModel.swift
//  Astropedia
//
//  Created by Yves Charpentier on 20/09/2023.
//

import Foundation
import Combine

final class AsteroidsViewModel {

    private let asteroidService = AsteroidService()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    @Published private(set) var asteroid: [APIAsteroid] = []
    @Published private(set) var updateNumberAsteroid: Int?
    @Published private(set) var sortButtonSelected: Bool?
    @Published private(set) var isLoading: Bool?

    init() {
        Task {
            // La ligne est complique a lire. Pourquoi ne pas la decomposer ?
//            await fetchData(startDate: formatDate(date: Date()), endDate: formatDate(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!))

            // Suggestion :
            let nowDate = Date()
            let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: nowDate) ?? nowDate

            let startDateString = formatDate(date: nowDate)
            let endDateString = formatDate(date: tomorrowDate)

            return await fetchData(startDate: startDateString, endDate: endDateString)
            // C'est + long mais on comprend plus facilement ce que tu veux faire
        }
    }
    
    func formatDate(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    // Le naming des parameters n'est pas bon. startDate --> on s'attend a une date pas une string. Appelons un chat un chat. Une String n'est pas une date ;)
    func fetchData(startDate: String, endDate: String) async -> Result<[APIAsteroid], Error> {
        isLoading = true
        do {
            let asteroids = try await asteroidService.getValue(startDate: startDate, endDate: endDate).nearEarthObjects.flatMap { $0.value }
            sortButtonSelected = false
            // Idem ici decompose.. A relire on se prend tres vite la tete
            // Ca ne sert a rien de vouloir gagner des lignes et mettre plusieurs calculs dans une meme lignes
            self.asteroid = asteroids.sorted { ($0.toAsteroid().estimatedDiameter ?? 0) > ($1.toAsteroid().estimatedDiameter ?? 0) }
            self.updateNumberAsteroid = asteroids.count
            //            spinner.stopAnimating()
            isLoading = false
            return .success(asteroids)
        } catch ResultError.invalidUrl {
            // Pas de code mort si possible
            //            presentAlert(title: "Erreur", message: "L'url n'est pas correcte.")
            return .failure(ResultError.invalidUrl)
        } catch ResultError.invalidResponse {
            //            presentAlert(title: "Erreur", message: "Aucune réponse du serveur.")
            return .failure(ResultError.invalidResponse)
        } catch ResultError.invalidResult {
            //            presentAlert(title: "Erreur", message: "Aucun résultat.")
            return .failure(ResultError.invalidResult)
        } catch {
            return .failure(error)
        }
    }
}
