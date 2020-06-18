//
//  Shaders.metal
//  study1
//
//  Created by gietal on 6/17/20.
//  Copyright © 2020 gietal. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct Vertex {
    float4 position [[position]];
};

vertex Vertex vertex_func(constant Vertex *vertices [[buffer(0)]], uint vid [[vertex_id]]) {
    return vertices[vid];
}

fragment float4 fragment_func(Vertex vert [[stage_in]]) {
    return float4(0.7, 1, 1, 1);
}
