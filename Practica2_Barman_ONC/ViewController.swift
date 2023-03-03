//
//  ViewController.swift
//  Practica2_Barman_ONC
//
//  Created by Omar Nieto on 01/03/23.
//

import UIKit
import Network

class ViewController: UIViewController {
    
    //Objeto mostrado
    var bebida : Bebida? = nil
    
    //Monitoreo de la red
    let monitorRed = NWPathMonitor()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Se establece el Completion Handler al monitor
        monitorRed.pathUpdateHandler = { path in
            var mensaje = ""
            
            if path.status == .satisfied { //Hay conexión a Internet
                if path.usesInterfaceType(.cellular) { //Usa la interface de conexión a la red celular
                    mensaje = "Su conexión a Internet se está realizando mediante la red celular"
                }
                else if path.usesInterfaceType(.wifi) { //Usa la interface de conexión a la red WiFi
                    mensaje = "Su conexión a Internet se está realizando mediante la red WiFi"
                }
                else {
                    mensaje = "Su conexión a Internet se está realizando con una interface diferente a la celular y WiFi"
                }
            }
            else { //No hay conexión a Internet
                mensaje = "No hay conexión a Internet"
            }
            
            // Manda un mensaje al usuario para indicarle el tipo
            // de Interface usada en la conexión a Internet
            let alertController = UIAlertController(title: "Conexión a Internet", message: mensaje, preferredStyle: .alert)
            let accionOk = UIAlertAction(title: "Ok", style:
                    .default)
            
            alertController.addAction(accionOk)
            
            //Se debe ejecutar la visualización de la alerta
            //En la cola de tareas principal
            
            DispatchQueue.main.async {
                self.present(alertController, animated: true)
            }
        }
        
        // Comienza el monitoreo en la cola de tareas global
        monitorRed.start(queue: DispatchQueue.global())
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Detiene el monitoreo de la red
        monitorRed.cancel()
        
        
    }


}

