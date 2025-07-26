//
//  Ad1ViewControllerWrapper.swift
//  VAMPSwiftUISample
//
//  Created by Supership Inc. on 2025/07/19.
//  Copyright © 2019年 Supership Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct Ad1ViewControllerWrapper: UIViewControllerRepresentable {
    @ObservedObject var viewModel: Ad1ViewModel

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = UIViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if viewModel.willShow {
            Task {
                viewModel.showAd(viewController: uiViewController)
            }
        }
    }
}
