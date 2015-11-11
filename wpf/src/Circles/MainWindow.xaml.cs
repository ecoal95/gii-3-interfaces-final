using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace Circles
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private WorldConfigViewModel config;

        public MainWindow()
        {
            InitializeComponent();
            this.config = new WorldConfigViewModel();
            this.DataContext = this.config;
            ObjectsBinding.ItemsSource = config.Objects;
            Mass.Value = 15;
            Radius.Value = 15;
            BounceFactor.Value = 1;
            SpeedX.Value = SpeedY.Value = 0;
            PositionX.Value = PositionY.Value = 500 / 2;
            SavedGames.ItemsSource = MapManager.GetInstance().SavedGames;

            if (SavedGames.Items.IsEmpty)
                SavedGamesPanel.Visibility = Visibility.Collapsed;
        }

        private void AddObject(object sender, RoutedEventArgs e)
        {
            config.Objects.Add(new MovingCircleConfig(new Point(PositionX.Value, PositionY.Value), Radius.Value, Mass.Value, BounceFactor.Value, new Vector(SpeedX.Value, SpeedY.Value)));
        }

        private void StartSimulation(object sender, EventArgs e)
        {
            new SimulationWindow(config.AsWorldConfig()).Show();
            this.Close();
        }

        private void ItemDoubleClicked(object sender, MouseButtonEventArgs e)
        {
            ListViewItem item = sender as ListViewItem;
            new SimulationWindow(item.Content as WorldConfig, false).Show();
            this.Close();
        }
    }
}
