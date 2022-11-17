//
//  FeedbackGenerator.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import Foundation
import UIKit

class FeedbackGenerator: BaseIOInitialisable {


    func makeFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

}
