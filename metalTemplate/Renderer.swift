import Foundation
import MetalKit
import simd

class Renderer: NSObject {
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var library: MTLLibrary
    var pipelineState: MTLRenderPipelineState!
    var computePipelineState: MTLComputePipelineState!
    var dimensionsBuffer: MTLBuffer?
    var timeBuffer: MTLBuffer? 


    struct ScreenDimensions {
        var width: Float
        var height: Float
    }
    
    struct Time {
        var value: Float
    }

    init?(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue(),
              let library = device.makeDefaultLibrary() else {
            print("Metal is not supported on this device")
            return nil
        }

        self.device = device
        self.commandQueue = commandQueue
        self.library = library

        super.init()

        metalView.device = device
        if !setupShadersAndPipelineState(metalView: metalView) {
            return nil
        }
        if !setupComputePipelineState() {
            return nil
        }
        
        updateScreenDimensions(metalView: metalView)
        setupTimeBuffer()
        metalView.delegate = self
    }

    private func setupShadersAndPipelineState(metalView: MTKView) -> Bool {
        let vertexFunction = library.makeFunction(name: "vertex_main")
        let fragmentFunction = library.makeFunction(name: "fragment_main")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat

        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            return true
        } catch let error {
            print("Failed to create render pipeline state: \(error)")
            return false
        }
    }

    private func setupComputePipelineState() -> Bool {
        guard let computeFunction = library.makeFunction(name: "compute_main") else {
            print("Compute function not found")
            return false
        }

        do {
            computePipelineState = try device.makeComputePipelineState(function: computeFunction)
            return true
        } catch let error {
            print("Failed to create compute pipeline state: \(error)")
            return false
        }
    }

    private func updateScreenDimensions(metalView: MTKView) {
        let size = metalView.bounds.size
        var dimensions = ScreenDimensions(width: Float(size.width), height: Float(size.height))
        dimensionsBuffer = device.makeBuffer(bytes: &dimensions, length: MemoryLayout<ScreenDimensions>.size, options: .storageModeShared)
    }
    
    private func setupTimeBuffer() {
        var time = Time(value: 0)
        timeBuffer = device.makeBuffer(bytes: &time, length: MemoryLayout<Time>.size, options: .storageModeShared)
    }
    
    private func updateTimeBuffer() {
        guard let timeBuffer = timeBuffer else { return }
        
        let currentTime = Float(CACurrentMediaTime())
        var time = Time(value: currentTime)
        memcpy(timeBuffer.contents(), &time, MemoryLayout<Time>.size)
    }

    func performComputePass() {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let computeEncoder = commandBuffer.makeComputeCommandEncoder(),
              let dimensionsBuffer = dimensionsBuffer,
              let timeBuffer = timeBuffer else {
            return
        }

        computeEncoder.setComputePipelineState(computePipelineState)
        computeEncoder.setBuffer(dimensionsBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(timeBuffer, offset: 0, index: 1)


        // Dispatch compute commands (adjust parameters based on your compute kernel)
        // Example: computeEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)

        computeEncoder.endEncoding()
        commandBuffer.commit()
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateScreenDimensions(metalView: view)
        updateTimeBuffer() // Update the time buffer each frame
        performComputePass()
    }

    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor),
              let dimensionsBuffer = dimensionsBuffer else {
            return
        }

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(dimensionsBuffer, offset: 0, index: 0)
        renderEncoder.endEncoding()

        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }

        commandBuffer.commit()
    }
}
