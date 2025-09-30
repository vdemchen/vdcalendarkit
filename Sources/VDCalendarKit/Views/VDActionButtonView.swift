//
//  VDActionButtonView.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 17.09.2025.
//

import SwiftUI

struct VDActionButtonView: View {
	@EnvironmentObject private var manager: VDCalendarManager
	@Environment(\.calendarStyle) private var calendarStyle
	@Environment(\.dismiss) private var dismiss
	@Binding var isShowActionButton: Bool

	var body: some View {
		if isShowActionButton {
			VStack {
				Spacer()
				if let text = manager.actionButtonTitle {
					Button(action: {
						dismiss()
						manager.performActionButtonTap()
					}) {
						Text(text)
							.font(calendarStyle.actionButtonFont)
							.foregroundColor(.white)
							.frame(maxWidth: .infinity, maxHeight: .infinity)
							.padding(.vertical, 16)
							.background(calendarStyle.accentColor)
							.cornerRadius(12)
					}
					.frame(height: 56)
					.padding(.horizontal, 16)
					.padding(.bottom, 34)
				}
			}
			.transition(.move(edge: .bottom).combined(with: .opacity))
			.animation(.easeInOut(duration: 0.3), value: isShowActionButton)
		}
	}
}

#if DEBUG
#Preview {
	VDActionButtonView(isShowActionButton: .constant(false))
		.environmentObject(VDCalendarManager())
}
#endif
