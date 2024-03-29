//
//  Chart.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/11/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import UIKit
import QuartzCore

// delegate method
public protocol ChartDelegate {
    func didSelectDataPoint(_ chart: Chart, _ x: CGFloat, yValues: [CGFloat], _ needShow: Bool)
    func drawIsFinished(_ chart: Chart)
}

open class Chart: UIView {

    public struct Labels {
        public var visible: Bool = true
        public var visibleCount = 10
        public var textColor = UIColor.white
        public var values: [String] = []
    }

    public struct Grid {
        public var visible: Bool = true
        public var count: CGFloat = 10
        public var color: UIColor = .black
    }

    public struct Axis {
        public var visible: Bool = true
        public var color = UIColor.white
        public var inset: CGFloat = 15
    }

    public struct Coordinate {
        // public
        public var labels: Labels = Labels()
        public var grid: Grid = Grid()
        public var axis: Axis = Axis()

        // private
        fileprivate var linear: LinearScale!
        fileprivate var scale: ((CGFloat) -> CGFloat)!
        fileprivate var invert: ((CGFloat) -> CGFloat)!
        fileprivate var ticks: (CGFloat, CGFloat, CGFloat)!
    }

    public struct Dots {
        public var visible: Bool = true
        public var colorDay: UIColor = UIColor.white
        public var colorNight: UIColor = UIColor.white
        public var innerRadius: CGFloat = 6
        public var outerRadius: CGFloat = 10
        public var innerRadiusHighlighted: CGFloat = 6
        public var outerRadiusHighlighted: CGFloat = 10
        public var innerColor: UIColor {
            set {}
            get {
                return Settings.shared.currentTheme == .day ? colorDay : colorNight
            }
        }
    }

    // default configuration
    open var dots: Dots = Dots()
    open var lineWidth: CGFloat = 2
    open var x: Coordinate = Coordinate()
    open var y: Coordinate = Coordinate()

    open var rangeToShow: Range<Int>? {
        didSet {
            guard let _ = oldValue else { return }
            draw(self.frame)
        }
    }

    // values calculated on init
    fileprivate var drawingHeight: CGFloat = 0 {
        didSet {
            guard let max = getMaximumYvalue(),
                  let min = getMinimumYvalue() else {return}

            y.linear = LinearScale(domain: [min, max], range: [0, drawingHeight])
            y.scale = y.linear.scale()
            y.ticks = y.linear.ticks(Int(y.grid.count))
        }
    }
    fileprivate var drawingWidth: CGFloat = 0 {
        didSet {
            let data = dataStore[0]
            x.linear = LinearScale(domain: [0.0, CGFloat(data.count - 1)], range: [0, drawingWidth])
            x.scale = x.linear.scale()
            x.invert = x.linear.invert()
            x.ticks = x.linear.ticks(Int(x.grid.count))
        }
    }

    open var delegate: ChartDelegate?

    // data stores
    fileprivate var hidingLinesIndexes = [Int]() // indexes of hiding lines
    fileprivate var linesAnimations = [Int : AnimationType]()


    fileprivate var tmpDataStore = [[CGFloat]]()
    fileprivate var dataStore: [[CGFloat]] {
        set {}
        get {
            guard let range = self.rangeToShow else { return tmpDataStore }
            var rangeDataStore = [[CGFloat]]()

            tmpDataStore.forEach { dataLine in
                let rangedLine = dataLine[range.lowerBound...range.upperBound]
                rangeDataStore.append(Array(rangedLine))
            }
            return rangeDataStore
        }
    }
    lazy fileprivate var dotsDataStore = [[DotCALayer]]()
    lazy fileprivate var cursorLinesDataStore = [[CALayer]]()
    lazy fileprivate var lineLayerStore = [Int : CAShapeLayer]()

    fileprivate var removeAll: Bool = false

    open var colors = [UIColor]()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func needShowYLayer(lineIndex: Int, needShow: Bool) {

        guard let layerToMove = lineLayerStore[lineIndex] else {return}

        if(needShow) {
            hidingLinesIndexes.removeAll(where: { $0 == lineIndex })
            linesAnimations[lineIndex] = AnimationType.upToCurrent
        } else {
            layerToMove.removeFromSuperlayer()
            hidingLinesIndexes.append(lineIndex)
        }

        draw(frame)
    }

    private func getColor(byIndex index: Int) -> UIColor {
        if index > self.colors.count - 1 {
            return .black
        }
        return self.colors[index]
    }

