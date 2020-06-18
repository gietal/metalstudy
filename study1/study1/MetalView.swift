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
        
        guard let rpd = currentRenderPassDescriptor else {
            print("render pass descriptor is nil")
            return
        }
        
        guard let drawable = currentDrawable else {
            print("drawable is nil")
            return
        }
        
        let vertex_data:[Float] = [-1.0, -1.0, 0.0, 1.0,
                                    1.0, -1.0, 0.0, 1.0,
                                    0.0,  1.0, 0.0, 1.0]
        let data_size = vertex_data.count * MemoryLayout<Float>.size
        let vertex_buffer = device.makeBuffer(bytes: vertex_data, length: data_size, options: [])
        
        // make shader programmatically
        let library = device.makeDefaultLibrary()!
        let vertex_func = library.makeFunction(name: "vertex_func")
        let frag_func = library.makeFunction(name: "fragment_func")
        
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
        
        // translate metal commands to gpu commands
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd) else {
            print("failed to make render command encoder")
            return
        }
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        render()
    }
}
