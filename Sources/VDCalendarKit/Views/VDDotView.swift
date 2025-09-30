//
//  VDDotView.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 03.09.2025.
//

import SwiftUI

struct VDDotView: View {
	private(set) var count: Int
	@Environment(\.calendarStyle) private var calendarStyle
	@Binding private(set) var type: VDDayStyle

	var body: some View {
		ZStack {
			if type.isSelected {
				Circle()
					.fill(Color.white)
			} else {
				Circle()
					.fill(calendarStyle.selectionGradient.linearGradient())
			}

			Text("\(count)")
				.font(calendarStyle.dotFont)
				.foregroundStyle(type.isSelected ? .black : .white)
				.minimumScaleFactor(0.5)
		}
	}
}

#if DEBUG
#Preview {
	VDDotView(count: 2, type: .constant(.selected))
		.frame(width: 16, height: 16)
}
#endif