    // draw chart
    //
    //
    override open func draw(_ rect: CGRect) {

        guard !dataStore.isEmpty else { return }

        if removeAll {
            let context = UIGraphicsGetCurrentContext()
            context?.clear(rect)
            return
        }

        self.drawingHeight = self.bounds.height - (2 * y.axis.inset)
        self.drawingWidth = self.bounds.width - (2 * x.axis.inset)

        // remove all labels
        for view: AnyObject in self.subviews {
            view.removeFromSuperview()
        }

        // remove all lines on device rotation
        lineLayerStore.values.forEach {
            $0.removeFromSuperlayer()
        }
        lineLayerStore.removeAll()

        // remove all dots on device rotation
        dotsDataStore.forEach {
            $0.forEach {
                $0.removeFromSuperlayer()
            }
        }

        // remove cursor lines
        cursorLinesDataStore.forEach {
            $0.forEach {
                $0.removeFromSuperlayer()
            }
        }

        dotsDataStore.removeAll()
        cursorLinesDataStore.removeAll()

        // draw grid
        if x.grid.visible && y.grid.visible { drawGrid() }

        // draw axes
        if x.axis.visible && y.axis.visible { drawAxes() }

        // draw labels
        if x.labels.visible { drawXLabels() }
        if y.labels.visible { drawYLabels() }

        // draw lines
        for (lineIndex, _) in dataStore.enumerated() {
            drawLine(lineIndex)

            // draw dots
            if dots.visible { createDotsDataSource(lineIndex) }
        }

        delegate?.drawIsFinished(self)
    }



    // get y value for given x value. Or return zero or maximum value.
    //
    //
    fileprivate func getYValuesForXValue(_ x: Int) -> [CGFloat] {
        var result: [CGFloat] = []

        for (index, lineData) in dataStore.enumerated() {
            if (index == 0) {
                continue // 0 это шкала X
            }

            if hidingLinesIndexes.contains(index) { // линия скрыта
                result.append(-1)
                continue
            }

            if x < 0 {
                result.append(lineData[0])
            } else if x > lineData.count - 1 {
                result.append(lineData[lineData.count - 1])
            } else {
                result.append(lineData[x])
            }
        }
        return result
    }

    fileprivate func handleTouchEvents(_ touches: NSSet, touchEnded: Bool = false) {
        if (self.dataStore.isEmpty) {
            return
        }

        guard let point = touches.anyObject() as? UITouch else { return }

        let xValue = point.location(in: self).x
        let inverted = self.x.invert(xValue - x.axis.inset)
        let rounded = Int(round(Double(inverted)))
        let yValues: [CGFloat] = getYValuesForXValue(rounded)

        drawDot(rounded, touchEnded)

        var needShowInfoWindow = false
        yValues.forEach { // если все Y значения -1 все линии скрыты
            if ($0 > 0) {
                needShowInfoWindow = true
            }
        }

        if needShowInfoWindow {
            delegate?.didSelectDataPoint(self, CGFloat(rounded), yValues: yValues, !touchEnded)
        }
    }

    // touch events
    //
    //
    func getIndexesRangeByPoints(_ pointsRange: Range<CGFloat>) -> Range<Int>? {
        if (self.dataStore.isEmpty) {
            return nil
        }

        let start = self.x.invert(pointsRange.lowerBound - x.axis.inset)
        let end = self.x.invert(pointsRange.upperBound - x.axis.inset)

        var roundedStart = Int(round(Double(start)))
        if (roundedStart < 0) {
            roundedStart = 0
        }

        var roundedEnd = Int(round(Double(end)))
        if (roundedEnd > dataStore[0].count - 1) {
            roundedEnd = dataStore[0].count - 1
        }

        return Range<Int>(uncheckedBounds: (roundedStart, roundedEnd))
    }

