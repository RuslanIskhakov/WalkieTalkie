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
    @IBOutlet weak var distanceLabel: UILabel!
    
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
                let isEnabled: Bool
                switch state {
                case .idle:
                    buttonColor = .green
                    isEnabled = true
                case .receiving:
                    buttonColor = .gray
                    isEnabled = false
                case .transmitting:
                    buttonColor = .yellow
                    isEnabled = true
                }
                self.pttButton.backgroundColor = buttonColor
                self.pttButton.isEnabled = isEnabled
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

        self.viewModel?.peerDistance
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] text in
                guard let self else { return }
                self.distanceLabel.text = text
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
