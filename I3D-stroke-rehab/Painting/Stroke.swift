import SwiftUI
import RealityKit


struct Stroke {
    /// The stroke that represents the stroke.
    var entity = Entity()


    /// The collection of points in 3D space that represent the stroke.
    var points: [SIMD3<Float>] = []


    /// The maximum radius of the stroke.
    let maxRadius: Float = 1E-2


    /// The number of points in each ring of the mesh.
    let pointsPerRing = 8


    func updateMesh() {
        // The starting point where the stroke mesh begins.
        guard let center = points.first else { return }


        /// The position, normals, and triangle indices that the points generate.
        let (positions, normals, triangles) = generateMeshData()


        /// The `MeshResource.Contents` instance.
        var contents = MeshResource.Contents()
        
        // Create and assign an instance to `contents`.
        contents.instances = [MeshResource.Instance(id: "main", model: "model")]


        // Create the part for the model, and set the vertex positions, triangle indices, and normals.
        var part = MeshResource.Part(id: "part", materialIndex: 0)
        part.positions = MeshBuffer(positions)
        part.triangleIndices = MeshBuffer(triangles)
        part.normals = MeshBuffer(normals)


        // Create and assign a model that consists of the `part`.
        contents.models = [MeshResource.Model(id: "model", parts: [part])]


        // Replace the mesh with `contents` if there is a mesh component on the entity.
        if let mesh = entity.components[ModelComponent.self]?.mesh {
            do {
                try mesh.replace(with: contents)
            } catch {
                print("Error replacing mesh: \(error.localizedDescription)")
            }
        } else {
            /// The new mesh that generates with `content`.
            guard let mesh = try? MeshResource.generate(from: contents) else {
            print("Error generating mesh")
                return
            }


            // Set the model component to the new mesh and assign a simple material.
            entity.components.set(ModelComponent(
                mesh: mesh,
                materials: [SimpleMaterial(color: .white, roughness: 1.0, isMetallic: false)]
            ))


            // Set the entity's transform and position.
            entity.setTransformMatrix(matrix_identity_float4x4, relativeTo: nil)
            entity.setPosition(center, relativeTo: nil)
        }
    }
    
    private func generateMeshData() -> ([SIMD3<Float>], [SIMD3<Float>], [UInt32]) {
        var positions: [SIMD3<Float>] = []
        var normals: [SIMD3<Float>] = []
        var triangles: [UInt32] = []


        guard points.count > 1 else {
            return ([], [], [])
        }


        for i in 0..<points.count {
            let currentPoint = points[i]
            let direction: SIMD3<Float>
            if i < points.count - 1 {
                direction = normalize(points[i+1] - currentPoint)
            } else {
                direction = normalize(currentPoint - points[i-1])
            }


            // Create a rotation to align the ring with the direction of the stroke
            let up: SIMD3<Float> = [0, 1, 0]
            let rotation = simd_quatf(from: up, to: direction)


            for j in 0..<pointsPerRing {
                let angle = Float(j) / Float(pointsPerRing) * 2 * .pi
                let ringPoint = SIMD3<Float>(cos(angle) * maxRadius, sin(angle) * maxRadius, 0)
                let rotatedPoint = rotation.act(ringPoint)
                positions.append(currentPoint + rotatedPoint)
                normals.append(normalize(rotatedPoint))
            }
        }


        for i in 0..<points.count - 1 {
            for j in 0..<pointsPerRing {
                let current = UInt32(i * pointsPerRing + j)
                let next = UInt32(i * pointsPerRing + (j + 1) % pointsPerRing)
                let currentUp = UInt32((i + 1) * pointsPerRing + j)
                let nextUp = UInt32((i + 1) * pointsPerRing + (j + 1) % pointsPerRing)


                triangles.append(contentsOf: [current, next, currentUp])
                triangles.append(contentsOf: [next, nextUp, currentUp])
            }
        }


        return (positions, normals, triangles)
    }
}