    // touch ended
    //
    //
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouchEvents(touches as NSSet, touchEnded: true)
    }

    // touch moved
    //
    //
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouchEvents(touches as NSSet)
    }

    // create dots data source
    //
    //
    fileprivate func createDotsDataSource(_ lineIndex: Int) {

        var dotLayers: [DotCALayer] = []
        var lineLayers: [CALayer] = []

        var data = self.dataStore[lineIndex]

        for index in 0..<data.count {
            let xValue = self.x.scale(CGFloat(index)) + x.axis.inset - dots.outerRadius/2
            let yValue = self.bounds.height - self.y.scale(data[index]) - y.axis.inset - dots.outerRadius/2

            // draw custom layer with another layer in the center
            let dotLayer = DotCALayer()
            let lineLayer = CALayer()

            dotLayer.dotInnerColor = (Settings.shared.currentTheme == .day ? dots.colorDay : dots.colorNight)
            dotLayer.backgroundColor = getColor(byIndex: lineIndex).cgColor

            dotLayer.innerRadius = dots.innerRadius
            dotLayer.cornerRadius = dots.outerRadius / 2
            dotLayer.frame = CGRect(x: xValue, y: yValue, width: dots.outerRadius, height: dots.outerRadius)
            dotLayers.append(dotLayer)

            // create cursor line
            lineLayer.frame = CGRect(x: dotLayer.frame.origin.x + dotLayer.frame.width / 2,
                    y: 0,
                    width: 0.5,
                    height: frame.size.height - y.axis.inset)
            lineLayer.backgroundColor = UIColor.lightGray.cgColor
            lineLayers.append(lineLayer)
        }

        cursorLinesDataStore.append(lineLayers)
        dotsDataStore.append(dotLayers)

    }

    // draw dot
    //
    //
    fileprivate func drawDot(_ dotIndex: Int, _ needRemoveAll: Bool = false) {
        for (index, dots) in dotsDataStore.enumerated() {

            // remove all cursor lines
            let lineDataStore = cursorLinesDataStore[index]
            lineDataStore.forEach {
                $0.removeFromSuperlayer()
            }

            // make all dots white again
            dots.forEach {
                $0.removeFromSuperlayer()
            }

            if needRemoveAll || index == 0 || hidingLinesIndexes.contains(index) {
                continue
            }

            // add dot from dotsData
            var dot: DotCALayer
            var line: CALayer?

            if dotIndex < 0 {
                dot = dots[0]
                line = lineDataStore[0]
            } else if dotIndex > dots.count - 1 {
                dot = dots[dots.count - 1]
                line = lineDataStore[dots.count - 1]
            } else {
                dot = dots[dotIndex]
                line = lineDataStore[dotIndex]
            }

            // add line
            if let lineLayer = line {self.layer.insertSublayer(lineLayer, at: 0)}

            // add dot
            self.layer.addSublayer(dot)
        }
    }

    // draw Axes
    //
    //
    fileprivate func drawAxes() {
        let height = self.bounds.height
        let width = self.bounds.width
        let path = UIBezierPath()
        // draw x-axis
        x.axis.color.setStroke()
        let y0 = height - self.y.scale(0) - y.axis.inset
        path.move(to: CGPoint(x: x.axis.inset, y: y0))
        path.addLine(to: CGPoint(x: width - x.axis.inset, y: y0))
        path.stroke()
        // draw y-axis
        y.axis.color.setStroke()
        path.move(to: CGPoint(x: x.axis.inset, y: height - y.axis.inset))
        path.addLine(to: CGPoint(x: x.axis.inset, y: y.axis.inset))
        path.stroke()
    }

    // get maximum value in all 'Y' arrays in data store.
    //
    //
    fileprivate func getMaximumYvalue() -> CGFloat? {
        var max: CGFloat?
        for (index, data) in dataStore.enumerated() {
            if (index == 0 || hidingLinesIndexes.contains(index)) { continue }
            if (max == nil) {
                max = data.max() ?? 0
                continue
            }

            let newMax = data.max() ?? max!
            if newMax > max! {
                max = newMax
            }
        }
        return max
    }

    // get minimum value in all 'Y' arrays in data store.
    //
    //
    fileprivate func getMinimumYvalue() -> CGFloat? {
        var min: CGFloat?
        for (index, data) in dataStore.enumerated() {
            if (index == 0 || hidingLinesIndexes.contains(index)) { continue }
            if min == nil {
                min = data.min() ?? 0
                continue
            }

            let newMin = data.min() ?? min!
            if newMin < min! {
                min = newMin
            }
        }
        return min
    }

    // draw line
    //
    //
    fileprivate func drawLine(_ lineIndex: Int) {

        var data = self.dataStore[lineIndex]

        let path = UIBezierPath()
        let textPath = UIBezierPath()

        var xValue = self.x.scale(0) + x.axis.inset
        var yValue = self.bounds.height - self.y.scale(data[0]) - y.axis.inset

        path.move(to: CGPoint(x: xValue, y: yValue))

        textPath.move(to: CGPoint(x: xValue, y: yValue))

        for index in 1..<data.count {
            xValue = self.x.scale(CGFloat(index)) + x.axis.inset
            yValue = self.bounds.height - self.y.scale(data[index]) - y.axis.inset
            path.addLine(to: CGPoint(x: xValue, y: yValue))
        }


        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path.cgPath

        if(lineIndex != 0) {
            layer.strokeColor = getColor(byIndex: lineIndex).cgColor
        }

        layer.fillColor = nil
        layer.lineWidth = lineWidth

        // отобржаем леер если его нет в списке скрытых
        if !hidingLinesIndexes.contains(lineIndex) {
            self.layer.addSublayer(layer)
        }

        // добавляем анимацию
        if let animationType = linesAnimations[lineIndex] {
            layer.addAnimation(animationType)
            linesAnimations.removeValue(forKey: lineIndex)
        }

        // add line layer to store
        lineLayerStore[lineIndex] = layer
    }

    func drawString(_ index: Int) {

        let xValue = self.x.scale(CGFloat(index)) + x.axis.inset

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 12.0),
            .foregroundColor: UIColor.white
        ]

        let myText = "H"
        let attributedString = NSAttributedString(string: myText, attributes: attributes)

        let stringRect = CGRect(x: xValue, y: frame.height / 2, width: 30, height: 20)
        attributedString.draw(in: stringRect)
    }

    // draw x grid.
    //
    //
    fileprivate func drawXGrid() {
        x.grid.color.setStroke()
        let path = UIBezierPath()
        var x1: CGFloat
        let y1: CGFloat = self.bounds.height - y.axis.inset
        let y2: CGFloat = y.axis.inset
        let (start, stop, step) = self.x.ticks
        for i in stride(from: start, through: stop, by: step){
            x1 = self.x.scale(i) + x.axis.inset
            path.move(to: CGPoint(x: x1, y: y1))
            path.addLine(to: CGPoint(x: x1, y: y2))
        }
        path.stroke()
    }

    // draw y grid.
    //
    //
    fileprivate func drawYGrid() {
        let gridCount = Int(self.y.grid.count)
        guard gridCount > 0 else { return }

        let path = UIBezierPath()

        path.lineWidth = 0.5
        let x1: CGFloat = x.axis.inset
        let x2: CGFloat = self.bounds.width - x.axis.inset
        let height = frame.height / CGFloat(gridCount)
        var y1: CGFloat = height * 0.7 // 0.7 с учетом Label

        for _ in 1...gridCount {
            path.move(to: CGPoint(x: x1, y: y1))
            path.addLine(to: CGPoint(x: x2, y: y1))
            y1 += height
        }

        (Settings.shared.currentTheme == .day ? UIColor.lightGray : UIColor.black).setStroke()
        path.stroke()
    }

    // draw grid.
    //
    //
    fileprivate func drawGrid() {
        drawXGrid()
        drawYGrid()
    }

    // draw x labels.
    //
    //
    fileprivate func drawXLabels() {

        let visibleCount = x.labels.visibleCount
        var xLabels = x.labels.values

        guard visibleCount > 0,
              !xLabels.isEmpty else {return}

        if let range = self.rangeToShow {
            let rangedLabels = xLabels[range.lowerBound...range.upperBound]
            xLabels = Array(rangedLabels)
        }

        let width = frame.width / CGFloat(visibleCount)
        let height = width / 4
        var xValue: CGFloat = 0
        let yValue = self.bounds.height - x.axis.inset

        for index in 1...visibleCount {

            if index != 1 {
                xValue += width
            }

            let label = UILabel(frame: CGRect(x: xValue, y: yValue, width: width, height: height))
            label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption2)
            label.textColor = x.labels.textColor
            label.textAlignment = .center

            let labelCenterX = (index == 1 ? width : xValue) - CGFloat(width / 2)
            let xLabelIndex = getIndexByXCoordinate(labelCenterX)
            label.text = xLabels[xLabelIndex]

            UIView.animate(withDuration: 1, animations: {
                self.addSubview(label)
            })
        }
    }

    // draw y labels.
    //
    //
    fileprivate func drawYLabels() {

        guard let maxY = getMaximumYvalue(),
              let minY = getMinimumYvalue() else { return }

        let visibleCount = y.labels.visibleCount

        let delta = maxY - minY
        let tick = delta / CGFloat(visibleCount)

        guard visibleCount > 0,
              delta > 0 else {return}

        let height = frame.height / CGFloat(visibleCount)
        let width = height / 2

        var yValue: CGFloat = 0.0
        let xValue: CGFloat = 0.0


        for index in 1...visibleCount {

            let value = (index == 1) ? maxY : (maxY - tick * CGFloat(index))

            let label = UILabel(frame: CGRect(x: xValue, y: yValue, width: width, height: height))
            label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption2)
            label.textColor = y.labels.textColor
            label.textAlignment = .left
            label.text = String(Int(value))

            yValue += height

            addSubview(label)
        }
    }

    fileprivate func getIndexByXCoordinate(_ x: CGFloat) -> Int {
        if (self.dataStore.isEmpty) {
            return 0
        }
        let index = self.x.invert(x)
        return Int(round(Double(index)))
    }

    // add line chart
    //
    //
    open func addLine(_ data: [CGFloat]) {
        self.tmpDataStore.append(data)
        self.setNeedsDisplay()
    }

    // make whole thing white again.
    //
    //
    open func clearAll() {
        self.removeAll = true
        clear()
        self.setNeedsDisplay()
        self.removeAll = false
    }

    // remove charts, areas and labels but keep axis and grid.
    //
    //
    open func clear() {
        // clear data
        tmpDataStore.removeAll()
        self.setNeedsDisplay()
    }
}

