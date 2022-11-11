//
//  SecondViewController.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var counterLabel: UILabel!

    private var viewModel: SecondScreenViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Second"

        self.viewModel = SecondScreenViewModel(with: AppDelegate.appModel)
        self.viewModel?.showCounterValueEvent = {[unowned self] value in
            self.counterLabel.text = "Counter: \(value)"
        }
    }

    deinit {
        print("dstest deinit SecondViewController")
    }

    @IBAction func increment(_ sender: Any) {
        self.viewModel?.incrementTap()
    }
}
