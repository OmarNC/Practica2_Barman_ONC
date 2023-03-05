//
//  Bebida+CoreDataProperties.swift
//  Practica2_Barman_ONC
//
//  Created by Omar Nieto on 04/03/23.
//
//

import Foundation
import CoreData


extension Bebida {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bebida> {
        return NSFetchRequest<Bebida>(entityName: "Bebida")
    }

    @NSManaged public var img: String?
    @NSManaged public var directions: String?
    @NSManaged public var ingredients: String?
    @NSManaged public var name: String?

}

extension Bebida : Identifiable {

}
