//
//  SecondViewController.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import UIKit
import RxSwift

class SecondViewController: BaseViewController {

    @IBOutlet weak var counterLabel: UILabel!

    private var viewModel: SecondScreenViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Second"

        self.viewModel = SecondScreenViewModel(with: AppDelegate.appModel)
        self.viewModel?.showCounterValueEvent
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[unowned self] value in
                self.counterLabel.text = "Counter: \(value)"
            }).disposed(by: self.disposeBag)
    }

    deinit {
        print("dstest deinit SecondViewController")
    }

    @IBAction func increment(_ sender: Any) {
        self.viewModel?.incrementTap()
    }
}
