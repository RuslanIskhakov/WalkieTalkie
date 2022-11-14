//
//  FirstViewController.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import UIKit
import RxSwift

class FirstViewController: BaseViewController {
    @IBOutlet weak var networkStateLabel: UILabel!
    @IBOutlet weak var ipAddressLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!

    private var viewModel: FirstScreenViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""

        self.viewModel = FirstScreenViewModel(with: AppDelegate.appModel)
        self.setupBindings()

        self.refreshButton.setTitle("", for: .normal)
        self.refreshButton.setTitle("", for: .disabled)

        self.viewModel?.configureView()
    }

    private func setupBindings() {
        self.viewModel?.showSecondEvent = {[weak self] in
            guard let strongSelf = self else {return}
            strongSelf.show(SecondViewController(), sender: nil)
        }

        self.viewModel?.refreshButtonEnabled
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] value in
                guard let self else { return }
                self.refreshButton.isEnabled = value
            }).disposed(by: self.disposeBag)

        self.viewModel?.networkStateText
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] text in
                guard let self else { return }
                self.networkStateLabel.text = text
            }).disposed(by: self.disposeBag)

        self.viewModel?.ipAddressText
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] text in
                guard let self else { return }
                self.ipAddressLabel.text = text
            }).disposed(by: self.disposeBag)
    }

    @IBAction func showSecond(_ sender: Any) {
        self.viewModel?.showSecondTap()
    }

    @IBAction func startServerTap(_ sender: Any) {
        self.viewModel?.startServerTap()
    }

    @IBAction func tryAudioTap(_ sender: Any) {
        self.viewModel?.tryAudioTap()
    }

    @IBAction func startClientTap(_ sender: Any) {
        self.viewModel?.startClientTap()
    }
    @IBAction func refreshTap(_ sender: Any) {
        self.viewModel?.refreshTap()
    }
}
