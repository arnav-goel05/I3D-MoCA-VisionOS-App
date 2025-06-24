//
//  ActivityManager.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 24/6/25.
//

import SwiftUI

final class ActivityManager: ObservableObject {
    @Published var currentActivityIndex = 0

    func nextActivity(index: Int) {
        currentActivityIndex = index
    }
}
