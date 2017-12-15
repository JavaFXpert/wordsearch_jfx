/*
 *  WordGridCell.fx - Represents a cell in the model of the word grid 
 *
 *  Developed 2007 by James L. Weaver (jim.weaver at jmentor dot com)
 *  to serve as a JavaFX Script example.
 */
package wordsearch_jfx.model;

import javafx.ui.*;
import java.lang.Character;
import java.lang.Math;
import wordsearch_jfx.ui.WordGridRect;

class WordGridCell {
  // Placed letter in this cell (or could contain a space)
  attribute cellLetter:String; 
  
  // Random letter in this cell
  attribute fillLetter:String;
  
  // Indicate which appearance that this cell should have
  // (e.g. SELECTED_LOOK, DRAGGING_LOOK, OR DEFAULT_LOOK)
  attribute appearance:WordGridRect;
  
  // Word grid entries associated with this cell on the grid
  attribute wordEntries:WordGridEntry*;
}

trigger on new WordGridCell {
  cellLetter = SPACE;

  // Generate random letter to be used to fill in this cell
  // in the case that it doesn't contain a word
  fillLetter = Character.forDigit(Math.random() * 26 + 10, 36).
                             toString().toUpperCase();
  wordEntries = [];
}

// Constant pertaining to a WordGridCell when that cell is 
// empty (contains a space)
SPACE:String = " ";


