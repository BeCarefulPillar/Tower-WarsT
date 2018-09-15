namespace Sfs2X.Requests.MMO
{
    using Sfs2X.Entities.Data;
    using System;

    public class MapLimits
    {
        private Vec3D higherLimit;
        private Vec3D lowerLimit;

        public MapLimits(Vec3D lowerLimit, Vec3D higherLimit)
        {
            if ((lowerLimit == null) || (higherLimit == null))
            {
                throw new ArgumentException("Map limits arguments must be both non null!");
            }
            this.lowerLimit = lowerLimit;
            this.higherLimit = higherLimit;
        }

        public Vec3D HigherLimit
        {
            get
            {
                return this.higherLimit;
            }
        }

        public Vec3D LowerLimit
        {
            get
            {
                return this.lowerLimit;
            }
        }
    }
}

