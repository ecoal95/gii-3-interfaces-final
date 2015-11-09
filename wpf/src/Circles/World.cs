﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Diagnostics;


namespace Circles
{
    class World
    {
        public List<MovingCircle> Objects;
        public double Width { get; }
        public double Height { get; }
        private double Gravity;
        private Vector[] PrecalculatedDeltaFCache = null;

        public World(double width, double height, double Gravity) {
            this.Objects = new List<MovingCircle>();
            this.Width = width;
            this.Height = height;
            this.Gravity = Gravity;
        }

        public void Tick(double timestep, double gravity)
        {
            this.Gravity = gravity;
            Tick(timestep);
        }

        public void Tick(double timestep) {
            timestep /= 1000; // Just seconds, please

            int len = Objects.Count;
            Vector[] accelerationCache = new Vector[len];
            // We know that the vector value is 0, 0
            this.PrecalculatedDeltaFCache = new Vector[len];

            for (int i = 0; i < len; ++i) {
                MovingCircle obj = Objects[i];
                Vector acceleration = force(obj, i, len) / obj.Mass;

                obj.Position += timestep * (obj.Speed + timestep * acceleration * .5);

                accelerationCache[i] = acceleration;

                CalculateSpeedAndPositionFromCollisions(obj, i, len);
            }

            this.PrecalculatedDeltaFCache = new Vector[len];
            // We want updated position and speeds
            for (int i = 0; i < len; ++i) {
                MovingCircle obj = Objects[i];
                Vector newAcceleration = force(obj, i, len) / obj.Mass;
                // (oldAcceleration + newAcceleration) / 2
                obj.Speed += timestep * (accelerationCache[i] + newAcceleration) * .5;
            }
        }

        public void CalculateSpeedAndPositionFromCollisions(MovingCircle obj, int myIndex, int len) {
            int len = Objects.Count;

            // We only detect collisions for bodies after us in the list
            for (int i = myIndex + 1; i < len; ++i)
            {
                MovingCircle other = Objects[i];

                Vector centerToCenter = (other.Center - obj.Center);
                double centerToCenterLen = centerToCenter.Length;

                // If they collide
                if ( centerToCenterLen <= other.Radius + obj.Radius )
                {
                    // We get the translation necessary to move one
                    Vector a = centerToCenter * (obj.Radius / centerToCenterLen);
                    Vector b = centerToCenter * (centerToCenterLen - other.Radius) / centerToCenterLen;
                    Vector middle = (a - b) / 2;

                    obj.Position -= middle;
                    other.Position += middle;

                    // Now we've positioned the cicles, we can normalize the centerToCenter vector in order to convert it into a unit vector
                    centerToCenter.Normalize();

                    // http://ericleong.me/research/circle-circle/#static-circle-circle-collision-detection
                    double p = 2 * (obj.Speed.X * centerToCenter.X + obj.Speed.Y * centerToCenter.Y - other.Speed.X * centerToCenter.X - other.Speed.Y * centerToCenter.Y) / (obj.Mass + other.Mass);
                    obj.Speed = new Vector(obj.Speed.X - p * other.Mass * centerToCenter.X,
                                           obj.Speed.Y - p * other.Mass * centerToCenter.Y)
                                           * obj.BounceFactor;
                    other.Speed = new Vector(other.Speed.X + p * obj.Mass * centerToCenter.X,
                                             other.Speed.Y + p * obj.Mass * centerToCenter.Y)
                                             * other.BounceFactor;
                    /* Original: Seems to have switched both masses, since a high-mass sphere bounces like heck
                    obj.Speed = new Vector(obj.Speed.X - p * obj.Mass * centerToCenter.X,
                                           obj.Speed.Y - p * obj.Mass * centerToCenter.Y)
                                           * obj.BounceFactor;
                    other.Speed = new Vector(other.Speed.X + p * other.Mass * centerToCenter.X,
                                             other.Speed.Y + p * other.Mass * centerToCenter.Y)
                                             * other.BounceFactor;
                    */
                }
            }

            if (obj.Position.Y < 0) {
                obj.Speed = new Vector(obj.Speed.X, Math.Abs(obj.Speed.Y) * obj.BounceFactor);
                obj.Position = new Point(obj.Position.X, 0);
            } else if (obj.Position.Y + obj.Diameter > this.Height) {
                obj.Speed = new Vector(obj.Speed.X, -Math.Abs(obj.Speed.Y) * obj.BounceFactor);
                obj.Position = new Point(obj.Position.X, this.Height - obj.Diameter);
            }

            if (obj.Position.X < 0) {
                obj.Position = new Point(0, obj.Position.Y);
                obj.Speed = new Vector(-obj.Speed.X * obj.BounceFactor, obj.Speed.Y);
            } else if (obj.Position.X + obj.Diameter > this.Width) {
                obj.Position = new Point(this.Height - obj.Diameter, obj.Position.Y);
                obj.Speed = new Vector(-obj.Speed.X * obj.BounceFactor, obj.Speed.Y);
            }

        }

        public Vector force(MovingCircle obj, int myIndex, int len) {
            Vector f = PrecalculatedDeltaFCache[myIndex];

            // Vector f = new Vector(0.0, 9.8) * obj.Mass
            // Actually the gravity is in px/s/s... Lol
            f += new Vector(0.0, this.Gravity) * obj.Mass; // Gravity

            // We only detect collisions for bodies after us in the list
            for (int i = myIndex + 1; i < len; ++i)
            {
                MovingCircle other = Objects[i];

                Vector centerToCenter = (other.Center - obj.Center);

                // If they collide
                // NOTE: Instead of length < o1.radius + o2.radius we use LengthSquared, since it's faster
                // (Obtaining the length needs a square root)
                if ( centerToCenter.LengthSquared < other.Radius * other.Radius + obj.Radius * obj.Radius )
                {
                    // Now we've positioned the cicles, we can normalize the centerToCenter vector in order to convert it into a unit vector
                    centerToCenter.Normalize();

                    // Add the linear momentum and substract the normal
                    f += other.Speed * other.Mass;
                    f -= obj.Speed * obj.Mass;

                    PrecalculatedDeltaFCache[i] += obj.Speed * obj.Mass;
                    PrecalculatedDeltaFCache[i] -= other.Speed * other.Mass;
                }
            }

            // if ( object touches boundary )
            //     f += normal; (f = 0);
            // TODO: Consider using < instead of <=
            if (obj.Position.Y < 0) {
                if (Gravity < 0)
                    f += new Vector(0, obj.Mass * -this.Gravity);
                f += new Vector(0, -obj.Speed.Y * obj.Mass);
            } else if (obj.Position.Y + obj.Diameter > this.Height) {
                if (Gravity > 0)
                    f += new Vector(0, obj.Mass * -this.Gravity);
                f += new Vector(0, -obj.Speed.Y * obj.Mass);
            }

            if (obj.Position.X < 0) {
                // Lineal moment:
                // p = m * v
                // F = dp/dt
                f += new Vector(obj.Mass * -obj.Speed.X, 0);
            } else if (obj.Position.X + obj.Diameter > this.Width) {
                // Lineal moment:
                // p = m * v
                // F = dp/dt
                f += new Vector(obj.Mass * -obj.Speed.X, 0);
            }

            return f;
        }
    }
}
