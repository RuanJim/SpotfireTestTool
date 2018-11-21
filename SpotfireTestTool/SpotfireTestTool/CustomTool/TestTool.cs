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
using Spotfire.Dxp.Application;
using Spotfire.Dxp.Application.Extension;

namespace Com.PerkinElmer.Service.SpotfireTestTool.CustomTool
{
    public sealed class TestTool : CustomTool<Document>
    {
        public TestTool() : base("R(D) Test")
        {
        }

        protected override bool GetSupportsPromptingCore()
        {
            return true;
        }

        protected override IEnumerable<object> ExecuteAndPromptCore(Document context)
        {
            return base.ExecuteAndPromptCore(context);
        }
    }
}
