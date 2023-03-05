//
//  ViewController.swift
//  Practica2_Barman_ONC
//
//  Created by Omar Nieto on 01/03/23.
//

import UIKit
import AVFoundation

class BebidaDetalleViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ingredientesTextView: UITextView!
    @IBOutlet weak var instruccionesTextView: UITextView!
    @IBOutlet weak var fileNameLabel: UILabel!
    
    
    var imgPickerController: UIImagePickerController?
    
    
    //Obtener el contexto para CoreData
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Objeto mostrado
    var bebida : Bebida? = nil
    
    let downloadImageURL = "http://janzelaznog.com/DDAM/iOS/drinksimages/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if bebida != nil {
            updateView()
        }
        else { //Nueva tarea
            nameTextField.becomeFirstResponder()
        }
        
        //Ocultar el teclado cuando se hace un tap fuera del campo de texto
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
       //Se emplea un control UILabel para guardar el nombre del archivo de la imagen, pero no se muestra
        fileNameLabel.text = ""
        fileNameLabel.isEnabled = false
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let destino = segue.destination as! TableViewController
        updateData()
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        var perform = false
        
        if Helper.validateText(text: nameTextField.text!){
            perform = true
        }else{
            
            Helper.AlertMessageOk(title: NSLocalizedString("ALERT_TITLE_VACIO", comment: "ALERT_TITLE_VACIO"), message: NSLocalizedString("ALERT_MENSSAGE_VACIO", comment: "ALERT_MENSSAGE_VACIO"), viewController: self)
        }
        return perform
    }
    
    
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        Salir()
    }
    
    
    private func Salir()
    {
        let esPresentadoEnModal = self.presentingViewController is UINavigationController
        if esPresentadoEnModal {
            dismiss(animated: true)
        }
        else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    
    func updateData()
    {
        if bebida == nil {
            bebida = Bebida(context: contexto)
        }
        bebida?.name = nameTextField.text ?? ""
        bebida?.ingredients  = ingredientesTextView.text ?? ""
        bebida?.directions = instruccionesTextView.text ?? ""
        bebida?.img = fileNameLabel.text
    
    }
    
    
    func updateView()
    {
        if bebida != nil{
            nameTextField.text = bebida?.name
            ingredientesTextView.text = bebida?.ingredients
            instruccionesTextView.text = bebida?.directions
            fileNameLabel.text = bebida?.img
            loadImage(srcImage: bebida?.img ?? "")
            
        }
    }

    
    func getLocalFileImageURL(strFile: String) -> URL? {
        var resultURL = URL(string: "")
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            var barmanDirectoryURL = documentsURL.appendingPathComponent("Barman")
            if FileManager.default.fileExists(atPath: barmanDirectoryURL.path) == false {
                do {
                    try FileManager.default.createDirectory(atPath: barmanDirectoryURL.path, withIntermediateDirectories: true)
                }
                catch {
                    print("ERROR: No se ha podido crear el directorio Barman")
                    barmanDirectoryURL = documentsURL
                }
            }
            resultURL = barmanDirectoryURL.appendingPathComponent(strFile)
        }
        return resultURL
    }
    
  
    
    //Las imágenes de cada bebida, se encuentran en
    // http://janzelaznog.com/DDAM/iOS/drinksimages/[nombre_de_la_bebida]
    // Cuando se vea una bebida por primera vez, hay que validar si su imagen existe en la carpeta Documents del dispositivo, en caso contrario descárgala y guárdala.
    // srcImageLabel.text = bebida?.img
    
    
    func loadImage(srcImage: String){
        //Se obtiene la imagen por defecto
        let strImgDefault = "Coctel1.jpg"
        
        //se obtiene la rula local donde se guarda las imagenes
        let localFilePathURL = getLocalFileImageURL(strFile: srcImage)
        
        //Si no se tiene una URL, entonces se carga la imagen por defecto
        if srcImage == "" {
            self.imageView.image = UIImage(named: strImgDefault)
        }
        else if FileManager.default.fileExists(atPath: localFilePathURL?.path ?? "") {
            // Verifica si el archivo ya existe localmente
            
            
            URLSession.shared.dataTask(with: localFilePathURL!) { data, response, error in
                
                if error == nil {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data!)
                    }
                }
                else {
                    print("ERROR: al leer el archivo \(String(describing: error))")
                }
            }.resume()
        }
        else { //Si el archivo no existe localmente, se intenta descargar de internet
            
            loadImageFromURL(srcImage: srcImage, dstImageView: self.imageView)
        }

    }
    
    func loadImageFromURL(srcImage: String, dstImageView: UIImageView) {
        
        //se obtiene la rula local donde se guarda las imagenes
        guard let localFilePathURL = getLocalFileImageURL(strFile: srcImage) else { return }
        
        //Se obtiene la ruta de la descarga de la imagen
        let strURL = downloadImageURL + srcImage
        
        if MonitorRed.instance.conexionActiva == false {  //Si la conexión no está activa
            Helper.AlertMessageOk(title: NSLocalizedString("DOWNLOAD_BTN_ALERT_TITLE", comment: "DOWNLOAD_BTN_ALERT_TITLE"), message: NSLocalizedString("DOWNLOAD_BTN_ALERT_MESSAGE", comment: "DOWNLOAD_BTN_ALERT_MESSAGE"), viewController: self)
            
            print("AVISO: No se tiene una conexión a Internet")
            return
        }
        
        
        if let url = URL(string: strURL) {
            
            // 1. Establecer la configuración por defecto para la sessión
            let sessionConfig = URLSessionConfiguration.default
            
            // 2. Crear la sesión
            let session = URLSession(configuration: sessionConfig)
            
            // 3. Se crea la solicitud (request) del recurso
            let request = URLRequest(url: url)
            
            // 4. Se crea la terea para responder a la petición
            let task = session.dataTask(with: request) { bytes, response, error in
                if error != nil {
                    Helper.AlertMessageOk(title: NSLocalizedString("DOWNLOAD_BTN_ALERT_TITLE3", comment: "DOWNLOAD_BTN_ALERT_TITLE3"), message: NSLocalizedString("DOWNLOAD_BTN_ALERT_MESSAGE3", comment: "DOWNLOAD_BTN_ALERT_MESSAGE3"), viewController: self)
                    
                    print("ERROR: al descargar la imagen de la bebida: \(request) \n \(String(describing:error))")
                    return
                }
                
                do {
                    guard let data = bytes else { return }
                    //Se guarda la imagen en forma local
                    try data.write(to: localFilePathURL)
                    DispatchQueue.main.async {
                        dstImageView.image = UIImage(data: data)
                    }
                    
                }
                catch {
                    print("ERROR: No se ha podido almacenar la imagen de forma local: \(String(describing:error))")
                }
            }
            
            // 5. Se inicia la tarea
            task.resume()
        }
    }
    
    // MARK: Manejo de la camara
    
    @IBAction func photoButtonPressed(_ sender: UIBarButtonItem) {
        
        //Configuración del UIImagePickerController
        imgPickerController = UIImagePickerController()
        imgPickerController?.delegate = self
        imgPickerController?.allowsEditing = true
        
        
        //Comprueba si tiene camara
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                DispatchQueue.main.async {
                    self.imgPickerController?.sourceType = .camera
                    self.present(self.imgPickerController!, animated: true)
                }

            case .notDetermined, .denied:
                AVCaptureDevice.requestAccess(for: .video) { permiso in
                    DispatchQueue.main.async {
                        if permiso {
                                self.imgPickerController?.sourceType = .camera
                                self.present(self.imgPickerController!, animated: true)
                            }
                        else {
                                Helper.AlertMessageOk(title: NSLocalizedString("PHOTO_BTN_ALERT_TITLE2", comment: "PHOTO_BTN_ALERT_TITLE2"), message: NSLocalizedString("PHOTO_BTN_ALERT_MESSAGE2", comment: "PHOTO_BTN_ALERT_MESSAGE2"), viewController: self)
                            }
                    }
                }
    
            default:
                Helper.AlertMessageOk(title: NSLocalizedString("PHOTO_BTN_ALERT_TITLE2", comment: "PHOTO_BTN_ALERT_TITLE2"), message: NSLocalizedString("PHOTO_BTN_ALERT_MESSAGE2", comment: "PHOTO_BTN_ALERT_MESSAGE2"), viewController: self)
            }
            
            
        }
        else {
            Helper.AlertMessageOk(title: NSLocalizedString("PHOTO_BTN_ALERT_TITLE", comment: "PHOTO_BTN_ALERT_TITLE"), message: NSLocalizedString("PHOTO_BTN_ALERT_MESSAGE", comment: "PHOTO_BTN_ALERT_MESSAGE"), viewController: self)
            
        }
        
    }
    
    // MARK: Eventos de la camara
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            self.imageView.image = image
            
            //Guardar la imagen
            let strFileName = "\(Helper.dateFormatter.string(from: Date())).png"
            //se obtiene la rula local donde se guarda las imagenes
            guard let localFilePathURL = getLocalFileImageURL(strFile: strFileName) else { return }
            if let data = image.pngData() {
                do{
                    try data.write(to: localFilePathURL)
                    fileNameLabel.text = strFileName
                }
                catch{
                    print("ERROR: No se ha podido almacenar la imagen (\(localFilePathURL.path)) de forma local: \(String(describing:error))")
                }
            }
           
             
            
        }
    }

    
}

