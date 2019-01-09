﻿// --------------------------------------------------------------------------------------------------------------------
// <copyright file="TestTool.cs" company="PerkinElmer Inc.">
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

using System.Text;
using System.Windows.Forms;
using Com.PerkinElmer.Service.SpotfireTestTool.Properties;
using Spotfire.Dxp.Application;
using Spotfire.Dxp.Application.Extension;
using Spotfire.Dxp.Data.DataFunctions;
using Spotfire.Dxp.Framework.ApplicationModel;
using Spotfire.Dxp.Framework.Services;

#endregion

namespace Com.PerkinElmer.Service.SpotfireTestTool.CustomTool
{
    public sealed class TestTool : CustomTool<Document>
    {
        private readonly TestToolSettings settings;

        public TestTool() : base("R Test") 
        {
            settings = new TestToolSettings();
        }

        protected override void ExecuteCore(Document document)
        {
            PromptService prompt = document.GetService<PromptService>();

            settings.Document = document;

            if (PromptResult.Ok == prompt.Prompt(settings))
            {
                ExecuteDataFunction(settings);
            }
            else
            {
                MessageBox.Show("Tool execution canceled.");
            }
        }

        private void ExecuteDataFunction(TestToolSettings testToolSettings)
        {
            string script = Encoding.UTF8.GetString(Resources.scripts_bai);

            DataFunctionDefinitionBuilder functionBuiler = new DataFunctionDefinitionBuilder("RTestTool", DataFunctionExecutorTypeIdentifiers.TERRScriptExecutor);

            functionBuiler.Settings.Add("script", script);
            

        }
    }
}
