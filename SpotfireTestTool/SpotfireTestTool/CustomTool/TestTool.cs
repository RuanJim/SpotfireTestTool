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

#region

using System.Linq;
using System.Text;
using System.Windows.Forms;
using Com.PerkinElmer.Service.SpotfireTestTool.Properties;
using Spotfire.Dxp.Application;
using Spotfire.Dxp.Application.Extension;
using Spotfire.Dxp.Data;
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
            testToolSettings.Document.Transactions.ExecuteTransaction(delegate
            {
                InputParameter categoryColumns, dataColumns, calculateKind;
                OutputParameter returnMessage, resultAll;


                DataFunction function = testToolSettings.Document.Data.DataFunctions.AddNew("RTest", GetFunctionDefinition(out categoryColumns, out dataColumns, out calculateKind, out returnMessage, out resultAll));

                string categoryColumnsExp = string.Join(",",
                    settings.CategoryColumns.Select(c => $"[{settings.DataTable}].[{c}]").ToArray());
                function.Inputs.SetInput(categoryColumns, categoryColumnsExp);

                string dataColumnsExp = string.Join(",",
                    settings.DataColumns.Select(c => $"[{settings.DataTable}].[{c}]").ToArray());
                function.Inputs.SetInput(dataColumns, dataColumnsExp);

                function.Inputs.SetInput(calculateKind, $@"""{settings.CalculatedKind}""");

                function.Outputs.SetTableOutput(returnMessage, "returnMessage");
                function.Outputs.SetTableOutput(resultAll, "resultAll");

                function.Execute();
            });
        }

        private static DataFunctionDefinition GetFunctionDefinition(
            out InputParameter categoryColumns, 
            out InputParameter dataColumns, 
            out InputParameter calculateKind,
            out OutputParameter returnMessage,
            out OutputParameter resultAll)
        {
            string script = Encoding.UTF8.GetString(Resources.scripts_bai);

            DataFunctionDefinitionBuilder functionBuiler = new DataFunctionDefinitionBuilder("RTestTool",
                DataFunctionExecutorTypeIdentifiers.TERRScriptExecutor);

            functionBuiler.Settings.Add("script", script);
            functionBuiler.Settings.Add("forcelocalengine", string.Empty);

            InputParameterBuilder categoryColumnsBuilder = new InputParameterBuilder("Category_Columns", ParameterType.Table);
            InputParameterBuilder dataColumnsBuilder = new InputParameterBuilder("Data_Columns", ParameterType.Table);
            InputParameterBuilder calculateKindBuilder = new InputParameterBuilder("Calculate_Kind", ParameterType.Value);

            categoryColumnsBuilder.AddAllowedDataType(DataType.Integer);
            categoryColumnsBuilder.AddAllowedDataType(DataType.String);

            dataColumnsBuilder.AddAllowedDataType(DataType.Integer);
            dataColumnsBuilder.AddAllowedDataType(DataType.Real);

            calculateKindBuilder.AddAllowedDataType(DataType.String);

            OutputParameterBuilder returnMessageBuilder = new OutputParameterBuilder("returnMessage", ParameterType.Table);
            OutputParameterBuilder resultAllBuilder = new OutputParameterBuilder("resultAll", ParameterType.Table);

            categoryColumns = categoryColumnsBuilder.Build();
            dataColumns = dataColumnsBuilder.Build();
            calculateKind = calculateKindBuilder.Build();
            returnMessage = returnMessageBuilder.Build();
            resultAll = resultAllBuilder.Build();

            functionBuiler.InputParameters.Add(categoryColumns);
            functionBuiler.InputParameters.Add(dataColumns);
            functionBuiler.InputParameters.Add(calculateKind);
            functionBuiler.OutputParameters.Add(returnMessage);
            functionBuiler.OutputParameters.Add(resultAll);

            return functionBuiler.Build();
        }
    }
}
