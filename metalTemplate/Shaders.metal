#include <metal_stdlib>
using namespace metal;

kernel void compute_main(
    // Example of a compute kernel parameter.
    // You can replace or remove this depending on your actual compute task.
    device float *data [[buffer(0)]],

    // The thread position in a threadgroup.
    uint3 threadPositionInGrid [[thread_position_in_grid]]
) {
    // This is a placeholder compute kernel and does not perform any computations.
    // You can add your compute logic here in the future.
}


// Structure for output vertices from the vertex shader.
struct VertexOut {
    float4 position [[position]];  // Position in clip space
};

// Simple vertex shader function
vertex VertexOut vertex_main(uint vertexID [[vertex_id]]) {
    VertexOut vertexOut;

    // Setting a default position, it won't actually render any visible geometry.
    vertexOut.position = float4(0, 0, 0, 1);

    return vertexOut;
}

// Simple fragment shader function
fragment float4 fragment_main() {
    // Output black color - RGBA
    return float4(0, 0, 0, 1);
}






