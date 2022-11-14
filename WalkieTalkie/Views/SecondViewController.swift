//
//  SecondViewController.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import UIKit
import RxSwift

class SecondViewController: BaseViewController {

    private var viewModel: SecondScreenViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Second"

        self.viewModel = SecondScreenViewModel(with: AppDelegate.appModel)
    }

    deinit {
        print("dstest deinit SecondViewController")
    }
}