/**
 * DotCALayer
 */
class DotCALayer: CALayer {

    var innerRadius: CGFloat = 8
    var dotInnerColor = UIColor.clear

    override init() {
        super.init()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSublayers() {
        super.layoutSublayers()
        let inset = self.bounds.size.width - innerRadius

        let innerDotLayer = CALayer()
        innerDotLayer.frame = self.bounds.insetBy(dx: inset/2, dy: inset/2)
        innerDotLayer.cornerRadius = innerRadius / 2
        innerDotLayer.backgroundColor = dotInnerColor.cgColor

        self.addSublayer(innerDotLayer)
    }
}


/**
 * LinearScale
 */
open class LinearScale {

    var domain: [CGFloat]
    var range: [CGFloat]

    public init(domain: [CGFloat] = [0, 1], range: [CGFloat] = [0, 1]) {
        self.domain = domain
        self.range = range
    }

    open func scale() -> (_ x: CGFloat) -> CGFloat {
        return bilinear(domain, range: range, uninterpolate: uninterpolate, interpolate: interpolate)
    }

    open func invert() -> (_ x: CGFloat) -> CGFloat {
        return bilinear(range, range: domain, uninterpolate: uninterpolate, interpolate: interpolate)
    }

    open func ticks(_ m: Int) -> (CGFloat, CGFloat, CGFloat) {
        return scale_linearTicks(domain, m: m)
    }

