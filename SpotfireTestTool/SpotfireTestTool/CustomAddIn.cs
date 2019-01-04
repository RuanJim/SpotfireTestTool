// --------------------------------------------------------------------------------------------------------------------
// <copyright file="CustomAddIn.cs" company="PerkinElmer Inc.">
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
using Com.PerkinElmer.Service.SpotfireTestTool.Views;
using Spotfire.Dxp.Application.Extension;

#endregion

namespace Com.PerkinElmer.Service.SpotfireTestTool
{
    /// <summary>
    /// </summary>
    public sealed class CustomAddIn : AddIn
    {
        protected override void RegisterTools(ToolRegistrar registrar)
        {
            base.RegisterTools(registrar);

            CustomMenuGroup menuGroup = new CustomMenuGroup("R");

            registrar.Register(new TestTool(), menuGroup);
        }

        protected override void RegisterViews(ViewRegistrar registrar)
        {
            base.RegisterViews(registrar);

            registrar.Register(typeof(Form), typeof(TestToolSettings), typeof(ToolSettingsDialog));
        }
    }
}
