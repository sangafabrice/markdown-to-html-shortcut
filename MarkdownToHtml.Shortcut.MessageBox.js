import System;
import System.Windows;

package MarkdownToHtml.Shortcut {

  /** Represents the simplified WPF MessageBox for the MarkdownToHtml Launcher.
  */
  class MessageBox {

    // The title of the message box.
    private static var title: String = 'Convert Markdown To HTML';

    /** Show the custom message box.
     *  @param message the message string in the Message Box.
     *  @param type the type of message 'Exclamation'/'Error'.
     *  @return true if the user clicked on the OK\No button, false otherwise.
    */
    static function Show(message: String, type: MessageBoxImage): Boolean {
      // If the message notifies of an Error, the message box only displays an OK button.
      // Otherwise, the message box displays an alternative: Yes/No buttons.
      var button: MessageBoxButton = type == MessageBoxImage.Error ? MessageBoxButton.OK:MessageBoxButton.YesNo;
      var result: MessageBoxResult = System.Windows.MessageBox.Show(message, title, button, type);
      return result == MessageBoxResult.No || result == MessageBoxResult.OK;
    }

    // Set that the default value of @param type is 'Error'.
    static function Show(message: String): Boolean {
      return Show(message, MessageBoxImage.Error);
    }
  }
}