// --------------------------------------------------------------------------------------------------------------------
// <copyright file="CalculateKindForm.cs" company="PerkinElmer Inc.">
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

using System.Windows.Forms;
using Com.PerkinElmer.Service.SpotfireTestTool.CustomTool;

#endregion

namespace Com.PerkinElmer.Service.SpotfireTestTool.Views
{
    public partial class CalculateKindForm : Form, ITestToolSettingsForm
    {
        public CalculateKindForm()
        {
            InitializeComponent();
        }

        public TestToolSettings TestToolSettings { get; set; }

        private void CalculateKindForm_Load(object sender, System.EventArgs e)
        {
            calculateKindComboBox.SelectedIndex = 0;
        }

        private void okButton_Click(object sender, System.EventArgs e)
        {
            this.TestToolSettings.CalculatedKind = calculateKindComboBox.Text;

        }
    }
}
