//
//  VDCalendarEnvironmentKeys.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 03.09.2025.
//

import SwiftUI

public struct VDCalendarStyleKey: @preconcurrency EnvironmentKey {
	@MainActor public static let defaultValue: VDCalendarStyle = .init(
		selectionGradient: CalendarGradient(start: .blue, end: .blue.opacity(0.5)),
		periodColor: .blue.opacity(0.2),
		accentColor: .blue,
		controlButtonsColor: .gray,
		descriptionFont: .system(size: 16, weight: .medium),
		descriptionColor: .gray,
		dayFont: .system(size: 18, weight: .medium),
		dayUnavailableColor: .gray.opacity(0.3),
		dotFont:.system(size: 11, weight: .semibold),
		monthHeaderFont:.system(size: 18, weight: .bold),
		dividerColor: .gray,
		weekDayColor: .gray,
		weekDayFont: .system(size: 16, weight: .semibold),
		actionButtonFont: .system(size: 18, weight: .medium),
		weekendColor: .red,
		weekendUnavailableColor: .red.opacity(0.5),
		todayFont: .body.bold()
	)
}

extension EnvironmentValues {
	public var calendarStyle: VDCalendarStyle {
		get {
			self[VDCalendarStyleKey.self]
		} set {
			self[VDCalendarStyleKey.self] = newValue
		}
	}
}
