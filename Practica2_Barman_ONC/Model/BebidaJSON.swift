//
//  Bebida.swift
//  Practica2_Barman_ONC
//
//  Created by Omar Nieto on 02/03/23.
//

import Foundation

struct BebidaJSON: Codable {
    let directions : String
    let ingredients : String
    let name : String
    let img: String
}

typealias BebidasJSON = [BebidaJSON]
