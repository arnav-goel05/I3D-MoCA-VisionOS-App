//
//  Styles.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 18/6/25.
//

import SwiftUI

// Styling for button text.

struct ButtonTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 35, weight: .semibold, design: .rounded))
            .frame(width: 300, height: 60)
            .padding()
            .cornerRadius(10)
    }
}

// Styling for title text.

struct TitleTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .multilineTextAlignment(.center)
            .padding()
    }
}

struct SubtitleTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 35, weight: .regular, design: .rounded))
            .multilineTextAlignment(.center)
            .padding()
    }
}

struct RegularTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 30, weight: .medium, design: .rounded))
            .multilineTextAlignment(.center)
            .padding()
    }
}

// Extensions.

extension View {
    func buttonTextStyle() -> some View {
        self.modifier(ButtonTextStyle())
    }
}

extension View {
    func titleTextStyle() -> some View {
        self.modifier(TitleTextStyle())
    }
}

extension View {
    func subtitleTextStyle() -> some View {
        self.modifier(SubtitleTextStyle())
    }
}

extension View {
    func regularTextStyle() -> some View {
        self.modifier(RegularTextStyle())
    }
}

extension Image {
    func imageStyle() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(20)
    }
}
