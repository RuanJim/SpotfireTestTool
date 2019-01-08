using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Com.PerkinElmer.Service.SpotfireTestTool.CustomTool;
using Spotfire.Dxp.Application;
using Spotfire.Dxp.Data;
using Spotfire.Dxp.Framework.Services;

namespace Com.PerkinElmer.Service.SpotfireTestTool.Views
{
    public partial class DataColumnsDialog : Form, ITestToolSettingsForm
    {
        public DataColumnsDialog()
        {
            InitializeComponent();
        }

        public TestToolSettings TestToolSettings { get; set; }

        private void DataColumnsDialog_Load(object sender, EventArgs e)
        {
            DataTable dataTable = TestToolSettings.Document.Data.Tables[TestToolSettings.DataTable];

            string[] columns = dataTable.Columns
                .AsEnumerable()
                .Where(c => c.DataType == DataType.Integer || c.DataType == DataType.Real)
                .Select(c => c.Name).ToArray();

            dataColumnsListBox.DataSource = columns;
        }

        private void okButton_Click(object sender, EventArgs e)
        {
            TestToolSettings.DataColumns = dataColumnsListBox.SelectedItems.Cast<string>().ToArray();

            this.Hide();

            CalculateKindForm calculateKindDialog = new CalculateKindForm();
            calculateKindDialog.TestToolSettings = TestToolSettings;
            calculateKindDialog.ShowDialog();
        }
    }
}
