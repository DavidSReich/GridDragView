//
//  TestGridDragView.swift
//  GridDrag
//
//  Created by David S Reich on 9/5/20.
//  Copyright © 2020 StellarSoftware. All rights reserved.
//

import SwiftUI

struct TestGridDragView: View {
    let cellSize: CGFloat
    let rows: Int
    let cols: Int

    @ObservedObject var gridDragViewModelStress: GridDragViewModelStress

    @State var buttonText = "Drag!!!"

    init(cellSize: CGFloat, rows: Int, cols: Int) {
        self.cellSize = cellSize
        self.rows = rows
        self.cols = cols
        self.gridDragViewModelStress = GridDragViewModelStress(rows: rows, cols: cols, cellSize: cellSize, viewFactory: SquareViewFactory(), cells: nil)
    }

    var body: some View {
        VStack {
            Spacer()
            GridDragView(gridDragViewModel: gridDragViewModelStress)
            Spacer()
            Button(action: {
                if self.gridDragViewModelStress.running {
                    self.gridDragViewModelStress.stop()
                    self.buttonText = "Drag!!!"
                } else {
                    self.gridDragViewModelStress.run(rows: self.rows, cols: self.cols, cellSize: self.cellSize)
                    self.buttonText = "Stop!"
                }
            }) {
                Text(buttonText)
                    .font(.largeTitle)
                    .padding()
            }
        }
    }
}

struct TestGridDragView_Previews: PreviewProvider {
    static let cellSize = CGFloat(50)
    static let rows = 5
    static let cols = 3

    static var previews: some View {
        TestGridDragView(cellSize: cellSize, rows: rows, cols: cols)
    }
}
