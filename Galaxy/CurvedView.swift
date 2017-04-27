import UIKit

class CurvedView: UIView {

    /// Initializes a curvedView with a curveHeight
    convenience init(frame: CGRect, curveHeight: CGFloat) {
        self.init(frame: frame)
        // Set the background color so it can be used as a mask
        self.backgroundColor = .white
        // Render the curve
        self.renderCurve(with: curveHeight)
    }

    private func renderCurve(with height: CGFloat) {
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()

        // Rect drawn from the curve to bottom of the view
        var maskRect: CGRect = self.bounds
        maskRect.origin.y += height

        // Add the mask paths
        path.addRect(maskRect)
        path.move(to: CGPoint(x: 0, y: height))
        path.addQuadCurve(to: CGPoint(x: self.bounds.width, y: height),
                          control: CGPoint(x: self.center.x, y: -height))

        // Set the maskLayer's path
        maskLayer.path = path
        
        // Mask view with the maskLayer
        self.layer.mask = maskLayer
    }
}
