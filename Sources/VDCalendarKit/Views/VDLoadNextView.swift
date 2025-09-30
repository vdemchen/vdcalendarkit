//
//  VDLoadNextView.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 22.09.2025.
//

import SwiftUI

// MARK: - VDLoadNextView
struct VDLoadNextView: View {
	// MARK: - Property
	private(set) var onAppear: () -> Void

	// MARK: - View
    var body: some View {
		Text("load")
			.foregroundStyle(Color.clear)
			.frame(height: 1)
			.onAppear {
				onAppear()
			}
    }
}
