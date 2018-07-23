//: Playground - noun: a place where people can play

import UIKit

let image = UIImage(named: "sample")

// Process the image!

public class ImageProcessor {
    public var myUIImage: UIImage {
        get {
            return myRGBA.toUIImage()!
        }
        set (newImage) {
            myRGBA = RGBAImage(image: newImage)!
        }
    }
    var myRGBA: RGBAImage
    
    public init(image: UIImage) {
        myRGBA = RGBAImage(image: image)!
        myUIImage = image
    }
    
    //Increases the brightness of the image additively
    public func brighten(factor: Double) {
        for y in 0..<myRGBA.height {
            for x in 0..<myRGBA.width {
                let index = y * myRGBA.width + x
                var pixel = myRGBA.pixels[index]
                pixel.red = UInt8(max(0, min(255, Double(pixel.red) + factor) ) )
                pixel.green = UInt8(max(0, min(255, Double(pixel.green) + factor) ) )
                pixel.blue = UInt8(max(0, min(255, Double(pixel.blue) + factor) ) )
                myRGBA.pixels[index] = pixel
            }
        }
    }
    
    //Finds the grayscale value of a given pixel
    public func findGrayscaleValue(pixel: Pixel) -> Double {
        //Coefficients are based on how sensitive the human eye is to each color
        return (0.21 * Double(pixel.red)) + (0.72 * Double(pixel.green)) + (0.07 * Double(pixel.blue))
    }
    
    // Desaturates the image. Entering a value of 1 for factor will completely convert the image to grayscale. Entering a negative value for factor will increase the saturation
    public func desaturate(factor: Double) {
        for y in 0..<myRGBA.height {
            for x in 0..<myRGBA.width {
                let index = y * myRGBA.width + x
                var pixel = myRGBA.pixels[index]
                let grayscaleValue = findGrayscaleValue(pixel)
                let red = max(0,min(255,(factor * grayscaleValue) + ((1 - factor) * Double(pixel.red))))
                let green = max(0,min(255,(factor * grayscaleValue) + ((1 - factor) * Double(pixel.green))))
                let blue = max(0,min(255,(factor * grayscaleValue) + ((1 - factor) * Double(pixel.blue))))
                pixel.red = UInt8(red)
                pixel.green = UInt8(green)
                pixel.blue = UInt8(blue)
                myRGBA.pixels[index] = pixel
            }
        }
    }
    
    // Modifies the exposure in the image. Entering a negative value for factor decreases the exposure
    public func increaseExposure(factor: Double) {
        for y in 0..<myRGBA.height {
            for x in 0..<myRGBA.width {
                let index = y * myRGBA.width + x
                var pixel = myRGBA.pixels[index]
                pixel.red = UInt8(max(0, min(255, Double(pixel.red) * pow(2, factor)) ) )
                pixel.green = UInt8(max(0, min(255, Double(pixel.green) * pow(2, factor)) ) )
                pixel.blue = UInt8(max(0, min(255, Double(pixel.blue) * pow(2, factor)) ) )
                myRGBA.pixels[index] = pixel
            }
        }
    }
    
    // Modifies the contrast in the image (dark colors get darker, light colors get lighter). Entering a negative value for level decreases the contrast
    public func increaseContrast(level: Double) {
        for y in 0..<myRGBA.height {
            for x in 0..<myRGBA.width {
                let index = y * myRGBA.width + x
                var pixel = myRGBA.pixels[index]
                let factor = (259 * (level + 255))/(255 * (259 - level))
                let red = (factor * (Double(pixel.red) - 128)) + 128
                let green = (factor * (Double(pixel.green) - 128)) + 128
                let blue = (factor * (Double(pixel.blue) - 128)) + 128
                pixel.red = UInt8(max(0, min(255, red) ) )
                pixel.green = UInt8(max(0, min(255, green) ) )
                pixel.blue = UInt8(max(0, min(255, blue) ) )
                myRGBA.pixels[index] = pixel
            }
        }
    }
    
    // Helper function that returns the new value that a color value should be set to given the number of ranges in posterization
    public func getPosterizedValue(val: UInt8, numRanges: Int) -> UInt8 {
        let step = 256 / numRanges
        var newVal = val
        var done = false
        var i = step
        while(!done && i < 256) {
            if(Int(val) < i) {
                newVal = UInt8(i - step)
                done = true
            }
            i += step
        }
        return newVal
    }
    
    // Sets all color values within a certain ranges to the lowest value within that range so that the image resembles a graphic poster
    public func posterize(numRanges: Int) {
        for y in 0..<myRGBA.height {
            for x in 0..<myRGBA.width {
                let index = y * myRGBA.width + x
                var pixel = myRGBA.pixels[index]
                pixel.red = getPosterizedValue(pixel.red, numRanges: numRanges)
                pixel.green = getPosterizedValue(pixel.green, numRanges: numRanges)
                pixel.blue = getPosterizedValue(pixel.blue, numRanges: numRanges)
                myRGBA.pixels[index] = pixel
            }
        }
    }
    
    public func filter(filterName: String)  -> UIImage {
        switch filterName {
        case "Brighten":
            brighten(64)
        case "Desaturate":
            desaturate(1)
        case "Increase Exposure":
            increaseExposure(0.5)
        case "Increase Contrast":
            increaseContrast(100)
        case "Posterize":
            posterize(8)
        default:
            print("Bad input")
        }
        return myRGBA.toUIImage()!
    }
}

var img = ImageProcessor(image: image!)
img.filter("Enter Filter Name Here")
