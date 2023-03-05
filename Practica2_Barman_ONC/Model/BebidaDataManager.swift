//
//  BebidaDataManager.swift
//  Practica2_Barman_ONC
//
//  Created by Omar Nieto on 03/03/23.
//

import Foundation
import CoreData

class BebidasDataManager {
    
    private var bebidas : [Bebida] = []
    private var context : NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetch() {
        do {
            self.bebidas = try self.context.fetch(Bebida.fetchRequest())
        }
        catch {
            print("ERROR: No se ha podido leer la base de datos")
        }
    }
    
    
    
    func getBebida(at index: Int) -> Bebida {
        
        return bebidas[index]
    }
    
    func setBebida(bebida: Bebida, at index: Int)
    {
        bebidas[index] = bebida
        saveData()
        fetchData()
    }
    
    
    func countBebidas() -> Int {
        return bebidas.count
    }
    
    
    
    func deleteBebida(at indice: Int) {
        deleteBebida(bebida: bebidas[indice])
    }
    
    
    
    func deleteBebida(bebida: Bebida) {
        context.delete(bebida)
        saveData()
        fetchData()
    }
    
    
    
    func fetchData()
    {
        do{
            self.bebidas = try self.context.fetch(Bebida.fetchRequest())
        }
        catch{
            print("ERROR: No se puede acceder a la base de datos de bebidas: ", error.localizedDescription)
        }
    }
    
    
    func saveData()
    {
        do{
            try self.context.save()
        }
        catch{
            print("ERROR: No se puede acceder a salvar la base de datos de bebidas: ", error.localizedDescription)
        }
    }
}
