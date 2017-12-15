/*
 *  WordOrientation.fx - Contains constants that represent the orientation
 *                       (direction) of the word on the word grid of the
 *                       Word Search Puzzle Builder
 *
 *  Developed 2007 by James L. Weaver (jim.weaver at jmentor dot com)
 *  to serve as a JavaFX Script example.
 */
package wordsearch_jfx.model;

import javafx.ui.*;

public class WordOrientation {
  public attribute id: Integer;
}

HORIZ:WordOrientation = WordOrientation {
  id: 0
};

DIAG_DOWN:WordOrientation = WordOrientation {
  id: 1
};

VERT:WordOrientation = WordOrientation {
  id: 2
};

DIAG_UP:WordOrientation = WordOrientation {
  id: 3
};

NUM_ORIENTS:Integer = 4;
