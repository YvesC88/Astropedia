//
//  APIAsteroid.swift
//  Planets
//
//  Created by Yves Charpentier on 31/03/2023.
//

import Foundation

struct ResultAsteroid: Codable {
    let links: WelcomeLinks
    let elementCount: Int
    let nearEarthObjects: [String: [APIAsteroid]]
    
    enum CodingKeys: String, CodingKey {
        case links
        case elementCount = "element_count"
        case nearEarthObjects = "near_earth_objects"
    }
}

struct WelcomeLinks: Codable {
    let next, previous, linksSelf: String
    
    enum CodingKeys: String, CodingKey {
        case next, previous
        case linksSelf = "self"
    }
}

struct APIAsteroid: Codable {
    let links: NearEarthObjectLinks
    let id, neoReferenceID, name: String
    let nasaJplURL: String
    let absoluteMagnitudeH: Double
    let estimatedDiameter: EstimatedDiameter
    let isPotentiallyHazardousAsteroid: Bool
    let closeApproachData: [CloseApproachDatum]
    let isSentryObject: Bool
    
    enum CodingKeys: String, CodingKey {
        case links, id
        case neoReferenceID = "neo_reference_id"
        case name
        case nasaJplURL = "nasa_jpl_url"
        case absoluteMagnitudeH = "absolute_magnitude_h"
        case estimatedDiameter = "estimated_diameter"
        case isPotentiallyHazardousAsteroid = "is_potentially_hazardous_asteroid"
        case closeApproachData = "close_approach_data"
        case isSentryObject = "is_sentry_object"
    }
}

struct CloseApproachDatum: Codable {
    let closeApproachDate, closeApproachDateFull: String
    let epochDateCloseApproach: Int
    var relativeVelocity: RelativeVelocity
    let missDistance: MissDistance
    let orbitingBody: String
    
    enum CodingKeys: String, CodingKey {
        case closeApproachDate = "close_approach_date"
        case closeApproachDateFull = "close_approach_date_full"
        case epochDateCloseApproach = "epoch_date_close_approach"
        case relativeVelocity = "relative_velocity"
        case missDistance = "miss_distance"
        case orbitingBody = "orbiting_body"
    }
}

struct MissDistance: Codable {
    let astronomical, lunar, kilometers, miles: String
}

struct RelativeVelocity: Codable {
    var kilometersPerSecond, kilometersPerHour, milesPerHour: String
    
    enum CodingKeys: String, CodingKey {
        case kilometersPerSecond = "kilometers_per_second"
        case kilometersPerHour = "kilometers_per_hour"
        case milesPerHour = "miles_per_hour"
    }
}

struct EstimatedDiameter: Codable {
    let kilometers, meters, miles, feet: Feet
}

struct Feet: Codable {
    let estimatedDiameterMin, estimatedDiameterMax: Double
    
    enum CodingKeys: String, CodingKey {
        case estimatedDiameterMin = "estimated_diameter_min"
        case estimatedDiameterMax = "estimated_diameter_max"
    }
}

struct NearEarthObjectLinks: Codable {
    let linksSelf: String
    
    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
    }
}

extension APIAsteroid {
    
    func toAsteroid() -> Asteroid {
        let dateFormatter = DateFormatter()
        
        let formatName = self.name.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        let estimatedDiameter = (self.estimatedDiameter.meters.estimatedDiameterMin + self.estimatedDiameter.meters.estimatedDiameterMax) / 2.0.rounded()
        
        let potentiallyHazardous: String
        if self.isPotentiallyHazardousAsteroid == true {
            potentiallyHazardous = "Potentiellement dangereux"
        } else {
            potentiallyHazardous = "Pas dangereux"
        }
        
        var approachDate: String = ""
        for closeApproachDate in self.closeApproachData {
            approachDate += closeApproachDate.closeApproachDateFull
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = Locale(identifier: "us_US")
        let date = dateFormatter.date(from: approachDate)
        dateFormatter.dateFormat = "d MMMM yyyy 'à' HH:mm"
        dateFormatter.locale = Locale(identifier: "fr_FR")
        let finalDate = dateFormatter.string(from: date ?? Date())
        
        var relativeVelocity: String = ""
        for velocity in self.closeApproachData {
            relativeVelocity += velocity.relativeVelocity.kilometersPerSecond
        }
        var relativeVelocityRounded = Double(relativeVelocity)
        relativeVelocityRounded = round(relativeVelocityRounded ?? 0.0 * 10) / 10
        
        var distance: String = ""
        for missDistance in self.closeApproachData {
            distance += missDistance.missDistance.lunar
        }
        var distanceDouble = Double(distance)
        distanceDouble = round(distanceDouble ?? 0.0)
        
        let url = URL(string: self.nasaJplURL)
        
        return Asteroid(name: formatName,
                        estimatedDiameter: estimatedDiameter,
                        isPotentiallyHazardous: potentiallyHazardous,
                        url: url,
                        relativeVelocity: relativeVelocityRounded,
                        missDistance: Double(distance),
                        closeApproachDate: finalDate,
                        absoluteMagnitude: self.absoluteMagnitudeH)
    }
}
