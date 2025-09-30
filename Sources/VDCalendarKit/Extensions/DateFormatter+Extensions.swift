//
//  DateFormatter+Extensions.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 16.09.2025.
//

import Foundation

extension DateFormatter {
	static let dateFormatter = createFormatter(dateFormat: "dd.MM.yyyy")
	static let dayFormatter = createFormatter(dateFormat: "d")
	static let yearFormatter = createFormatter(dateFormat: "yyyy")
	
	static func createFormatter(
		dateFormat: String, locale: Locale? = .current,
		timeZone: TimeZone? = nil
	) -> DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = dateFormat
		if let locale = locale {
			formatter.locale = locale
		}
		if let timeZone = timeZone {
			formatter.timeZone = timeZone
		}
		return formatter
	}
}
