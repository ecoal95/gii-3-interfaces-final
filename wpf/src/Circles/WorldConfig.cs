using System.Collections.Generic;

namespace Circles
{
    public class WorldConfig
    {
        public List<MovingCircleConfig> Objects;

        public double Gravity { get; }
        public double Width { get; }
        public double Height { get; }
        public bool IsStatic { get; }

        public WorldConfig(double gravity, double height, double width, bool isStatic): this(gravity, height, width, isStatic, new List<MovingCircleConfig>())
        {
        }

        public WorldConfig(double gravity, double height, double width, bool isStatic, List<MovingCircleConfig> objects)
        {
            this.Objects = objects;
            this.Gravity = gravity;
            this.Height = height;
            this.Width = width;
            this.IsStatic = isStatic;
        }

        public WorldConfigViewModel ToViewModel()
        {
            WorldConfigViewModel vm = new WorldConfigViewModel();

            vm.Gravity = Gravity;
            vm.Width = Width;
            vm.Height = Height;
            vm.IsStatic = IsStatic;

            foreach(MovingCircleConfig c in Objects)
            {
                vm.Objects.Add(c);
            }

            return vm;
        }
    }
}