    fileprivate func scale_linearTicks(_ domain: [CGFloat], m: Int) -> (CGFloat, CGFloat, CGFloat) {
        return scale_linearTickRange(domain, m: m)
    }

    fileprivate func scale_linearTickRange(_ domain: [CGFloat], m: Int) -> (CGFloat, CGFloat, CGFloat) {
        var extent = scaleExtent(domain)
        let span = extent[1] - extent[0]
        var step = CGFloat(pow(10, floor(log(Double(span) / Double(m)) / M_LN10)))
        let err = CGFloat(m) / span * step

        // Filter ticks to get closer to the desired count.
        if (err <= 0.15) {
            step *= 10
        } else if (err <= 0.35) {
            step *= 5
        } else if (err <= 0.75) {
            step *= 2
        }

        // Round start and stop values to step interval.
        let start = ceil(extent[0] / step) * step
        let stop = floor(extent[1] / step) * step + step * 0.5 // inclusive

        return (start, stop, step)
    }

    fileprivate func scaleExtent(_ domain: [CGFloat]) -> [CGFloat] {
        let start = domain[0]
        let stop = domain[domain.count - 1]
        return start < stop ? [start, stop] : [stop, start]
    }

    fileprivate func interpolate(_ a: CGFloat, b: CGFloat) -> (_ c: CGFloat) -> CGFloat {
        var diff = b - a
        func f(_ c: CGFloat) -> CGFloat {
            return (a + diff) * c
        }
        return f
    }

    fileprivate func uninterpolate(_ a: CGFloat, b: CGFloat) -> (_ c: CGFloat) -> CGFloat {
        var diff = b - a
        var re = diff != 0 ? 1 / diff : 0
        func f(_ c: CGFloat) -> CGFloat {
            return (c - a) * re
        }
        return f
    }

    fileprivate func bilinear(_ domain: [CGFloat], range: [CGFloat], uninterpolate: (_ a: CGFloat, _ b: CGFloat) -> (_ c: CGFloat) -> CGFloat, interpolate: (_ a: CGFloat, _ b: CGFloat) -> (_ c: CGFloat) -> CGFloat) -> (_ c: CGFloat) -> CGFloat {
        var u: (_ c: CGFloat) -> CGFloat = uninterpolate(domain[0], domain[1])
        var i: (_ c: CGFloat) -> CGFloat = interpolate(range[0], range[1])
        func f(_ d: CGFloat) -> CGFloat {
            return i(u(d))
        }
        return f
    }
}

extension Chart: ThemeProtocol {

    func themeDidChange(_ animation: Bool = false) {
        self.draw(self.frame)
    }

}
