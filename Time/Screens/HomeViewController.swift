//
//  ViewController.swift
//  Time
//
//  Created by Mistake on 3/25/20.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    // temp image for hero
    @IBOutlet weak var tempImageView: UIImageView!
    
    var selectedRow = 0
    
    var cards = [
        ["title": "Discuss many things"],
        ["title": "Discuss many things"],
        ["title": "Discuss many things"],
        ["title": "Discuss many things"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.hero.isEnabled = true
        hero.isEnabled = true
        
        view.hero.modifiers = [.fade]
        
        collectionView!.decelerationRate = .fast
        
        if let layout = collectionView?.collectionViewLayout as? CardCollectionViewLayout {
          layout.delegate = self
        }
        
        tempImageView.layer.cornerRadius = 16
        
        navigationController!.hero.navigationAnimationType = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tempImageView.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CardDetails" {
            let destVC = segue.destination as! CardDetailsViewController
            destVC.row = selectedRow
        }
    }

}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath as IndexPath) as! CardCell
        cell.titleLabel.text = cards[indexPath.item]["title"];
        
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        let cell = collectionView.cellForItem(at: indexPath) as! CardCell

        // show temp image view
        tempImageView.image = cell.backgroundImageView.image
        tempImageView.isHidden = false
        tempImageView.frame = cell.contentView.convert(cell.backgroundImageView.frame, to: view)
        
        selectedRow = indexPath.row
        cell.titleLabel.hero.id = "CardTitle"

        performSegue(withIdentifier: "CardDetails", sender: self)
    }
}

extension HomeViewController: CardLayoutDelegate {
    func heightForItemInCollectionView(_ collectionView: UICollectionView) -> CGFloat {
        return 450
    }
}
