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
            if (Instance == null)
                Instance = new MapManager();

            return Instance;
        }


        private List<WorldConfig> _SavedGames;

        public List<WorldConfig> SavedGames
        {
            get
            {
                return new List<WorldConfig>(_SavedGames);
            }
        }

        public MapManager()
        {
            // TODO: Read from file and persist
            this._SavedGames = new List<WorldConfig>();
        }

        public void SaveGame(WorldConfig game)
        {
            _SavedGames.Add(game);
        }
    }
}
