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

    deinit {
        print("deinit for \(String(describing: type(of: self)))")
    }
}
