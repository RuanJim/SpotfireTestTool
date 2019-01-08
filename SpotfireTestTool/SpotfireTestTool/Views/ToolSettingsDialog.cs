// --------------------------------------------------------------------------------------------------------------------
// <copyright file="ToolSettingsDialog.cs" company="PerkinElmer Inc.">
//   Copyright (c) 2013 PerkinElmer Inc.,
//     940 Winter Street, Waltham, MA 02451.
//     All rights reserved.
//     This software is the confidential and proprietary information
//     of PerkinElmer Inc. ("Confidential Information"). You shall not
//     disclose such Confidential Information and may not use it in any way,
//     absent an express written license agreement between you and PerkinElmer Inc.
//     that authorizes such use.
// </copyright>
// --------------------------------------------------------------------------------------------------------------------

#region

using System.Linq;
using System.Windows.Forms;
using Com.PerkinElmer.Service.SpotfireTestTool.CustomTool;
using Spotfire.Dxp.Application;
using Spotfire.Dxp.Framework.Services;

#endregion

namespace Com.PerkinElmer.Service.SpotfireTestTool.Views
{
    public partial class ToolSettingsDialog : Form, ITestToolSettingsForm
    { 
        public ToolSettingsDialog(TestToolSettings settings)
        {
            InitializeComponent();

            TestToolSettings = settings;
        }


        public TestToolSettings TestToolSettings { get; set; }

        private void ToolSettingsDialog_Load(object sender, System.EventArgs e)
        {
            string[] tableList = TestToolSettings.Document.Data.Tables.AsEnumerable().Select(t => t.Name).ToArray();

            dataTableComboBox.DataSource = tableList;
        }

        private void okButton_Click(object sender, System.EventArgs e)
        {
            TestToolSettings.DataTable = dataTableComboBox.Text;
            TestToolSettings.Marking = markingComboBox.Text;
            TestToolSettings.DataRange = markingRadio.Checked ? "marking" : "all";

            Hide();

            CategoryColumnDialog categoryColumnsDialog = new CategoryColumnDialog();
            categoryColumnsDialog.TestToolSettings = TestToolSettings;

            categoryColumnsDialog.ShowDialog();
        }

        private void markingRadio_CheckedChanged(object sender, System.EventArgs e)
        {
            markingComboBox.Enabled = markingRadio.Checked;

            if (markingComboBox.Enabled)
            {
                string[] markingList =
                    TestToolSettings.Document.Data.Markings.AsEnumerable().Select(m => m.Name).ToArray();

                markingComboBox.DataSource = markingList;
            }
            else
            {
                markingComboBox.DataSource = null;
            }
        }
    }
}
