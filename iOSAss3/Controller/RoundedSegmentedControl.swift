//
//  RoundedSegmentedControl.swift
//  iOSAss3
//
//  Created by John Wang on 11/5/2023.
//

import UIKit

class RoundedSegmentedControl: UISegmentedControl {
    
    @IBInspectable var cornerRadius: CGFloat = 8.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let selectedSegmentIndex = self.selectedSegmentIndex
        if let segmentBackgroundImage = self.backgroundImage(for: .selected, barMetrics: .default) {
            for i in 0 ..< self.numberOfSegments {
                if let segment = self.subviewForSegment(at: i) {
                    segment.layer.cornerRadius = cornerRadius
                    segment.layer.masksToBounds = true
                    
                    if i == selectedSegmentIndex {
                        segment.backgroundColor = segmentBackgroundImage.averageColor
                    } else {
                        segment.backgroundColor = nil
                    }
                }
            }
        }
    }
    
    private func subviewForSegment(at index: Int) -> UIView? {
        let segmentWidth = self.bounds.width / CGFloat(self.numberOfSegments)
        let segmentFrame = CGRect(x: CGFloat(index) * segmentWidth, y: 0, width: segmentWidth, height: self.bounds.height)
        
        for subview in self.subviews {
            if subview.frame.equalTo(segmentFrame) {
                return subview
            }
        }
        return nil
    }
}

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: NSNull()])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}
