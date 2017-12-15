/*
 *  WordGridView.fx - The "view" of the word grid in the Word Search Puzzle
 *                    Builder
 *
 *  Developed 2007 by James L. Weaver (jim.weaver at jmentor dot com)
 *  to serve as a JavaFX Script example.
 */

package wordsearch_jfx.ui;

import javafx.ui.*;
import javafx.ui.canvas.*;
import javafx.ui.filter.*;
import wordsearch_jfx.model.WordGridEntry;
import wordsearch_jfx.model.WordGridModel;

class WordGridView extends CompositeNode {
  attribute wgModel:WordGridModel;
  attribute wsHandlers:WordSearchHandlers;

  attribute rows:Integer;
  attribute columns:Integer;

  // Rectangles on the word grid
  attribute wgRects:WordGridRect*;
  
  // Letters on the grid
  attribute textLetters:Text*;
  
  // Numeric labels on the top and left sides of the grid
  attribute gridLabels:Text*;
  
  attribute canvas:Canvas;
  
  // For dragging words around on the grid:
  // The row and column of the first letter of the word to be dragged
  attribute dragOrigRow:Integer;
  attribute dragOrigColumn:Integer;
  // The row and column of the cell to which the first letter of the word
  // is being dragged.
  attribute dragToRow:Integer;
  attribute dragToColumn:Integer;
  // The word grid entry of the word being dragged
  attribute dragOrigWge:WordGridEntry;
  // This holds the state of whether a word is being dragged
  attribute dragging:Boolean;
}

// Constant
CELL_WIDTH:Integer = 30;

// Triggers
trigger on new WordGridView {
  canvas = Canvas {};
  dragging = false;
  dragOrigWge = null;
}

