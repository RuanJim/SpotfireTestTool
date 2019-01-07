using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Com.PerkinElmer.Service.SpotfireTestTool.CustomTool;
using Spotfire.Dxp.Application;
using Spotfire.Dxp.Framework.Services;

namespace Com.PerkinElmer.Service.SpotfireTestTool.Views
{
    public partial class CategoryColumnDialog : Form, ITestToolSettingsForm
    {
        public CategoryColumnDialog()
        {
            InitializeComponent();
        }
        public Document Document => TestToolSettings.GetService<Document>();

        public TestToolSettings TestToolSettings { get; set; }
    }
}
