//
//  MainMenuViewController.swift
//  RSR Test
//
//  Created by Ráchel Polachová on 26/02/2019.
//  Copyright © 2019 Rachel Polachova. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    @IBOutlet weak var infoButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navig_bar_back")?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .stretch), for: UIBarMetrics.default)
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navig_bar_back_ipad")?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .stretch), for: UIBarMetrics.default)
        }
    }
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Om gebruik te mäken van deze app, dient u het privacybeleid te accepteren.", message: "", preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "Accepteren", style: .default)
        let privacyPolicyAction = UIAlertAction(title: "Ga naar privacybeleid", style: .default) { (action) in
            let urlString = "https://www.rsr.nl/index.php?page=privacy-wetgeving&fbclid=IwAR0KscoIvNJmtsv1nk2ouxy3_RsEYSAFBcywCB0j-0hCT0-7pJdqvrA2U90"
            guard let url = URL(string: urlString) else { return }
            UIApplication.shared.open(url)
        }
        alert.addAction(acceptAction)
        alert.addAction(privacyPolicyAction)
        present(alert, animated: true, completion: nil)
    }
    
}

