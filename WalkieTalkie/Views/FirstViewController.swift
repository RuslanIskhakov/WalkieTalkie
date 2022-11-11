//
//  FirstViewController.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import UIKit

import UIKit

class FirstViewController: UIViewController {

    private var viewModel: FirstScreenViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "First"

        self.viewModel = FirstScreenViewModel(with: AppDelegate.appModel)
        self.viewModel?.showSecondEvent = {[weak self] in
            guard let strongSelf = self else {return}
            strongSelf.show(SecondViewController(), sender: nil)
        }
    }

    @IBAction func showSecond(_ sender: Any) {
        self.viewModel?.showSecondTap()
    }

    @IBAction func startServerTap(_ sender: Any) {
        self.viewModel?.startServerTap()
    }

    @IBAction func startClientTap(_ sender: Any) {
        self.viewModel?.startClientTap()
    }
}