trigger on WordGridView.wgModel = newValue {
  var letterFont = new Font("Sans Serif", "BOLD", 20);
  wgRects = [];
  textLetters = [];
  for (yPos in [0..  rows - 1]) {
    for (xPos in [0.. columns - 1]) {
      insert WordGridRect {
        var: self
        row: yPos
        column: xPos
        x:(xPos * CELL_WIDTH:Integer)
        y:(yPos * CELL_WIDTH:Integer)
        height:CELL_WIDTH:Integer
        width:CELL_WIDTH:Integer
        appearance:
          bind wgModel.gridCells[yPos * columns + xPos].appearance
        wsHandlers: wsHandlers
        wgModel: wgModel
          
        onMouseEntered: operation(evt:CanvasMouseEvent) {
          wgModel.highlightWordsOnCell(yPos * columns + xPos);
        }        

        onMouseMoved: operation(evt:CanvasMouseEvent) {
          wgModel.highlightWordsOnCell(yPos * columns + xPos);
        }        

        onMouseExited: operation(evt:CanvasMouseEvent) {
          wgModel.highlightWordsOnCell(NO_CELL:Integer);
        }        

        onMouseClicked: operation(evt:CanvasMouseEvent) {
          if (wgModel.fillLettersOnGrid) {
            return;
          }
          if (evt.button == 3 or evt.isControlDown()) { 
            // Context menu button was clicked
            self.displayPopupMenu(evt, canvas);
          }
          else if (evt.button == 1) {
            if (evt.isShiftDown()) {
              // Left mouse button was clicked while the shift key was
              // pressed, so find the next available orientation for the word
              // and place it there.
              if (sizeof wgModel.gridCells[yPos * columns + xPos].wordEntries > 0) {
                var wge:WordGridEntry = 
                  wgModel.gridCells[yPos * columns + xPos].wordEntries[0];
                for (d in [1.. NUM_ORIENTS:Integer]) {
                  var newOrient = (d + wge.direction) % NUM_ORIENTS:Integer;
                  if (wgModel.canPlaceWordSpecific(wge.word, 
                                                   wge.row,
                                                   wge.column, 
                                                   newOrient,
                                                   DEFAULT_LOOK:WordGridRect)) {
                    if (wgModel.unplaceWord(wge.word)) {
                      wgModel.placeWordSpecific(wge.word, 
                                                wge.row,
                                                wge.column, 
                                                newOrient);
                      wgModel.highlightWordsOnCell(wge.row * columns + 
                                                   wge.column);
                    }
                    break;
                  }
                }
              }
            }
          }
        }        

        onMousePressed: operation(evt:CanvasMouseEvent) {
          // If the fill letters aren't on the grid, since the mouse is being
          // pressed, set up for being able to drag the word around the grid.
          if (wgModel.fillLettersOnGrid) {
            return;
          }
          cursor = DEFAULT;
          dragging = false;
          if (evt.button == 1) {
            if (sizeof wgModel.gridCells[yPos * columns + xPos].
                               wordEntries > 0) {
              dragOrigWge = 
                wgModel.gridCells[yPos * columns + xPos].wordEntries[0];
              if (dragOrigWge.row == yPos and
                dragOrigWge.column == xPos) { 
                dragOrigRow = yPos;
                dragOrigColumn = xPos;
                dragToRow = yPos;
                dragToColumn = xPos;
                dragging = true;
              }
            }
          }    
        }

        onMouseDragged: operation(evt:CanvasMouseEvent) {
          // If the fill letters aren't on the grid, use the CanvasMouseEvent
          // to know where the user is dragging the mouse.  Give feedback to
          // the user as to whether the word can be placed where it is
          // currently being dragged.
          if (wgModel.fillLettersOnGrid) {
            return;
          }
          if (dragging) {
            if (dragOrigWge <> null) {
              dragToRow = ((evt.localY) / CELL_WIDTH:Integer).intValue();
              dragToColumn = ((evt.localX) / CELL_WIDTH:Integer).intValue();
              // See if the word can be placed, giving the cells under
              // consideration the "dragged" look.
              if (not wgModel.canPlaceWordSpecific(dragOrigWge.word, 
                                                   dragToRow,
                                                   dragToColumn, 
                                                   dragOrigWge.direction,
                                                   DRAGGING_LOOK:WordGridRect)) {
                // The word can't be placed, so call the same method, passing
                // an argument that causes the cells to have a "can't drop look"
                wgModel.canPlaceWordSpecific(dragOrigWge.word, 
                                                   dragToRow,
                                                   dragToColumn, 
                                                   dragOrigWge.direction,
                                                   CANT_DROP_LOOK:WordGridRect);
              } 
            }
          }
        }  

        onMouseReleased: operation(evt:CanvasMouseEvent) {
          // If the fill letters aren't on the grid, and the user released the
          // left mouse button after having dragged a word, then place that
          // word on the grid if possible.
          if (wgModel.fillLettersOnGrid) {
            return;
          }
          if (dragging and evt.button == 1) {
            dragging = false;
            if (dragOrigWge <> null) {
              if (wgModel.canPlaceWordSpecific(dragOrigWge.word, 
                                               dragToRow,
                                               dragToColumn, 
                                               dragOrigWge.direction,
                                               DEFAULT_LOOK:WordGridRect)) {
                if (wgModel.unplaceWord(dragOrigWge.word)) {
                  if (wgModel.placeWordSpecific(dragOrigWge.word, 
                                                dragToRow,
                                                dragToColumn, 
                                                dragOrigWge.direction)) { 
                  }
                }
              }
            }
          }  
          dragOrigWge = null;
        }        
      } into wgRects;
      // Populate the textLetters array with the letters in the grid cells
      insert Text {
               x: bind wgRects[yPos * columns + xPos].x
               y: bind wgRects[yPos * columns + xPos].y
               content: bind wgModel.gridCells[yPos * columns + xPos].cellLetter
               font: letterFont
             } 
        into textLetters;
      
      var rowColumnNumberFont = new Font("Sans Serif", "PLAIN", 12);
        if (yPos == 0) {
          // Draw column numbers
          insert Text {
                   x: (xPos + 1) * CELL_WIDTH:Integer
                   y: yPos
                   content: "{xPos}"
                   font: rowColumnNumberFont
                 }
            into gridLabels;
        } 
        if (xPos == 0) {
          // Draw row numbers
          insert Text {
                   x: xPos
                   y: (yPos  + 1) * CELL_WIDTH:Integer
                   content: "{yPos}"
                   font: rowColumnNumberFont
                 }
          into gridLabels;
        } 
      }
  }
}

// Attribute initializers
attribute WordGridView.rows = bind wgModel.rows;
attribute WordGridView.columns = bind wgModel.columns;

/**
 * This method is automatically called, and the return value is the declarative
 * script that defines this custom graphics component
 */
operation WordGridView.composeNode() { 
  return Group {
    content: [
      Text {
        filter: [ShadowFilter]
        x: 10
        y: 10
        content: "My Word Search Puzzle"
        stroke: blue
        font: new Font("Serif", ["BOLD", "ITALIC"], 24)
      },
      Group {
        transform: translate(45, 55)
        content: [
          wgRects,
          View {
          // This canvas serves as the owner for the PopupMenu
            content: canvas
          }
        ]
      },
      Group {
        transform: translate(53, 63)
        content: textLetters
      },
      Group {
        transform: translate(27, 36)
        content: gridLabels
      }
    ]
  };
}


