using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;
using Spotfire.Dxp.Application.Extension;
using Spotfire.Dxp.Framework.DocumentModel;
using Spotfire.Dxp.Framework.Persistence;

namespace Com.PerkinElmer.Service.SpotfireTestTool.CustomTool
{
    [Serializable]
    [PersistenceVersion(1, 0)]
    public sealed class TestToolSettings : CustomNode
    {
        private readonly UndoableProperty<string> DataTable;
        private readonly UndoableProperty<string> DataRange;
        private readonly UndoableList<string> CategoryColumns;
        private readonly UndoableList<string> DataColumns;
        private readonly UndoableProperty<string> CalculatedKind;

        public TestToolSettings()
        {
            this.CreateProperty(PropertyNames.DataTable, out this.DataTable, string.Empty);
            this.CreateProperty(PropertyNames.DataRange, out this.DataRange, string.Empty);
            this.CreateProperty(PropertyNames.CalculateKind, out this.CalculatedKind, string.Empty);
            this.CreateProperty(PropertyNames.CategoryColumns, out this.CategoryColumns);
            this.CreateProperty(PropertyNames.DataColumns, out this.DataColumns);
        }

        public TestToolSettings(SerializationInfo info, StreamingContext context)
            : base(info, context)
        {
            this.DeserializeProperty(info, context, PropertyNames.DataTable, out this.DataTable);
            this.DeserializeProperty(info, context, PropertyNames.DataRange, out this.DataRange);
            this.DeserializeProperty(info, context, PropertyNames.CalculateKind, out this.CalculatedKind);
            this.DeserializeProperty(info, context, PropertyNames.CategoryColumns, out this.CategoryColumns);
            this.DeserializeProperty(info, context, PropertyNames.DataColumns, out this.DataColumns);
        }

        protected override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            base.GetObjectData(info, context);

            this.SerializeProperty(info, context, this.DataTable);
            this.SerializeProperty(info, context, this.DataRange);
            this.SerializeProperty(info, context, this.CalculatedKind);
            this.SerializeProperty(info, context, this.CategoryColumns);
            this.SerializeProperty(info, context, this.DataTable);
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
