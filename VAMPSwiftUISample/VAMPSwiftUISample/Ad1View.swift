//
//  Ad1View.swift
//  VAMPSwiftUISample
//
//  Created by Supership Inc. on 2025/07/19.
//  Copyright © 2019年 Supership Inc. All rights reserved.
//

import SwiftUI
import VAMP

struct Ad1View: View {
    @StateObject var viewModel: Ad1ViewModel

    var body: some View {
        VStack(content: {
            VStack {
                ParameterRow(label: "PlacementId", value: viewModel.placementId)
                ParameterRow(label: "TestMode", value: "\(VAMP.isTestMode())")
                ParameterRow(label: "DebugMode", value: "\(VAMP.isDebugMode())")
            }
            .padding()
            .frame(width: 300, height: 120)
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1))

            Spacer(minLength: 16)

            HStack {
                Button(action: {
                    viewModel.loadAd()
                }) {
                    Text("LOAD")
                }
                .buttonStyle(RoundedButtonStyle())

                Button(action: {
                    viewModel.willShowAd()
                }) {
                    Text("SHOW")
                }
                .buttonStyle(RoundedButtonStyle())
            }

            Spacer(minLength: 16)

            ConsoleLogView(logs: viewModel.logs)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal, 8)

            Ad1ViewControllerWrapper(viewModel: viewModel)
                .frame(width: 0, height: 0)
        })
        .navigationTitle("Ad1")
    }
}

struct ParameterRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text("\(label): ")
                .font(.body)
                .fixedSize(horizontal: true, vertical: false)

            Spacer()

            Text(value)
                .font(.body)
        }
    }
}

struct RoundedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 100, height: 16)
            .padding()
            .background(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    Ad1View(viewModel: Ad1ViewModel(placementId: "59755"))
}
