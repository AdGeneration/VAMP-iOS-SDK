//
//  ConsoleLogView.swift
//  VAMPSwiftUISample
//
//  Created by Supership Inc. on 2025/07/19.
//  Copyright © 2019年 Supership Inc. All rights reserved.
//

import SwiftUI

struct ConsoleLogView: View {
    let logs: [LogEntry]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 4) {
                ForEach(logs.reversed()) { log in
                    LogRowView(log: log)
                }
            }
            .padding(.horizontal, 2)
        }
        .padding(.vertical, 5)
        .background(Color(UIColor.secondarySystemBackground))
        .overlay(RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

struct LogRowView: View {
    let log: LogEntry

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(log.formattedTimestamp)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: true, vertical: false)
                .lineLimit(1)

            Text(log.message)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(log.messageColor)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct LogEntry: Identifiable {
    let id = UUID()
    let formattedTimestamp: String
    let message: String
    let messageColor: Color

    init(message: String, messageColor: Color = Color(UIColor.systemGray)) {
        self.message = message
        self.messageColor = messageColor

        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm:ss"
        formattedTimestamp = formatter.string(from: Date())

        print("[VAMP] \(formattedTimestamp) \(message)")
    }
}
