/*
 *  WordListsView.fx - The "view" of the word lists in the Word Search Puzzle
 *                     Builder
 *
 *  Developed 2007 by James L. Weaver (jim.weaver at jmentor dot com)
 *  to serve as a JavaFX Script example.
 */

package wordsearch_jfx.ui;

import javafx.ui.*;
import javafx.ui.canvas.*;
import wordsearch_jfx.model.WordGridModel;

class WordListsView extends CompositeWidget {
  attribute wgModel:WordGridModel;
  attribute wsHandlers:WordSearchHandlers;
}

trigger on WordListsView.wgModel = newValue {
  wgModel.selectedUnplacedWordIndex = -1;
  wgModel.selectedPlacedWordIndex = -1;
}

/**
 * This method is automatically called, and the return value is the declarative
 * script that defines this custom widget
 */
operation WordListsView.composeWidget() { 
  var selectedWord:String;
  
  // Note: variables are being created for the list boxes in order to pass
  //       then into the WordGridModel.  This will be unnecessary when
  //       when JavaFX implements the ListBox selectedCell attribute.

  // Build the "unplaced words" list box
  var unplacedListBox = ListBox {
    border:
      TitledBorder {
        title: "Unplaced Words:"
      }
    selection: bind wgModel.selectedUnplacedWordIndex
    cells: bind foreach (wge in wgModel.unplacedGridEntries)
      ListCell {
        text: wge.word
      }
    action: operation() {
      if (not wgModel.fillLettersOnGrid) {
        wsHandlers.gridPlaceWordRandomly();
      }
    }
  };

  // Build the "placed words" list box
  var placedListBox = ListBox {
    border:
      TitledBorder {
        title: "Placed Words:"
      }
    selection: bind wgModel.selectedPlacedWordIndex
    cells: bind foreach (wge in wgModel.placedGridEntries)
      ListCell {
        text: wge.word
      }
    action: operation() {
      if (not wgModel.fillLettersOnGrid) {
        wsHandlers.gridUnplaceWord();
      }
    }
  };
    
  wgModel.unplacedListBox = unplacedListBox;
  wgModel.placedListBox = placedListBox;

  // Place both list boxes in a GridPanel and return this custom widget
  return GridPanel {
    rows: 2
    columns: 1
    cells: [
      unplacedListBox,
      placedListBox
    ]
  };
}
