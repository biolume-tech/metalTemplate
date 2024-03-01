import SwiftUI
import MetalKit

struct MetalView: View {
    @State private var metalView = MTKView()
    @State private var renderer: Renderer?

    var body: some View {
        MetalViewRepresentable(metalView: $metalView)
            .onAppear {
                setupMetalView()
            }
    }

    private func setupMetalView() {
        metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        renderer = Renderer(metalView: metalView)
        if renderer == nil {
            // Handle Renderer initialization failure appropriately here
            print("Failed to initialize Renderer.")
        }
    }
}

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
#endif

struct MetalViewRepresentable: ViewRepresentable {
    @Binding var metalView: MTKView

#if os(macOS)
    func makeNSView(context: Context) -> some NSView {
        metalView.preferredFramesPerSecond = 60 // keeps your original frame rate for macOS
        return metalView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {}
#elseif os(iOS)
    func makeUIView(context: Context) -> MTKView {
        metalView.preferredFramesPerSecond = 120 // keeps your original frame rate for iOS
        return metalView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {}
#endif
}
