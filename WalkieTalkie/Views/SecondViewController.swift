//
//  SecondViewController.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import UIKit
import RxSwift

class SecondViewController: BaseViewController {

    @IBOutlet weak var pttButton: UIButton!

    private var viewModel: SecondScreenViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""

        self.viewModel = SecondScreenViewModel(with: AppDelegate.appModel)

        self.pttButton.layer.borderWidth = 8

        self.setupBindings()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.viewModel?.viewDidAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.viewModel?.viewWillDisappear()
    }

    private func setupBindings() {

        self.viewModel?.wkState
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] state in
                guard let self else { return }
                let buttonColor: UIColor
                switch state {
                case .idle:
                    buttonColor = .green
                case .receiving:
                    buttonColor = .gray
                case .transmitting:
                    buttonColor = .yellow
                }
                self.pttButton.backgroundColor = buttonColor
            }).disposed(by: self.disposeBag)

        self.viewModel?.connectivityState
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] state in
                guard let self else { return }
                let borderColor: UIColor
                switch state {
                case .ok:
                    borderColor = . green
                case .noConnection:
                    borderColor = .red
                }
                self.pttButton.layer.borderColor = borderColor.cgColor
            }).disposed(by: self.disposeBag)
    }

    @IBAction func pttTouchUpInside(_ sender: Any) {
        self.viewModel?.pttTouchUp()
    }
    @IBAction func pttTouchDown(_ sender: Any) {
        self.viewModel?.pttTouchDown()
    }
    @IBAction func touchUpOutside(_ sender: Any) {
        self.viewModel?.pttTouchUp()
    }
}
