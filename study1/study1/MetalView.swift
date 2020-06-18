//
//  MetalView.swift
//  study1
//
//  Created by gietal on 6/17/20.
//  Copyright © 2020 gietal. All rights reserved.
//

import Foundation
import AppKit
import MetalKit

class MetalView: MTKView {
    func render() {
        // get reference to the gpu
        self.device = MTLCreateSystemDefaultDevice()
        
        guard let device = self.device else {
            print("device is nil")
            return
        }
        
        // MTLRenderPassDescriptor is sort of like render target
        guard let rpd = currentRenderPassDescriptor else {
            print("render pass descriptor is nil")
            return
        }
        
        guard let drawable = currentDrawable else {
            print("drawable is nil")
            return
        }
        
        // create clear color
        let bleen = MTLClearColor(red: 0, green: 0.5, blue: 0.5, alpha: 1)
        rpd.colorAttachments[0].texture = drawable.texture
        rpd.colorAttachments[0].clearColor = bleen
        rpd.colorAttachments[0].loadAction = .clear
        
        // commandQueue: serial sequence of command buffer
        guard let commandQueue = device.makeCommandQueue() else {
            print("failed to make command queue")
            return
        }
        
        // store the commands encoded by the command encoder
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("failed to make command buffer")
            return
        }
        
        // encoder translates metal commands to gpu commands
        // this encoder will put the commands to draw to the render pass specified
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd) else {
            print("failed to make render command encoder")
            return
        }
        
        
        // triangle in screen coordinate [(-1, -1), (1, 1)]
        let vertex_data:[Float] = [-1.0, -1.0, 0.0, 1.0,
                                    1.0, -1.0, 0.0, 1.0,
                                    0.0,  1.0, 0.0, 1.0]
        let data_size = vertex_data.count * MemoryLayout<Float>.size
        let vertex_buffer = device.makeBuffer(bytes: vertex_data, length: data_size, options: [])
        
        // find the shader funcs from all our metal files
        let library = device.makeDefaultLibrary()!
        let vertex_func = library.makeFunction(name: "vertex_func")
        let frag_func = library.makeFunction(name: "fragment_func")
        
        // create descriptor to make MTLRenderPipelineState
        // specify the shader functions and pixel format
        let rpld = MTLRenderPipelineDescriptor()
        rpld.vertexFunction = vertex_func
        rpld.fragmentFunction = frag_func
        rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // MTLRenderPipelineState contains all the graphics function and configs
        // to be used in a render pass
        let rps = try! device.makeRenderPipelineState(descriptor: rpld)
        
        // set the state for this rendering
        encoder.setRenderPipelineState(rps)
        encoder.setVertexBuffer(vertex_buffer, offset: 0, index: 0)
        
        // then draw
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        
        // done
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        render()
    }
}
