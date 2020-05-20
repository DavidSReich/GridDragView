//
//  GridDragView.swift
//  GridDrag
//
//  Created by David S Reich on 1/5/20.
//  Copyright © 2020 StellarSoftware.
//  All rights reserved except as defined by MIT license - see LICENSE file for more info.
//

import SwiftUI

struct GridDragView: View {

    @ObservedObject var gridDragViewModel: GridDragViewModel

    init(gridDragViewModel: GridDragViewModel) {
        self.gridDragViewModel = gridDragViewModel
    }

    var body: some View {
        ZStack {
            makeGrid(gridDragViewModel: gridDragViewModel)
                .animation(.easeInOut)
        }
    }

    private func makeGrid(gridDragViewModel: GridDragViewModel) -> some View {
        let rows = gridDragViewModel.rows
        let cols = gridDragViewModel.cols
        
        return ForEach(0..<rows, id: \.self) { row in
            ZStack {
                ForEach(0..<cols, id: \.self) { col in
                    ZStack {
                        self.makeView(row: row, col: col)
                    }
                }
            }
        }
    }

    private func makeView(row: Int, col: Int) -> some View {
        let cols = gridDragViewModel.cols
        let cellIndex = (row * cols) + col
        let size = gridDragViewModel.cellSize

        return gridDragViewModel.getCellView(row: row, col: col)
            .frame(width: CGFloat(size), height: CGFloat(size))
            .offset(self.gridDragViewModel.getCurrentOffset(index: cellIndex))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.gridDragViewModel.moveViews(index: cellIndex, translation: value.translation)
                        self.gridDragViewModel.dragging = true
                }
                .onEnded { value in
                    self.gridDragViewModel.moveViews(index: cellIndex, translation: value.translation)
                    self.gridDragViewModel.snapToGrid()
                    self.gridDragViewModel.dragging = false
                }
        )
    }
}

struct GridDragView_Previews: PreviewProvider {
    static let gCells: [GridDragViewModel.GridCell] = [
        GridDragViewModel.GridCell(cell: AnyView(Rectangle().foregroundColor(.red))),
        GridDragViewModel.GridCell(cell: AnyView(Text("Huey"))),
        GridDragViewModel.GridCell(cell: AnyView(Circle().foregroundColor(.orange))),
        GridDragViewModel.GridCell(cell: AnyView(Rectangle().foregroundColor(.blue))),
        GridDragViewModel.GridCell(cell: AnyView(Text("Phooey"))),
        GridDragViewModel.GridCell(cell: AnyView(Circle().foregroundColor(.purple))),
        GridDragViewModel.GridCell(cell: AnyView(Rectangle().foregroundColor(.green))),
        GridDragViewModel.GridCell(cell: AnyView(Text("Dewey"))),
        GridDragViewModel.GridCell(cell: AnyView(Circle().foregroundColor(.pink))),
        GridDragViewModel.GridCell(cell: AnyView(Rectangle().foregroundColor(.yellow))),
        GridDragViewModel.GridCell(cell: AnyView(Text("Louie"))),
        GridDragViewModel.GridCell(cell: AnyView(Circle().foregroundColor(.black)))
    ]

    static let gridDragViewModelViewFactory = GridDragViewModel(rows: 5, cols: 3, cellSize: 50, viewFactory: SquareViewFactory(), cells: nil)
    static let gridDragViewModelCells = GridDragViewModel(rows: 4, cols: 3, cellSize: 60, viewFactory: nil, cells: gCells)

    static var previews: some View {
        Group {
            GridDragView(gridDragViewModel: gridDragViewModelViewFactory)
            GridDragView(gridDragViewModel: gridDragViewModelCells)
        }
    }
}

//examples ...
//ViewFactoryProtocol classes should be in their own file(s)
class SquareViewFactory: ViewFactoryProtocol {
    func makeView(row: Int, col: Int) -> AnyView {
        AnyView(Rectangle()
            .foregroundColor((row + col) % 2 == 0 ? .red : .blue)
            .overlay(Text("\(row) \(col)")
                .font(Font.footnote.smallCaps())
                .lineLimit(1)
                .minimumScaleFactor(0.1)
            )
        )
    }
}

class RoundViewFactory: ViewFactoryProtocol {
    func makeView(row: Int, col: Int) -> AnyView {
        AnyView(Circle()
            .foregroundColor((row + col) % 2 == 0 ? .red : .blue)
            .overlay(Text("\(row) \(col)")
                .lineLimit(1)
                .minimumScaleFactor(0.1)
        ))
    }
}
