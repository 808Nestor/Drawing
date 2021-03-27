//
//  ContentView.swift
//  Drawing
//
//  Created by Nestor Trillo on 3/26/21.
//
 
import SwiftUI

struct Spirograph: Shape {
	let innerRadius: Int
	let outerRadius: Int
	let distance: Int
	let amount: CGFloat
	
	func gcd(_ a: Int, _ b: Int) -> Int {
		var a = a
		var b = b
		
		while b != 0 {
			let temp = b
			b = a % b
			a = temp
		}
		
		return a
	}
	
	func path(in rect: CGRect) -> Path {
		let divisor = gcd(innerRadius, outerRadius)
		let outerRadius = CGFloat(self.outerRadius)
		let innerRadius = CGFloat(self.innerRadius)
		let distance = CGFloat(self.distance)
		let difference = innerRadius - outerRadius
		let endPoint = ceil(2 * CGFloat.pi * outerRadius / CGFloat(divisor)) * amount
		
		var path = Path()
		
		for theta in stride(from: 0, through: endPoint, by: 0.01) {
			var x = difference * cos(theta) + distance * cos(difference / outerRadius * theta)
			var y = difference * sin(theta) - distance * sin(difference / outerRadius * theta)
			
			x += rect.width / 2
			y += rect.height / 2
			
			if theta == 0 {
				path.move(to: CGPoint(x: x, y: y))
			} else {
				path.addLine(to: CGPoint(x: x, y: y))
			}
		}
		
		return path
	}
}

struct SpirographContentView: View {
	@State private var innerRadius = 125.0
	@State private var outerRadius = 75.0
	@State private var distance = 25.0
	@State private var amount: CGFloat = 1.0
	@State private var hue = 0.6
	
	var body: some View {
		VStack(spacing: 0) {
			Spacer()
			
			Spirograph(innerRadius: Int(innerRadius), outerRadius: Int(outerRadius), distance: Int(distance), amount: amount)
				.stroke(Color(hue: hue, saturation: 1, brightness: 1), lineWidth: 1)
				.frame(width: 300, height: 300)
			
			Spacer()
			
			Group {
				Text("Inner radius: \(Int(innerRadius))")
				Slider(value: $innerRadius, in: 10...150, step: 1)
					.padding([.horizontal, .bottom])
				
				Text("Outer radius: \(Int(outerRadius))")
				Slider(value: $outerRadius, in: 10...150, step: 1)
					.padding([.horizontal, .bottom])
				
				Text("Distance: \(Int(distance))")
				Slider(value: $distance, in: 1...150, step: 1)
					.padding([.horizontal, .bottom])
				
				Text("Amount: \(amount, specifier: "%.2f")")
				Slider(value: $amount)
					.padding([.horizontal, .bottom])
				
				Text("Color")
				Slider(value: $hue)
					.padding(.horizontal)
			}
		}
	}
}

struct Flower: Shape {
	// How much to move this petal away from the center
	var petalOffset: Double = -20
	
	// How wide to make each petal
	var petalWidth: Double = 100
	
	func path(in rect: CGRect) -> Path {
		// The path that will hold all petals
		var path = Path()
		
		// Count from 0 up to pi * 2, moving up pi / 8 each time
		for number in stride(from: 0, to: CGFloat.pi * 2, by: CGFloat.pi / 8) {
			// rotate the petal by the current value of our loop
			let rotation = CGAffineTransform(rotationAngle: number)
			
			// move the petal to be at the center of our view
			let position = rotation.concatenating(CGAffineTransform(translationX: rect.width / 2, y: rect.height / 2))
			
			// create a path for this petal using our properties plus a fixed Y and height
			let originalPetal = Path(ellipseIn: CGRect(x: CGFloat(petalOffset), y: 0, width: CGFloat(petalWidth), height: rect.width / 2))
			
			// apply our rotation/position transformation to the petal
			let rotatedPetal = originalPetal.applying(position)
			
			// add it to our main path
			path.addPath(rotatedPetal)
		}
		
		// now send the main path back
		return path
	}
}

struct FlowerContentView: View {
	@State private var petalOffset = -20.0
	@State private var petalWidth = 100.0
	
	var body: some View {
		VStack {
			Flower(petalOffset: petalOffset, petalWidth: petalWidth)
				.fill(Color.pink, style: FillStyle(eoFill: true, antialiased: true))
			
			Text("Offset")
			Slider(value: $petalOffset, in: -40...40)
			padding([.horizontal, .bottom])
			
			Text("Width")
			Slider(value: $petalWidth, in: 0...100)
				.padding(.horizontal)
		}
	}
}

struct Triangle: Shape {
	func path(in rect: CGRect) -> Path {
		var path = Path()
		
		path.move(to: CGPoint(x: rect.midX, y: rect.minY))
		path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
		path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
		path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
		
		return path
	}
}

struct Arc: Shape {
	var startAngle: Angle
	var endAngle: Angle
	var clockwise: Bool
	
	func path(in rect: CGRect) -> Path {
		let rotationAdjustment = Angle.degrees(90)
		let modifiedStart = startAngle - rotationAdjustment
		let modifiedEnd = endAngle - rotationAdjustment
		
		var path = Path()
		path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width/2, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)
		
		return path
	}
}

struct InsettableArc: InsettableShape {
	var startAngle: Angle
	var endAngle: Angle
	var clockwise: Bool
	var insetAmount: CGFloat = 0
	
	func path(in rect: CGRect) -> Path {
		let rotationAdjustment = Angle.degrees(90)
		let modifiedStart = startAngle - rotationAdjustment
		let modifiedEnd = endAngle - rotationAdjustment
		
		var path = Path()
		path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2 - insetAmount, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)
		
		return path
	}
	
	func inset(by amount: CGFloat) -> some InsettableShape {
		var arc = self
		arc.insetAmount += amount
		return arc
	}
}

struct ContentView: View {
    var body: some View {
		InsettableArc(startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: true)
			.strokeBorder(Color.blue, lineWidth: 40)
		
//		Triangle()
//			.stroke(Color.purple, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
//			.frame(width: 300, height: 300)

    }
}

struct SpirographContentView_Previews: PreviewProvider {
    static var previews: some View {
		SpirographContentView()
    }
}
