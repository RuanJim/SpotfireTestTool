// --------------------------------------------------------------------------------------------------------------------
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

using System.Collections.Generic;
using System.Windows.Forms;
using Spotfire.Dxp.Application;
using Spotfire.Dxp.Application.Extension;
using Spotfire.Dxp.Framework.ApplicationModel;
using Spotfire.Dxp.Framework.Services;

namespace Com.PerkinElmer.Service.SpotfireTestTool.CustomTool
{
    public sealed class TestTool : CustomTool<Document>
    {
        public TestTool() : base("R Test")
        {
        }

        protected override void ExecuteCore(Document document)
        {
            PromptService prompt = document.GetService<PromptService>();

            prompt.Prompt(new TestToolSettings());
        }
    }
}
