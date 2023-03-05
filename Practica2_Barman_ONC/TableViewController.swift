//
//  TableViewController.swift
//  Practica2_Barman_ONC
//
//  Created by Omar Nieto on 02/03/23.
//

import UIKit


class TableViewController: UITableViewController {
    //Outlets
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    //Obtener el contexto para CoreData
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Se crea el manejador para la base de datos
    var dataManager : BebidasDataManager?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataManager = BebidasDataManager(context: contexto)
        dataManager?.fetchData()
  
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataManager?.countBebidas() ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        let bebida = dataManager?.getBebida(at: indexPath.row)
        cell.textLabel?.text = bebida?.name
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if tableView.isEditing {
            return nil
        }
        
        //SE agrega el botón de borrar
        let action = UIContextualAction(style: .destructive, title: NSLocalizedString("ALERT_TITLE_BORRAR", comment: "ALERT_TITLE_BORRAR")) {(action, view, completionHandler) in
            
            self.dataManager?.deleteBebida(at: indexPath.row)
            tableView.reloadData()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }


    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            self.dataManager?.deleteBebida(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "DetalleBebidaSegue", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AddBebidaSegue" {
            if let indexSelected = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: indexSelected, animated: true)
            }
        }
        else if segue.identifier == "DetalleBebidaSegue" {
            let destino = segue.destination as! BebidaDetalleViewController
            let indexSelected = tableView.indexPathForSelectedRow?.row
            destino.bebida = dataManager?.getBebida(at: indexSelected!)
        }
    }
    
    
    //Segue ejecutado cuando el DetalleViewController aprieta el botón save
    
    @IBAction func unwindFromDetail(segue: UIStoryboardSegue)
    {
        let source = segue.source as! BebidaDetalleViewController
        if let selectedIndexPath = tableView.indexPathForSelectedRow
        {
            //Cuando se ha seleccionado un elemento y se ha mostrado el detalle
            // el renglón del tableView aun sigue seleccionado
            dataManager?.setBebida(bebida: source.bebida!, at: selectedIndexPath.row)
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        }
        else {
            //Agregar nueva bebida.
            //Previamente, en la preparación del segue se ha deseleccionado
            //cualquier renglón para evitar confundirlo con el detalle
            dataManager?.saveData()
            dataManager?.fetchData()
            tableView.reloadData()
        }
    }
   
    
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            addButton.isEnabled = true
            sender.title = NSLocalizedString("BUTTON_EDIT", comment: "BUTTON_EDIT")
        } else {
            tableView.setEditing(true, animated: true)
            addButton.isEnabled = false
            sender.title = NSLocalizedString("BUTTON_DONE", comment: "BUTTON_DONE")
        }
    }
    
    
    
    @IBAction func downloadButtonPressed(_ sender: UIBarButtonItem) {
        
        // Descarga el archivo con las bebidas predeterminadas de la siguiente URL: http://janzelaznog.com/DDAM/iOS/drinks.json
        let strUrl = "http://janzelaznog.com/DDAM/iOS/drinks.json"
        
        if MonitorRed.instance.conexionActiva == true {
            if let url = URL(string: strUrl) {
                
                // 1. Establecer la configuración por defecto para la sessión
                let sessionConfig = URLSessionConfiguration.default
                
                // 2. Crear la sesión
                let session = URLSession(configuration: sessionConfig)
                
                // 3. Se crea la solicitud (request) del recurso
                let request = URLRequest(url: url)
                
                // 4. Se crea la terea para responder a la petición
                let task = session.dataTask(with: request) { bytes, response, error in
                    if error != nil {
                        Helper.AlertMessageOk(title: NSLocalizedString("DOWNLOAD_BTN_ALERT_TITLE2", comment: "DOWNLOAD_BTN_ALERT_TITLE2"), message: NSLocalizedString("DOWNLOAD_BTN_ALERT_MESSAGE2", comment: "DOWNLOAD_BTN_ALERT_MESSAGE2"), viewController: self)
                        
                        print("ERROR: al descargar la bebidas: \(String(describing:error))")
                        return
                    }
                    //Consultar el JSON
                    do {
                        guard let data = bytes else { return }
                        //Se guarda la información recabada
                        let listaBebidas = try JSONDecoder().decode(BebidasJSON.self, from: data)
                        
                        
                        for item in listaBebidas {
                            let  nuevaBebida = Bebida(context: self.contexto)
                            nuevaBebida.name = item.name
                            nuevaBebida.ingredients = item.ingredients
                            nuevaBebida.directions = item.directions
                            nuevaBebida.img = item.img
                        }
                        
                        DispatchQueue.main.async {
                            self.dataManager?.saveData()
                            self.dataManager?.fetchData()
                            self.tableView.reloadData()
                        }
                        
                    }
                    catch {
                        print("ERROR: Deserializar el JSON: \(String(describing:error))")
                    }
                }
                
                // 5. Se inicia la tarea
                task.resume()
                
            }
            
        }
        else {  //Si la conexión no está activa
            Helper.AlertMessageOk(title: NSLocalizedString("DOWNLOAD_BTN_ALERT_TITLE", comment: "DOWNLOAD_BTN_ALERT_TITLE"), message: NSLocalizedString("DOWNLOAD_BTN_ALERT_MESSAGE", comment: "DOWNLOAD_BTN_ALERT_MESSAGE"), viewController: self)
            
            print("AVISO: No se tiene una conexión a Internet")
        }
                
    }
    
    
    

}
