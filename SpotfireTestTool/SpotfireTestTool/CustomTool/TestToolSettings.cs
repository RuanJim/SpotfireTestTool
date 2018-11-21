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
        private readonly UndoableProperty<string> CalculatedKind;
        private readonly UndoableList<string> CategoryColumns;
        private readonly UndoableList<string> DataColumns;
        private readonly UndoableProperty<string> DataRange;
        private readonly UndoableProperty<string> DataTable;

        public TestToolSettings()
        {
            CreateProperty(PropertyNames.DataTable, out DataTable, string.Empty);
            CreateProperty(PropertyNames.DataRange, out DataRange, string.Empty);
            CreateProperty(PropertyNames.CalculateKind, out CalculatedKind, string.Empty);
            CreateProperty(PropertyNames.CategoryColumns, out CategoryColumns);
            CreateProperty(PropertyNames.DataColumns, out DataColumns);
        }

        public TestToolSettings(SerializationInfo info, StreamingContext context)
            : base(info, context)
        {
            DeserializeProperty(info, context, PropertyNames.DataTable, out DataTable);
            DeserializeProperty(info, context, PropertyNames.DataRange, out DataRange);
            DeserializeProperty(info, context, PropertyNames.CalculateKind, out CalculatedKind);
            DeserializeProperty(info, context, PropertyNames.CategoryColumns, out CategoryColumns);
            DeserializeProperty(info, context, PropertyNames.DataColumns, out DataColumns);
        }

        protected override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            base.GetObjectData(info, context);

            SerializeProperty(info, context, DataTable);
            SerializeProperty(info, context, DataRange);
            SerializeProperty(info, context, CalculatedKind);
            SerializeProperty(info, context, CategoryColumns);
            SerializeProperty(info, context, DataTable);
        }

        public new class PropertyNames : CustomNode.PropertyNames
        {
            public static readonly PropertyName DataTable = CreatePropertyName("DataTable");
            public static readonly PropertyName DataRange = CreatePropertyName("DataRange");
            public static readonly PropertyName CategoryColumns = CreatePropertyName("CategoryColumns");
            public static readonly PropertyName DataColumns = CreatePropertyName("DataColumns");
            public static readonly PropertyName CalculateKind = CreatePropertyName("CalculateKind");
        }
    }
}
