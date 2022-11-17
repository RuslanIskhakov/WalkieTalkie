//
//  BaseViewController.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    var disposeBag = DisposeBag()

    init() {
        super.init(nibName: nil, bundle: nil)
        print("\(String(describing: type(of: self))) created")
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.backgroundColor = .systemGreen
            navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]

            self.navigationController?.navigationBar.standardAppearance = navBarAppearance;
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance;
        }
    }

    deinit {
        print("deinit for \(String(describing: type(of: self)))")
    }
}
