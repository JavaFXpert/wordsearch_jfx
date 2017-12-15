/*
 *  WordGridEntry.fx - Represents a word, including information such as its
 *                     orientation and placement in the word grid of the Word 
 *                     Search Puzzle Builder.
 *
 *  Developed 2007 by James L. Weaver (jim.weaver at jmentor dot com)
 *  to serve as a JavaFX Script example.
 */

package wordsearch_jfx.model;

import javafx.ui.*;

public class WordGridEntry {
  // Contains the word that this WordGridEntry represents
  attribute word:String; 

  // Indicates whether this word is placed on the grid. There can be 
  // WordGridEntry objects that are not placed on the grid.
  public attribute placed:Boolean; 

  // Contains the row in the grid that this word begins at.
  attribute row:Integer; 

  // Contains the column in the grid that this word begins at.
  attribute column:Integer; 

  // Contains the direction (orientation) of this word on the grid. The 
  // possible values are the directional constants in WordOrientation class.
  public attribute direction:Integer;
}

trigger on WordGridEntry.word = newWord {
  word = newWord.toUpperCase();
}
 