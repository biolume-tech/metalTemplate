import SwiftUI

struct ContentView: View {
    
    //  @State private var hideStatusBar = true         // UNCOMMENT TO hide status bar (iOS only)
    
    
    @State private var renderer: Renderer?
    
    @State private var hideCursorTimer: Timer?
    
    var body: some View {
        VStack {
            MetalView()
        }
        .onAppear() {
            setupCursorHiding()                              // UNCOMMENT TO hide cursor (MacOS only)
        }
        
        //      .statusBar(hidden: hideStatusBar)            // UNCOMMENT TO hide status bar (iOS only)
        //      .persistentSystemOverlays(.hidden)           // UNCOMMENT TO hide other overlays (iOS only)
    }
    
    private func setupCursorHiding() {
        NSCursor.hide() // Initially hide the cursor
        
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { event in
            self.resetCursorHideTimer()
            return event
        }
        
    }
    
    private func resetCursorHideTimer() {
        NSCursor.unhide()
        
        hideCursorTimer?.invalidate()
        hideCursorTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            NSCursor.hide()}
    }
    
}
