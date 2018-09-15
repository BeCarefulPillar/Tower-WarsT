namespace Sfs2X.Entities
{
    using Sfs2X.Entities.Data;
    using System;
    using System.Collections.Generic;

    public class MMORoom : SFSRoom
    {
        private Vec3D defaultAOI;
        private Vec3D higherMapLimit;
        private Dictionary<int, IMMOItem> itemsById;
        private Vec3D lowerMapLimit;

        public MMORoom(int id, string name) : base(id, name)
        {
            this.itemsById = new Dictionary<int, IMMOItem>();
        }

        public MMORoom(int id, string name, string groupId) : base(id, name, groupId)
        {
            this.itemsById = new Dictionary<int, IMMOItem>();
        }

        public void AddMMOItem(IMMOItem item)
        {
            this.itemsById.Add(item.Id, item);
        }

        public IMMOItem GetMMOItem(int id)
        {
            return this.itemsById[id];
        }

        public List<IMMOItem> GetMMOItems()
        {
            return new List<IMMOItem>(this.itemsById.Values);
        }

        public void RemoveItem(int id)
        {
            this.itemsById.Remove(id);
        }

        public Vec3D DefaultAOI
        {
            get
            {
                return this.defaultAOI;
            }
            set
            {
                this.defaultAOI = value;
            }
        }

        public Vec3D HigherMapLimit
        {
            get
            {
                return this.higherMapLimit;
            }
            set
            {
                this.higherMapLimit = value;
            }
        }

        public Vec3D LowerMapLimit
        {
            get
            {
                return this.lowerMapLimit;
            }
            set
            {
                this.lowerMapLimit = value;
            }
        }
    }
}

