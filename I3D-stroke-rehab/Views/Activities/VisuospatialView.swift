import SwiftUI

struct Node: Identifiable, Equatable {
    let id: String
    let position: CGPoint
}

struct ConnectingLine: Identifiable {
    let id = UUID()
    var start: CGPoint
    var end: CGPoint
}

struct Arrow: Shape {
    var start: CGPoint
    var end: CGPoint
    var headLength: CGFloat = 20
    var headAngle: CGFloat = .pi / 8

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let angle = atan2(end.y - start.y, end.x - start.x)
        let nodeRadius: CGFloat = 45
        
        let shortenedStart = CGPoint(x: start.x + nodeRadius * cos(angle), y: start.y + nodeRadius * sin(angle))
        let shortenedEnd = CGPoint(x: end.x - nodeRadius * cos(angle), y: end.y - nodeRadius * sin(angle))

        path.move(to: shortenedStart)
        path.addLine(to: shortenedEnd)

        let arrowP1 = CGPoint(x: shortenedEnd.x - headLength * cos(angle - headAngle),
                              y: shortenedEnd.y - headLength * sin(angle - headAngle))
        let arrowP2 = CGPoint(x: shortenedEnd.x - headLength * cos(angle + headAngle),
                              y: shortenedEnd.y - headLength * sin(angle + headAngle))

        path.move(to: arrowP1)
        path.addLine(to: shortenedEnd)
        path.addLine(to: arrowP2)

        return path
    }
}


struct VisuospatialView: View {
    let nodes: [Node] = [
        Node(id: "1", position: CGPoint(x: 650, y: 350)),
        Node(id: "A", position: CGPoint(x: 850, y: 150)),
        Node(id: "2", position: CGPoint(x: 1000, y: 200)),
        Node(id: "B", position: CGPoint(x: 850, y: 300)),
        Node(id: "3", position: CGPoint(x: 1000, y: 550)),
        Node(id: "C", position: CGPoint(x: 600, y: 600)),
        Node(id: "4", position: CGPoint(x: 800, y: 500)),
        Node(id: "D", position: CGPoint(x: 500, y: 500)),
        Node(id: "5", position: CGPoint(x: 450, y: 250)),
        Node(id: "E", position: CGPoint(x: 650, y: 100))
    ]

    @State private var lines: [ConnectingLine] = []
    @State private var currentLine: ConnectingLine?
    @State private var selectedNodes: [Node] = []
    @State private var navigateToNextTask = false
    @State private var showImmersiveSpace = false

    @EnvironmentObject var activityManager: ActivityManager
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.openWindow) var openWindow

    // Computed properties to break down complex expressions
    private var demoArrows: some View {
        Group {
            if lines.isEmpty {
                let node1 = nodes.first(where: { $0.id == "1" })
                let nodeA = nodes.first(where: { $0.id == "A" })
                let node2 = nodes.first(where: { $0.id == "2" })
                
                if let node1 = node1, let nodeA = nodeA, let node2 = node2 {
                    Arrow(start: node1.position, end: nodeA.position)
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [15, 15]))
                    Arrow(start: nodeA.position, end: node2.position)
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [15, 15]))
                }
            }
        }
    }
    
    private var drawnLines: some View {
        ForEach(lines) { line in
            Arrow(start: line.start, end: line.end)
                .stroke(Color.black, lineWidth: 5)
        }
    }
    
    private var currentLineView: some View {
        Group {
            if let currentLine = currentLine {
                let angle = atan2(currentLine.end.y - currentLine.start.y, currentLine.end.x - currentLine.start.x)
                let nodeRadius: CGFloat = 45
                let shortenedStart = CGPoint(
                    x: currentLine.start.x + nodeRadius * cos(angle),
                    y: currentLine.start.y + nodeRadius * sin(angle)
                )
                
                Path { path in
                    path.move(to: shortenedStart)
                    path.addLine(to: currentLine.end)
                }
                .stroke(Color.gray, lineWidth: 3)
            }
        }
    }

    var body: some View {
        VStack {
            Text("Connect the nodes in ascending order, alternating between numbers and letters (1-A-2-B...).")
                .font(.largeTitle)
                .padding()

            ZStack {
                demoArrows
                drawnLines
                currentLineView
                
                ForEach(nodes) { node in
                    ZStack {
                        Circle()
                            .fill(nodeColor(node))
                            .frame(width: 90, height: 90)
                        Text(node.id)
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                    }
                    .position(node.position)
                    .onTapGesture {
                        if let index = lines.firstIndex(where: { $0.start == node.position }) {
                            let lineToRemove = lines[index]
                            if let endNode = self.node(at: lineToRemove.end) {
                                selectedNodes.removeAll { $0 == node || $0 == endNode } 
                            }
                            lines.remove(at: index)
                        }
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if self.currentLine == nil {
                            if let startNode = self.node(at: value.startLocation) {
                                if !self.lines.contains(where: { $0.start == startNode.position }) {
                                    self.currentLine = ConnectingLine(start: startNode.position, end: value.location)
                                }
                            }
                        } else {
                            self.currentLine?.end = value.location
                        }
                    }
                    .onEnded { value in
                        defer { self.currentLine = nil }
                        guard var line = self.currentLine else { return }

                        guard let startNode = self.node(at: line.start),
                              let endNode = self.node(at: value.location) else {
                            return
                        }
                        
                        if startNode == endNode { return }
                        
                        let startNodeHasOutgoing = self.lines.contains { $0.start == startNode.position }
                        let endNodeHasIncoming = self.lines.contains { $0.end == endNode.position }
                        
                        if startNodeHasOutgoing || endNodeHasIncoming {
                            return
                        }

                        line.end = endNode.position
                        self.lines.append(line)
                        
                        if !selectedNodes.contains(startNode) {
                            selectedNodes.append(startNode)
                        }
                        if !selectedNodes.contains(endNode) {
                            selectedNodes.append(endNode)
                        }
                    }
            )
            
            HStack(spacing: 20) {
                Button(action: {
                    lines.removeAll()
                    selectedNodes.removeAll()
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset")
                        Spacer()
                    }
                    .buttonTextStyle()
                }
                
                Button(action: {
                    Task {
                        switch await openImmersiveSpace(id: "ImmersiveSpace") {
                        case .opened:
                            showImmersiveSpace = true
                            // Simply dismiss the windows
                            dismissWindow(id: "main")
                            dismissWindow(id: "progress-bar")
                            print("Entering immersive space...")
                        case .error, .userCancelled:
                            print("Failed to open immersive space")
                        @unknown default:
                            print("Unknown result when opening immersive space")
                        }
                    }
                }) {
                    Text("3D")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.clear)
                }
                
                NavigationLink(destination: ExecutiveView()) {
                    Text("Next Task")
                        .buttonTextStyle()
                }
                .disabled(false)
                .navigationDestination(isPresented: $navigateToNextTask) {
                    _3DPaintView()
                }

            }
            .padding()
        }
    }

    private func node(at point: CGPoint) -> Node? {
        nodes.first { node in
            let distance = sqrt(pow(point.x - node.position.x, 2) + pow(point.y - node.position.y, 2))
            return distance <= 45
        }
    }
    
    private func nodeColor(_ node: Node) -> Color {
        if selectedNodes.contains(node) {
            return .green
        }
        if let startNode = currentLine.flatMap({ self.node(at: $0.start) }), startNode == node {
            return .orange
        }
        return .yellow
    }
}

struct VisuospatialView_Previews: PreviewProvider {
    static var previews: some View {
        VisuospatialView()
    }
}
