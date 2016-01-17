//
//  ViewController.swift
//  Example2-1
//
//  Created by Alsey Coleman Miller on 1/17/16.
//  Copyright © 2016 ColemanCDA. All rights reserved.
//

import UIKit
import GLKit

final class ViewController: GLKViewController {
    
    // MARK: - Properties
    
    var baseEffect: GLKBaseEffect!
    
    private var vertexBufferID: GLuint = 0
    
    // MARK: - Loading

    /// Called when the view controller's view is loaded
    /// Perform initialization before the view is asked to draw
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Verify the type of view created automatically by the Interface Builder storyboard
        guard let view = self.view as? GLKView
            else { fatalError("View controller's view is not a GLKView") }
        
        // Create an OpenGL ES 2.0 context and provide it to the view
        view.context = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        
        // Make the new context current
        EAGLContext.setCurrentContext(view.context)
        
        // Create a base effect that provides standard OpenGL ES 2.0
        // Shading Language programs and set constants to be used for
        // all subsequent rendering
        self.baseEffect = GLKBaseEffect()
        self.baseEffect.useConstantColor = GLboolean(GL_TRUE)
        self.baseEffect.constantColor = GLKVector4Make(
            1.0, // Red
            1.0, // Green
            1.0, // Blue
            1.0) // Alpha
        
        // Set the background color stored in the current context
        glClearColor(0, 0, 0, 0)
        
        // Generate, bind, and initialize contents of a buffer to be stored in GPU memory
        
        glGenBuffers(1, &vertexBufferID)                        // STEP 1
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferID)   // STEP 2
        
        glBufferData(                                           // STEP 3
            GLenum(GL_ARRAY_BUFFER),                // Initialize buffer contents
            sizeof(SceneVertex) * vertices.count,   // Number of bytes to copy
            &vertices,                              // Address of bytes to copy
            GLenum(GL_STATIC_DRAW))                 // Hint: cache in GPU memory
    }
    
    // Called when the view controller's view has been unloaded
    // Perform clean-up that is possible when you know the view
    // controller's view won't be asked to draw again soon.
    
    // `-viewDidUnload` is deprecated, using this instead
    deinit {
        
        // Make the view's context current
        let view = self.view as! GLKView
        EAGLContext.setCurrentContext(view.context)
        
        if vertexBufferID != 0 {
            
            glDeleteBuffers (1,                                 // STEP 7
                            &vertexBufferID);
            
            vertexBufferID = 0
        }
        
        // Stop using the context created in -viewDidLoad
        EAGLContext.setCurrentContext(nil)
    }
    
    // MARK: - Methods
    
    /// GLKView delegate method: Called by the view controller's view
    /// whenever Cocoa Touch asks the view controller's view to
    /// draw itself. (In this case, render into a frame buffer that
    /// shares memory with a Core Animation Layer)
    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        
        self.baseEffect.prepareToDraw()
        
        // Clear Frame Buffer (erase previous drawing)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        // Enable use of positions from bound vertex buffer
        glEnableVertexAttribArray(                              // STEP 4
            GLuint(GLKVertexAttrib.Position.rawValue))
        
        glVertexAttribPointer(                                  // STEP 5
            GLuint(GLKVertexAttrib.Position.rawValue),
            3,                              // three components per vertex
            GLenum(GL_FLOAT),               // data is floating point
            GLboolean(GL_FALSE),            // no fixed point scaling
            GLsizei(sizeof(SceneVertex)),   // no gaps in data
            nil)                            // NULL tells GPU to start at beginning of bound buffer
        
        // Draw triangles using the first three vertices in the
        // currently bound vertex buffer
        glDrawArrays(GLenum(GL_TRIANGLES),                      // STEP 6
            0,  // Start with first vertex in currently bound buffer
            3); // Use three vertices from currently bound buffer
    }
}

// MARK: - Supporting Types

/// This data type is used to store information for each vertex
struct SceneVertex {
    
    var positionCoords: GLKVector3
    
    init(_ value: (Float, Float, Float)) {
        
        self.positionCoords = GLKVector3(v: value)
    }
}

// MARK: - Constants

/// Define vertex data for a triangle to use in example
var vertices = [
    SceneVertex((-0.5, -0.5, 0.0)), // lower left corner
    SceneVertex(( 0.5, -0.5, 0.0)), // lower right corner
    SceneVertex((-0.5,  0.5, 0.0))  // upper left corner
]

