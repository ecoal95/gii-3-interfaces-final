using System;
using System.IO;
using System.Diagnostics;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Circles
{
    class MapManager
    {
        private static MapManager Instance;

        public static MapManager GetInstance()
        {
            if (Instance != null)
                return Instance;

            return new MapManager();
        }

        private List<WorldConfig> SavedGames;
        public MapManager()
        {
            // TODO: Read from file and persist
            this.SavedGames = new List<WorldConfig>();
        }

        public void SaveGame(WorldConfig game)
        {
            SavedGames.Add(game);
        }
    }
}
