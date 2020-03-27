//
//  CardDetailsViewController.swift
//  Time
//
//  Created by Mistake on 3/26/20.
//

import UIKit
import Hero

class CardDetailsViewController: UIViewController {
    @IBOutlet weak var leftTimeContainerView: UIView!
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var userActionView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    // naming hero animation index
    var row = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hero.isEnabled = true
        
        // set round border to left time
        leftTimeContainerView.layer.cornerRadius = 12
        leftTimeContainerView.layer.borderColor = UIColor.white.cgColor
        leftTimeContainerView.layer.borderWidth = 1.0 / UIScreen.main.scale
        
        // expand below status bar
        itemsTableView.contentInsetAdjustmentBehavior = .never
        
        // set round border to action view
        userActionView.layer.cornerRadius = 10
        userActionView.layer.borderColor = UIColor(white: 0.53, alpha: 0.1).cgColor
        userActionView.layer.borderWidth = 1
        
        backgroundImageView.hero.id = "BackgroundImage"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CardDetailsViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.setContentOffset(.zero, animated: false)
           navigationController?.popViewController(animated: true)
        }
    }
}

extension CardDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardDetailsItemCell", for: indexPath) as! CardDetailsItemCell
        
        // mock cells for now
        switch indexPath.row {
        case 0:
            cell.fillDetails("Repeats weekly on Mon, Wed, Sat", "Ends on Dec 12", UIImage(named: "repeat"))
        default:
            cell.fillDetails("Blue Bottle Coffee", "5.0mi | 400 Florence St, Palo Alto, CA 94301", UIImage(named: "location"))
        }
        return cell
    }
}
