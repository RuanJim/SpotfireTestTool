// --------------------------------------------------------------------------------------------------------------------
// <copyright file="CategoryColumnDialog.cs" company="PerkinElmer Inc.">
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

using System;
using System.Linq;
using System.Windows.Forms;
using Com.PerkinElmer.Service.SpotfireTestTool.CustomTool;
using Spotfire.Dxp.Data;

#endregion

namespace Com.PerkinElmer.Service.SpotfireTestTool.Views
{
    public partial class CategoryColumnDialog : Form, ITestToolSettingsForm
    {
        public CategoryColumnDialog()
        {
            InitializeComponent();
        }

        public TestToolSettings TestToolSettings { get; set; }

        private void CategoryColumnDialog_Load(object sender, EventArgs e)
        {
            DataTable dataTable = TestToolSettings.Document.Data.Tables[TestToolSettings.DataTable];

            string[] columns = dataTable.Columns
                .AsEnumerable()
                .Where(c => c.DataType == DataType.String || c.DataType == DataType.Integer)
                .Select(c => c.Name).ToArray();

            categoryColumnListBox.DataSource = columns;
        }

        private void okButton_Click(object sender, EventArgs e)
        {
            TestToolSettings.CategoryColumns = categoryColumnListBox.SelectedItems.Cast<string>().ToArray();

            this.Hide();

            DataColumnsDialog dataColumnsDialog = new DataColumnsDialog();
            dataColumnsDialog.TestToolSettings = TestToolSettings;
            DialogResult = dataColumnsDialog.ShowDialog(this);
        }
    }
}
