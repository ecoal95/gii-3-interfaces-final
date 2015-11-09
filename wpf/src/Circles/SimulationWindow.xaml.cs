using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Timers;
using System.Windows.Threading;
using System.Diagnostics;
using System.Windows.Media;
using System.Collections.Generic;

namespace Circles
{
    /// <summary>
    /// Interaction logic for SimulationWindow.xaml
    /// </summary>
    public partial class SimulationWindow : Window
    {
        private DynamicConfigViewModel ViewModel;
        private World World;
        private Timer PhysicsTimer;
        private DispatcherTimer DrawTimer;
        private DynamicConfigurationWindow DynamicConfigurationWindow;
        private double WorldWidth;
        private double WorldHeight;
        private bool IsStaticSimulation;


        const double MIN_WORLD_WIDTH = 500.0;
        const double MIN_WORLD_HEIGHT = 500.0;
        const uint PHYSICS_PER_SECOND = 180;
        const uint FRAMES_PER_SECOND = 120;

        public SimulationWindow(WorldConfigViewModel config)
        {
            InitializeComponent();
            this.WorldWidth = Math.Max(Math.Abs(config.Width), MIN_WORLD_WIDTH);
            this.WorldHeight = Math.Max(Math.Abs(config.Height), MIN_WORLD_HEIGHT);
            this.ViewModel = new DynamicConfigViewModel();
            this.ViewModel.Gravity = config.Gravity;
            this.IsStaticSimulation = config.IsStatic;
            this.World = new World(this.WorldWidth, this.WorldHeight, ViewModel.Gravity);

            this.PhysicsTimer = new Timer(1000.0 / PHYSICS_PER_SECOND);
            this.PhysicsTimer.AutoReset = true;
            this.PhysicsTimer.Elapsed += CalculatePhysics;
            this.PhysicsTimer.Enabled = true;

            this.DrawTimer = new DispatcherTimer(TimeSpan.FromMilliseconds(1000.0 / FRAMES_PER_SECOND), DispatcherPriority.Send, DoDraw, this.Dispatcher);

            Canvas.Width = this.WorldWidth;
            Canvas.Height = this.WorldHeight;

            if (config.IsStatic)
                OpenConfigurationDialogButton.Visibility = Visibility.Collapsed;
            else
                Canvas.MouseDown += HandleMouseDown;

            foreach (MovingCircleConfig c in config.Objects) {
                AddCircle(new MovingCircle(c.Radius, c.Mass, c.BounceFactor, c.Position - new Vector(c.Radius, c.Radius), c.Speed));
            }
        }

        public void AddCircle(Point position) {
            AddCircle(new MovingCircle(ViewModel.Radius, ViewModel.Mass, ViewModel.BounceFactor, position - new Vector(ViewModel.Radius, ViewModel.Radius), new Vector(0, 0)));
        }

        public void AddCircle(MovingCircle c) {
            World.Objects.Add(c);
            Canvas.Children.Add(c.circle);
            Canvas.SetLeft(c.circle, c.Position.X);
            Canvas.SetTop(c.circle, c.Position.Y);
        }

        private void Draw() {
            foreach (MovingCircle obj in World.Objects)
            {
                Canvas.SetLeft(obj.circle, obj.Position.X);
                Canvas.SetTop(obj.circle, obj.Position.Y);
            }
        }

        private void HandleMouseDown(object sender, MouseButtonEventArgs e)
        {
            AddCircle(e.GetPosition(Canvas));
        }

        private void DoDraw(object sender, EventArgs e) {
            Draw();
        }

        private void CalculatePhysics(object sender, EventArgs e)
        {
            World.Tick(PhysicsTimer.Interval, ViewModel.Gravity);
        }

        private void OpenConfigurationDialog(object sender, EventArgs e) {
            if (DynamicConfigurationWindow == null || !DynamicConfigurationWindow.IsVisible)
            {
                DynamicConfigurationWindow = new DynamicConfigurationWindow();
                DynamicConfigurationWindow.DataContext = ViewModel;
                DynamicConfigurationWindow.Show();
            }

            DynamicConfigurationWindow.Focus();
        }

        private void CloseDialogIfPresent(object sender, System.ComponentModel.CancelEventArgs e)
        {
            if (DynamicConfigurationWindow != null)
                DynamicConfigurationWindow.Close();
        }
    }
}