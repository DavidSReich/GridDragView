//
//  MainView.swift
//  GridDrag
//
//  Created by David S Reich on 29/4/20.
//  Copyright © 2020 StellarSoftware.
//  All rights reserved except as defined by MIT license - see LICENSE file for more info.
//

import SwiftUI

struct MainView: View {
    let gCells: [GridDragViewModel.GridCell] = [
        GridDragViewModel.GridCell(cell: AnyView(Rectangle().foregroundColor(.red))),
        GridDragViewModel.GridCell(cell: AnyView(Text("Huey").minimumScaleFactor(0.1).lineLimit(1))),
        GridDragViewModel.GridCell(cell: AnyView(Circle().foregroundColor(.orange))),
        GridDragViewModel.GridCell(cell: AnyView(Rectangle().foregroundColor(.blue))),
        GridDragViewModel.GridCell(cell: AnyView(Text("Phooey").minimumScaleFactor(0.1).lineLimit(1))),
        GridDragViewModel.GridCell(cell: AnyView(Circle().foregroundColor(.purple))),
        GridDragViewModel.GridCell(cell: AnyView(Rectangle().foregroundColor(.green))),
        GridDragViewModel.GridCell(cell: AnyView(Text("Dewey").minimumScaleFactor(0.1).lineLimit(1))),
        GridDragViewModel.GridCell(cell: AnyView(Circle().foregroundColor(.pink))),
        GridDragViewModel.GridCell(cell: AnyView(Rectangle().foregroundColor(.yellow))),
        GridDragViewModel.GridCell(cell: AnyView(Text("Louie").minimumScaleFactor(0.1).lineLimit(1))),
        GridDragViewModel.GridCell(cell: AnyView(Circle()))
    ]

    @State private var viewIndex = 0
    @State private var didAppear = false

    private var viewModels: [GridDragViewModel]

    init() {
        viewModels = [
            GridDragViewModel(rows: 5, cols: 4, cellSize: 0, viewFactory: SquareViewFactory(), cells: nil),
            GridDragViewModel(rows: 4, cols: 3, cellSize: 0, viewFactory: nil, cells: gCells)
        ]
    }

    var body: some View {
        VStack {
            Picker(selection: $viewIndex, label: EmptyView()) {
                Text("Use cell factory").tag(0)
                Text("Use array of cells").tag(1)
            }.pickerStyle(SegmentedPickerStyle())

            Spacer()

            GeometryReader { geometry in
                self.makeGridDragView(modelIndex: self.viewIndex, size: geometry.size)
            }

            Spacer()

            Text("Drag rows and columns up and down and left and right!\nCells wrap continuously to the opposite edge.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            Spacer()

            Button(action: {
                self.viewModels[self.viewIndex].resetCellOffsets()
            }) {
                Text("Reset")
                    .font(.title)
                    .padding()
            }
        }
        .padding()
    }

    private func makeGridDragView(modelIndex: Int, size: CGSize) -> some View {
        let rows = viewModels[modelIndex].rows
        let cols = viewModels[modelIndex].cols
        let cellSize = self.calculateCellSize(rows: rows, cols: cols, size: size)
        viewModels[modelIndex].resizeCells(newCellSize: cellSize)

        return GridDragView(gridDragViewModel: viewModels[modelIndex])
    }

    private func calculateCellSize(rows: Int, cols: Int, size: CGSize) -> CGFloat {
        let screenHeight = size.height
        let screenWidth = size.width

        guard screenHeight != 0,
            screenWidth != 0 else {
                return 1
        }

        let cellWidth = screenWidth / CGFloat(cols)
        let cellHeight = screenHeight * 1.0 / CGFloat(rows)

        return min(cellWidth, cellHeight)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
