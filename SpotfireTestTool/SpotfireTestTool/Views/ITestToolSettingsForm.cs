// --------------------------------------------------------------------------------------------------------------------
// <copyright file="ITestToolSettingsForm.cs" company="PerkinElmer Inc.">
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

using Com.PerkinElmer.Service.SpotfireTestTool.CustomTool;
using Spotfire.Dxp.Application;

namespace Com.PerkinElmer.Service.SpotfireTestTool.Views
{
    interface ITestToolSettingsForm
    {
        Document Document { get; }
        TestToolSettings TestToolSettings { get; set; }
    }
}
