//
//  TableViewController.swift
//  Practica2_Barman_ONC
//
//  Created by Omar Nieto on 02/03/23.
//

import UIKit

class TableViewController: UITableViewController {

    var bebidas =  Bebidas()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bebida1 = Bebida(directions: "Shake vigorously and serve.", ingredients: "white creme de menthe, peach liqueur vodka,  hot chocolate", name: "After Dinner Mint", img: "1.jpg")
        
        let bebida2 = Bebida(directions: "Pour the liqueur into a glass, add the cider, and serve cold.", ingredients: "cinnamon schnapps, hard cider", name: "Baked Apple", img: "2.jpg")
        
        bebidas.append(bebida1)
        bebidas.append(bebida2)
        
        
          
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return bebidas.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        let bebida = bebidas[indexPath.row]
        cell.textLabel?.text = bebida.name
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detalleBebidaSegue", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let destino = segue.destination as! ViewController
        
        
        // Pass the selected object to the new view controller.
    }
    

}
