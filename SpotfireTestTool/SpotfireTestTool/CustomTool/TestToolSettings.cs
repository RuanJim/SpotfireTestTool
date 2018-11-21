// --------------------------------------------------------------------------------------------------------------------
// <copyright file="TestToolSettings.cs" company="PerkinElmer Inc.">
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
using System.Runtime.Serialization;
using Spotfire.Dxp.Application.Extension;
using Spotfire.Dxp.Framework.DocumentModel;
using Spotfire.Dxp.Framework.Persistence;

#endregion

namespace Com.PerkinElmer.Service.SpotfireTestTool.CustomTool
{
    [Serializable]
    [PersistenceVersion(1, 0)]
    public sealed class TestToolSettings : CustomNode
    {
        private readonly UndoableProperty<string> calculatedKind;
        private readonly UndoableList<string> categoryColumns;
        private readonly UndoableList<string> dataColumns;
        private readonly UndoableProperty<string> dataRange;
        private readonly UndoableProperty<string> dataTable;

        public string CalculatedKind
        {
            get { return this.calculatedKind.Value; }
            set { this.calculatedKind.Value = value; }
        }

        public string DataTable {
            get { return this.dataTable.Value; }
            set { this.dataTable.Value = value; }
        }

        public string DataRange {
            get { return this.dataRange.Value; }
            set { this.dataRange.Value = value; }
        }

        public string[] CategoryColumns
        {
            get { return this.categoryColumns.ToArray(); }
            set { this.categoryColumns.Clear(); this.categoryColumns.AddRange(value); }
        }

        public string[] DataColumns
        {
            get { return this.dataColumns.ToArray(); }
            set { this.dataColumns.Clear(); this.categoryColumns.AddRange(value); }
        }

        public TestToolSettings()
        {
            CreateProperty(PropertyNames.DataTable, out dataTable, string.Empty);
            CreateProperty(PropertyNames.DataRange, out dataRange, string.Empty);
            CreateProperty(PropertyNames.CalculateKind, out calculatedKind, string.Empty);
            CreateProperty(PropertyNames.CategoryColumns, out categoryColumns);
            CreateProperty(PropertyNames.DataColumns, out dataColumns);
        }

        public TestToolSettings(SerializationInfo info, StreamingContext context)
            : base(info, context)
        {
            DeserializeProperty(info, context, PropertyNames.DataTable, out dataTable);
            DeserializeProperty(info, context, PropertyNames.DataRange, out dataRange);
            DeserializeProperty(info, context, PropertyNames.CalculateKind, out calculatedKind);
            DeserializeProperty(info, context, PropertyNames.CategoryColumns, out categoryColumns);
            DeserializeProperty(info, context, PropertyNames.DataColumns, out dataColumns);
        }

        protected override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            base.GetObjectData(info, context);

            SerializeProperty(info, context, dataTable);
            SerializeProperty(info, context, dataRange);
            SerializeProperty(info, context, calculatedKind);
            SerializeProperty(info, context, categoryColumns);
            SerializeProperty(info, context, dataColumns);
        }

        public new class PropertyNames : CustomNode.PropertyNames
        {
            public static readonly PropertyName DataTable = CreatePropertyName("dataTable");
            public static readonly PropertyName DataRange = CreatePropertyName("dataRange");
            public static readonly PropertyName CategoryColumns = CreatePropertyName("categoryColumns");
            public static readonly PropertyName DataColumns = CreatePropertyName("dataColumns");
            public static readonly PropertyName CalculateKind = CreatePropertyName("CalculateKind");
        }
    }
}
