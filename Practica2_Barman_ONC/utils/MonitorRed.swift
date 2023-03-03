//
//  MonitorRed.swift
//  Practica2_Barman_ONC
//
//  Created by Omar Nieto on 03/03/23.
//

import Foundation
import Network


class MonitorRed : NSObject {
    
    enum TipoInterface {
        case Wifi, Celular, Otro, Ninguno
    }
    
    var tipoInterface : TipoInterface = .Ninguno
    var conexionActiva : Bool = false
    
    
    //--------------------------------
    static let monitor = NWPathMonitor()
    static let instance = MonitorRed()
    
    override private init() {
        super.init()
        iniciarMonitoreo()
    }
    
    
    func iniciarMonitoreo(){
        
        //Se establece el closure para la detección de la red
        MonitorRed.monitor.pathUpdateHandler = { path in
            //Se verifica si hay conexión
            if path.status == .satisfied {
                
                self.conexionActiva = true
                
                if path.usesInterfaceType(.wifi) {
                    self.tipoInterface = .Wifi
                }
                else if path.usesInterfaceType(.cellular) {
                    self.tipoInterface = .Celular
                }
                else {
                    self.tipoInterface = .Otro
                }
            }
            else { //No hay conexión
                self.tipoInterface = .Ninguno
                self.conexionActiva = false
            }
            
        }
        //Iniciar el monitoreo
        MonitorRed.monitor.start(queue: DispatchQueue.global())
        
    }
    
}
