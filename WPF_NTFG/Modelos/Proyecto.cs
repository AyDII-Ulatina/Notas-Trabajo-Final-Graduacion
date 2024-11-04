using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WPF_NTFG.Modelos
{
    public class Proyecto
    {
        public int idProyecto { get; set;}
        public string nomProyecto { get; set;}
        public DateTime fecha { get; set;}
        public string nomTutor { get; set;}
        public string nomMetodologo { get; set;}
        public int idEstado { get; set;}
        public string nomEstudiante { get; set;}

    }
}
