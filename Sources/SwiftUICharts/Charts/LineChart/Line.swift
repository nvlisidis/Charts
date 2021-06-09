import SwiftUI

/// A single line of data, a view in a `LineChart`
public struct Line: View {
    @EnvironmentObject var chartValue: ChartValue
    @ObservedObject var chartData: ChartData

    var style: ChartStyle

    @State private var showIndicator: Bool = false
    @State private var touchLocation: CGPoint = .zero
    @State private var showBackground: Bool = true
    @State private var didCellAppear: Bool = false

    var curvedLines: Bool = true
    
	/// The content and behavior of the `Line`.
	/// Draw the background if showing the full line (?) and the `showBackground` option is set. Above that draw the line, and then the data indicator if the graph is currently being touched.
	/// On appear, set the frame so that the data graph metrics can be calculated. On a drag (touch) gesture, highlight the closest touched data point.
	/// TODO: explain rotation
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                if self.didCellAppear && self.showBackground {
                    LineBackgroundShapeView(chartData: chartData,
                                            geometry: geometry,
                                            style: style)
                }
                LineShapeView(chartData: chartData,
                              geometry: geometry,
                              style: style,
                              trimTo: didCellAppear ? 1.0 : 0.0)
                    .animation(.easeIn)
//                if self.showIndicator {
//                    IndicatorPoint()
//                        .position(self.getClosestPointOnPath(touchLocation: self.touchLocation))
//                        .rotationEffect(.degrees(180), anchor: .center)
//                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
//                }
            }
            .onAppear {
                didCellAppear = true
            }
            .onDisappear() {
                didCellAppear = false
            }
			
            .gesture(DragGesture()
                .onChanged({ value in
                    self.touchLocation = value.location
                    self.showIndicator = true
//                    self.getClosestDataPoint(point: self.getClosestPointOnPath(touchLocation: value.location))
                    self.chartValue.interactionInProgress = true
                })
                .onEnded({ value in
                    self.touchLocation = .zero
                    self.showIndicator = false
                    self.chartValue.interactionInProgress = false
                })
            )
        }
    }
}

// MARK: - Private functions

//extension Line {
//	/// Calculate point closest to where the user touched
//	/// - Parameter touchLocation: location in view where touched
//	/// - Returns: `CGPoint` of data point on chart
//    private func getClosestPointOnPath(touchLocation: CGPoint) -> CGPoint {
//        let closest = self.path.point(to: touchLocation.x)
//        return closest
//    }
//
//	/// Figure out where closest touch point was
//	/// - Parameter point: location of data point on graph, near touch location
//    private func getClosestDataPoint(point: CGPoint) {
//        let index = Int(round((point.x)/step.x))
//        if (index >= 0 && index < self.chartData.data.count){
//            self.chartValue.currentValue = self.chartData.points[index]
//        }
//    }
//}

struct Line_Previews: PreviewProvider {
    /// Predefined style, black over white, for preview
    static let blackLineStyle = ChartStyle(backgroundColor: ColorGradient(.white), foregroundColor: ColorGradient(.black))

    /// Predefined style red over white, for preview
    static let redLineStyle = ChartStyle(backgroundColor: .whiteBlack, foregroundColor: ColorGradient(.red))

    static var previews: some View {
        Group {
            Line(chartData:  ChartData([8, 23, 32, 7, 23, -4]), style: blackLineStyle)
            Line(chartData:  ChartData([8, 23, 32, 7, 23, 43]), style: redLineStyle)
        }
    }
}
