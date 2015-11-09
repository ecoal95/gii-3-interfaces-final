using System.Windows;

namespace Circles
{
    public class MovingCircleConfig
    {
        public Point Position { get; }
        public double Radius { get; }
        public double Mass { get; }
        public double BounceFactor { get; }
        public Vector Speed { get; }

        public MovingCircleConfig(Point position, double radius, double mass, double bounceFactor, Vector speed) {
            this.Position = position;
            this.Radius = radius;
            this.Mass = mass;
            this.BounceFactor = bounceFactor;
            this.Speed = speed;
        }

        public MovingCircle ToMovingCircle() {
            return new MovingCircle(Radius, Mass, BounceFactor, Position, Speed);
        }
    }
}
