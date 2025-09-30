//
//  View+Extensions.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 16.09.2025.
//

import SwiftUI

extension View {
	@ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}
}
