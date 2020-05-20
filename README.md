# GridDragView
`GridDragView` is a grid that allows a cell to be dragged up, down, left and right and the row or column will be dragged independently of all other rows and columns.  
Cells dragged off the grid will continuously wrap around and appear at the opposite edge.

The `GridDragViewModel` contains all the logic that controls the creation of the cells and their dragging and placement.  

Cells can be passed into the `GridDragViewModel` as an array of `AnyView` -- `[AnyView]` or can be created by a view factory.  

Neither `GridDragView` or `GridDragViewModel` does any size calculations.  They "know" nothing directly about the dimensions of the `GridDragView` or it's location on screen.

## How?

Create a `GridDragViewModel`:  

```swift
func GridDragViewModel(rows: Int, cols: Int, cellSize: CGFloat, viewFactory: ViewFactoryProtocol?, cells: [GridCell]?)

GridDragViewModel(rows: 5, cols: 4, cellSize: 40, viewFactory: ViewFactory(), cells: nil)
//or  
GridDragViewModel(rows: 4, cols: 3, cellSize: 40, viewFactory: nil, cells: gCells)  
```
Where:

```swift
class ViewFactory: ViewFactoryProtocol {
    func makeView(row: Int, col: Int) -> AnyView {
        AnyView(YourCellView())
    }
}
```
or:

```swift
struct GridCell: View {
    var cell: AnyView
    var body: some View {
        cell
    }
}

let gCells: [GridDragViewModel.GridCell] = [
    GridDragViewModel.GridCell(cell: AnyView(Rectangle().foregroundColor(.red))),
    GridDragViewModel.GridCell(cell: AnyView(Text("Huey").minimumScaleFactor(0.1).lineLimit(1))),
    GridDragViewModel.GridCell(cell: AnyView(Circle().foregroundColor(.orange)))
]
```
Then pass the `GridDragViewModel` into a `GridDragView`:

```swift
GridDragView(gridDragViewModel: myGridDragViewModel)
```

The `GridDragView` uses the `GridDragViewModel` to create the cells of the grid and to manage the calculations of the the cells' locations as the user drags horizontally or vertically.  As is commonly done, all configuration information is controlled by the `GridDragViewModel`.

There is no "traditional" data source used here. 

The `GridDragViewModel` can be created in a `body` and immediately passed to the `GridDragView`.  But then any dragging will be automatically reset every time the containing `View` is redrawn.  This redrawing often happens at inconvenient times, such as switching between two grids, or even just rotating the phone.

The "Demo" avoids this by making the `MainView` the owner of the `GridDragViewModel` and creating it inside the `init` function.  Since there's no dimensional information available when `init` is invoked the `cellSize` is set to `0` when the `GridDragViewModel` is created.  When the `GridDragView` is created inside a `GeometryReader` the desired cell size can be calculated by the containing ` View` whenever the `Geometry.size` changes.  Then `GridDragViewModel.resizeCells(newCellSize: CGFloat)` can be called.  This will recalculate the placements of all the cells in the grid, preserving their locations even when the grid is resized when the phone is rotated.

## Interface  

```swift
func GridDragView(gridDragViewModel: myGridDragViewModel)
```
`GridDragView` conforms to the `View` protocol.  It does not conform to additional protocols and has no other properties.  It can only be manipulated as a `View`.

```swift
class GridDragViewModel: ObservableObject
```
The `GridDragViewModel` is a class.  It is an `ObservableObject` and has a number of functions and properties.  
### Properties  
```swift
    var dragging = false
    var cellSize: CGFloat
    let rows: Int
    let cols: Int
```
The `dragging` property is set to `true` by the `GridDragView` to tell the `GridDragViewModel` when a dragging gesture is ongoing and reset to `false` when the dragging gesture is finished.  
The other properties are set when the `GridDragViewModel` is created.  
### Functions  
```swift
func GridDragViewModel(rows: Int, cols: Int, cellSize: CGFloat, viewFactory: ViewFactoryProtocol?, cells: [GridCell]?)
```
The parameters `rows`, `cols`, and `cellSize` must be set.  The `cellSize` can be changed later - see `resizeCells()` below.  
Either a `viewFactory` or a `cells` MUST be passed in.  If both are `nil` then a `fatalError` will be triggered.  
If `cells` is used then `cells.count` must equal `rows * cols`, otherwise a `fatalError` will be triggered.

```swift
func getCellView(row: Int, col: Int) -> AnyView
```
`getCellView()` is called by `GridDragView` and returns the `View` to be placed at [row, col] in the `GridDragView`.  

```swift
func moveViews(index: Int, translation: CGSize)
```
`moveViews` is called by `GridDragView` whenever `DragGesture` events occur.  

```swift
func snapToGrid()
```
`snapToGrid()` is called by `GridDragView` when a dragging gesture is finished and snaps the dragged cells into alignment with the grid.  

```swift
func resetCellOffsets()
```
`resetCellOffsets()` can be called anytime it is desired to return the grid to its initial state.  This would usually be in response to some user action.  

```swift
func resizeCells(newCellSize: CGFloat)
```
`resizeCells()` can be called anytime it is desired to changed the size of the cells.  This would usually be in response to some user action, such as when the device is rotated or some other user action implemented by the containing `Views`.  

```swift
func getCurrentOffset(index: Int) -> CGSize
```
`getCurrentOffset()` is called by `GridDragView` when it is being refreshed.  It returns the current offset of the cell so the cell can be drawn (by SwiftUI) at the correct offset.  

## Extra credit
Except for the display of the grid and the implementation of dragging the `GridDragView` is a simple dumb control.  It has been designed and tested embedded within the visible part of a screen.  It can probably be made larger than the visible area and embedded within a `ScrollView`.  This has not been tested.

The `GridDragViewModel` can probably be extended to scrolling content with reusable cells like a `List`, but this has not been investigated.

Placing empty spaces within the grid and constraining movement to within the borders (i.e. no wrapping) can be added to the logic.  This feature and others could be implemented by adding collision detection.  This would be a way to implement a standard [15-puzzle.](https://en.wikipedia.org/wiki/15_puzzle)

Expanding the logic to include rectangular shapes could lead one to implement a [Klotski puzzle.](https://en.wikipedia.org/wiki/Klotski)

## Author
* [David Reich](https://github.com/DavidSReich) (<dreich@alum.mit.edu>)

## License

GridDragView is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
