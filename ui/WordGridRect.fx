/*
 *  WordGridRect.fx - Class that gives each cell on the grid a relationship with
 *                     an array of WordGridEntry instances.
 *
 *  Developed 2007 by James L. Weaver (jim.weaver at jmentor dot com)
 *  to serve as a JavaFX Script example.
 */
package wordsearch_jfx.ui;

import javafx.ui.*;
import javafx.ui.canvas.*;
import wordsearch_jfx.model.WordGridModel;

class WordGridRect extends Rect {
  attribute wsHandlers:WordSearchHandlers;
  attribute wgModel:WordGridModel;

  attribute row:Integer;
  attribute column:Integer;

  attribute appearance:WordGridRect;
  
  // For ..._LOOK constants
  attribute name:String;
  
  operation displayPopupMenu (cmEvt:CanvasMouseEvent, canvas:Canvas);
}

// Constants
SELECTED_LOOK:WordGridRect = WordGridRect {name: "SELECTED_LOOK"};
SELECTED_FIRST_LETTER_LOOK:WordGridRect = 
  WordGridRect {name: "SELECTED_FIRST_LETTER_LOOK"};
DRAGGING_LOOK:WordGridRect = WordGridRect {name: "DRAGGING_LOOK"};
CANT_DROP_LOOK:WordGridRect = WordGridRect {name: "CANT_DROP_LOOK"};
DEFAULT_FIRST_LETTER_LOOK:WordGridRect = 
  WordGridRect {name: "DEFAULT_FIRST_LETTER_LOOK"};
DEFAULT_LOOK:WordGridRect = WordGridRect {name: "DEFAULT_LOOK"};

// Triggers
trigger on new WordGridRect {
  appearance = DEFAULT_LOOK;
}

trigger on WordGridRect.appearance = newAppearance {
  if (newAppearance == SELECTED_LOOK:WordGridRect) {
    strokeWidth = 2;
    stroke = black;
    fill = yellow;
    cursor = DEFAULT;
  }
  else if (newAppearance == SELECTED_FIRST_LETTER_LOOK:WordGridRect) {
    strokeWidth = 2;
    stroke = black;
    fill = yellow;
    cursor = HAND;
  }
  else if (newAppearance == DRAGGING_LOOK:WordGridRect) {
    strokeWidth = 1;
    stroke = cyan;
    fill = cyan;
    cursor = HAND;
  }
  else if (newAppearance == CANT_DROP_LOOK:WordGridRect) {
    strokeWidth = 1;
    stroke = red;
    fill = red;
    cursor = MOVE;
  }
  else if (newAppearance == DEFAULT_FIRST_LETTER_LOOK:WordGridRect) {
    strokeWidth = 1;
    stroke = black;
    fill = white;
    cursor = HAND;
  }
  else if (newAppearance == DEFAULT_LOOK:WordGridRect) {
    strokeWidth = 1;
    stroke = black;
    fill = white;
    cursor = DEFAULT;
  }
}

// Operations and functions
operation WordGridRect.displayPopupMenu (cmEvt, canvas) {
  PopupMenu {
    items: bind
      foreach (wge in wgModel.gridCells[row * wgModel.columns + column].wordEntries)
        MenuItem {
          text: "Unplace {wge.word}"
          enabled: bind not wgModel.fillLettersOnGrid
          action:
            operation() {
              wgModel.selectPlacedWord(wge.word);
              wsHandlers.gridUnplaceWord();
            }
        }
    owner: canvas
    x:cmEvt.localX
    y:cmEvt.localY
    visible: true
  };
}
