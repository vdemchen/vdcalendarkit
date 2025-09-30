//
//  FekeView.swift
//  VDCalendarKit
//
//  Created by Vladyslav Demchenko on 24.09.2025.
//

import SwiftUI

// this view needed to prevent navigation title from scrolling
struct FakeView: UIViewRepresentable {
	public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView {
		UIView()
	}

	public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) { }
}
