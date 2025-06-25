//
//  TaskManager.swift
//  I3D-stroke-rehab
//
//  Created by Interactive 3D Design on 18/6/25.
//

import SwiftUI

class TaskManager: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var userInput: String = ""
    @Published var backgroundColor: Color = .blue.opacity(0.2)
    @Published var show3DPainting: Bool = false
    @State var total: Int
    
    init(total: Int) {
        self.total = total
    }
    
    func nextTask() {
        currentIndex += 1
        userInput = ""
        backgroundColor = currentIndex == total ? .green.opacity(0.2) : .blue.opacity(0.2)
    }
}
