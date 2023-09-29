//
//  AsteroidsViewModel.swift
//  Astropedia
//
//  Created by Yves Charpentier on 20/09/2023.
//

import Foundation
import Combine

class AsteroidsViewModel: NSObject {
    
    private let asteroidService = AsteroidService()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    @Published var asteroid: [APIAsteroid] = []
    @Published var updateNumberAsteroid: Int?
    @Published var sortButtonSelected: Bool?
    @Published var isLoading: Bool?
    
    override init() {
        super.init()
        Task {
            await fetchData(startDate: formatDate(date: Date()), endDate: formatDate(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!))
        }
    }
    
    func formatDate(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func fetchData(startDate: String, endDate: String) async -> Result<[APIAsteroid], Error> {
        isLoading = true
        do {
            let asteroids = try await asteroidService.getValue(startDate: startDate, endDate: endDate).nearEarthObjects.flatMap { $0.value }
            sortButtonSelected = false
            self.asteroid = asteroids.sorted { ($0.toAsteroid().estimatedDiameter ?? 0) > ($1.toAsteroid().estimatedDiameter ?? 0) }
            self.updateNumberAsteroid = asteroids.count
            //            spinner.stopAnimating()
            isLoading = false
            return .success(asteroids)
        } catch ResultError.invalidUrl {
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
