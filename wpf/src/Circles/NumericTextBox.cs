using System;
using System.Windows.Controls;
using System.Windows.Input;

namespace Circles
{
    class NumericTextBox: TextBox
    {
        public double Value
        {
            get
            {
                double result;
                if (double.TryParse(Text, out result)) {
                    return result;
                }
                return 0;
            }
            set
            {
                Text = value.ToString();
            }
        }

        public NumericTextBox(): base()
        {
            PreviewTextInput += RejectNonNumericInput;
        }

        private void RejectNonNumericInput(object _sender, TextCompositionEventArgs obj)
        {
            double d;

            NumericTextBox sender = (NumericTextBox)_sender;
            string finalText = sender.Text.Remove(sender.SelectionStart, sender.SelectionLength)
                                          .Insert(sender.SelectionStart, obj.Text);

            if ( ! double.TryParse(finalText, out d) )
                obj.Handled = true;
        }
    }
}
