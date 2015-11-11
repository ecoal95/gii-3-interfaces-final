using System.Collections.Generic;

namespace Circles
{
    using System.Collections.ObjectModel;
    using System.ComponentModel;

    public class WorldConfigViewModel: INotifyPropertyChanged {
        public ObservableCollection<MovingCircleConfig> Objects;
        public double Gravity = 300;
        public double Width = 500;
        public double Height = 500;
        
        public event PropertyChangedEventHandler PropertyChanged;

        public string GravityText
        {
            get
            {
                return this.Gravity.ToString();
            }
            set
            {
                double val;
                if (double.TryParse(value, out val))
                {
                    this.Gravity = val;
                    OnPropertyChanged("GravityText");
                }
            }
        }

        public string WidthText
        {
            get
            {
                return this.Width.ToString();
            }
            set
            {
                double val;
                if (double.TryParse(value, out val))
                {
                    this.Width = val;
                    OnPropertyChanged("WidthText");
                }
            }
        }

        public string HeightText
        {
            get
            {
                return this.Height.ToString();
            }
            set
            {
                double val;
                if (double.TryParse(value, out val))
                {
                    this.Height = val;
                    OnPropertyChanged("HeightText");
                }
            }
        }

        public WorldConfigViewModel() {
            this.Objects = new ObservableCollection<MovingCircleConfig>();
        }

        protected virtual void OnPropertyChanged(string propertyName)
        {
            var handler = PropertyChanged;
            if (handler != null) handler(this, new PropertyChangedEventArgs(propertyName));
        }

        public WorldConfig AsWorldConfig()
        {
            return new WorldConfig(Gravity, Height, Width, new List<MovingCircleConfig>(Objects));
        }
    }
}
