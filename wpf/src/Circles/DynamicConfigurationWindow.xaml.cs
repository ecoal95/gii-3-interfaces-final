using System.Windows;
using System.Windows.Controls;
using System.Collections.Generic;
using System.Linq;
using System;
using System.Windows.Data;
using System.Windows.Input;

namespace Circles
{
    /// <summary>
    /// Interaction logic for DynamicConfigurationWindow.xaml
    /// </summary>
    public partial class DynamicConfigurationWindow : Window
    {
        public DynamicConfigurationWindow()
        {
            InitializeComponent();
            SavedGames.ItemsSource = MapManager.GetInstance().SavedGames;
        }

        private void ItemDoubleClicked(object sender, MouseButtonEventArgs e)
        {
            ListViewItem item = sender as ListViewItem;
            (Owner as SimulationWindow).SetWorldConfig(item.Content as WorldConfig);
        }
    }
}
