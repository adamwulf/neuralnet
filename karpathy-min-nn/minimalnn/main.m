//
//  main.m
//  minimalnn
//
//  Created by Adam Wulf on 7/8/15.
//
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <Accelerate/Accelerate.h>
#include "randn.h"

// port of http://cs231n.github.io/neural-networks-case-study/

CGFloat* linspace(CGFloat min, CGFloat max, int count){
    return NULL;
}

CGFloat linspaceat(CGFloat start, CGFloat stop, int count, int at){
    CGFloat diff = stop - start;
    CGFloat step = diff / (count-1);
    return start + step * at;
}

NSColor* randomColor(){
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [NSColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

NSImage* plot(CGFloat* data, int count, int classes){
    NSSize size = NSMakeSize(600, 600);
    NSImage *output = [[NSImage alloc] initWithSize:size];
    [output lockFocus];
    
    [[NSColor whiteColor] setFill];
    [[NSBezierPath bezierPathWithRect:NSMakeRect(0,0, size.width, size.height)] fill];
    
    for(int k=0;k<classes;k++){
        [randomColor() setFill];
        for (int i=k*count; i<(k+1)*count; i++) {
            CGFloat x = data[i+0] * size.width/2 + size.width/2;
            CGFloat y = data[i+classes*count] * size.height/2 + size.height/2;
            [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(x-2, y-2, 4, 4)] fill];
        }
    }

    [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(150, 150, 4, 4)] fill];

    [output unlockFocus];
    return output;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // http://cs231n.github.io/neural-networks-case-study/
        
        //Generating some data
        
        const NSUInteger N  = 100; // number of data points
        const NSUInteger D = 2;
        const NSUInteger K = 3;
        
        // X = [[rx, rx, rx, bx, bx, bx, gx, gx, gx],
        //      [ry, ry, ry, by, by, by, gy, gy, gy]];
        //
        
        
        CGFloat X[D][N*K];
        NSUInteger y[N*K];

        for(int k=0;k<K;k++){
            for(int n=0;n<N;n++){
                int ix=N*k + n;
                for(int d=0;d<D;d++){
                    CGFloat r = linspaceat(0,1,N,n);
                    CGFloat t = linspaceat(k*4,(k+1)*4,N,n)+randn(0, .2);
                    if(d == 0){
                        CGFloat foo = r * sin(t);
                        X[d][ix] = foo;
                    }else{
                        CGFloat foo = r * cos(t);
                        X[d][ix] = foo;
                    }
                    y[ix] = k;
                }
            }
        }
        
        // save image to verify
        
        NSString* path = @"/Users/adam/Screenshots/foo.png";
        NSImage* image = plot((CGFloat*)X, N, K);
        [image lockFocus];
        NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, image.size.width, image.size.height)];
        [image unlockFocus];
        
        [[bitmapRep representationUsingType:NSPNGFileType properties:Nil] writeToFile:path atomically:YES];
        
        
        
        // Training a Softmax Linear Classifier
        // Initialize the parameters
        
        // W = [[ rx, bx, gx ],
        //      [ ry, by, gy ]];
        
        CGFloat W[D][K];
        CGFloat b[1][K] = {0};
        
        for(int d=0;d<D;d++){
            for(int k=0;k<K;k++){
                W[d][k] = randn(0, .01);
            }
        }
        
        CGFloat scores[300][3];
        
        vDSP_dotpr(X, 1, W, 1, scores, N*K);
        
        
        for(int k=0;k<K;k++){
            for(int n=0;n<N;n++){
                NSLog(@"(%d %d)=%f", k, n, scores[n][k]);
            }
        }
        
        
    }
    return 0;
}

CGFloat dotProduct(CGFloat[300] X, CGFloat[300]W)
