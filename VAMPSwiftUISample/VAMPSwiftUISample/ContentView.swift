//
//  ContentView.swift
//  VAMPSwiftUISample
//
//  Created by Supership Inc. on 2025/07/19.
//  Copyright © 2019年 Supership Inc. All rights reserved.
//

import SwiftUI
import VAMP

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        NavigationView(content: {
            VStack(spacing: 16) {
                VStack(spacing: 16) {
                    Text("VAMP SDK \(VAMPSDKVersion) / \(viewModel.location)")
                    HStack {
                        Text("PlacementId")
                            .frame(width: 100, alignment: .leading)
                        Spacer()
                        TextField("Enter text", text: $viewModel.placementId)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120, alignment: .trailing)
                    }

                    HStack {
                        Toggle(isOn: $viewModel.testMode) {
                            Text("TestMode")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        Spacer()
                    }

                    HStack {
                        Toggle(isOn: $viewModel.debugMode) {
                            Text("DebugMode")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        Spacer()
                    }
                }
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1))
                .padding(16)

                Spacer()

                VStack(spacing: 16) {
                    NavigationLink(destination: Ad1View(viewModel: Ad1ViewModel(placementId: viewModel
                            .placementId)))
                    {
                        Text("Ad1")
                    }
                    .buttonStyle(CapsuleButtonStyle())

                    NavigationLink(destination: InfoView()) {
                        Text("Info")
                    }
                    .buttonStyle(CapsuleButtonStyle())

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationTitle("VAMP SwiftUI Sample")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(UIColor.systemBackground))
            .padding(.top, 16)
        }).onAppear(perform: {
            viewModel.getLocation()
        })
    }
}

struct CapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 160)
            .padding()
            .background(Color.white)
            .foregroundColor(.blue)
            .font(.body.bold())
            .clipShape(Capsule())
            .overlay(RoundedRectangle(cornerRadius: 32)
                .stroke(Color.blue, lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
