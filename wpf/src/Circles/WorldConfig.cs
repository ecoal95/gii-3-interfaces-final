using System.Collections.Generic;

namespace Circles
{
    public class WorldConfig
    {
        public List<MovingCircleConfig> Objects;

        public double Gravity { get; set; }
        public double Width { get; set; }
        public double Height { get; set; }
        public int ObjectCount { get { return Objects.Count; } }



        public WorldConfig(double gravity, double height, double width): this(gravity, height, width, new List<MovingCircleConfig>())
        {
        }

        public WorldConfig(double gravity, double height, double width, List<MovingCircleConfig> objects)
        {
            this.Objects = objects;
            this.Gravity = gravity;
            this.Height = height;
            this.Width = width;
        }

        public WorldConfigViewModel ToViewModel()
        {
            WorldConfigViewModel vm = new WorldConfigViewModel();

            vm.Gravity = Gravity;
            vm.Width = Width;
            vm.Height = Height;

            foreach(MovingCircleConfig c in Objects)
            {
                vm.Objects.Add(c);
            }

            return vm;
        }

        public override string ToString()
        {
            return string.Format("World ({0}x{1}) g: {2} ({3} objects)", Width, Height, Gravity, ObjectCount);
        }
    }
}
